#!/usr/bin/env python3
import json
import os
import random
import string
import sys
import time
import urllib.error
import urllib.parse
import urllib.request

import yaml


METABASE_URL = os.getenv("METABASE_URL", "http://metabase:3000").rstrip("/")
ADMIN_EMAIL = os.getenv("MB_SETUP_ADMIN_EMAIL", "admin@celeste.local")
ADMIN_PASSWORD = os.getenv("MB_SETUP_ADMIN_PASSWORD", "Celeste2026!")
MANIFEST_PATH = os.getenv("DASHBOARD_MANIFEST", "/dashboard.yaml")
APP_DB_HOST = os.getenv("MB_APP_DB_HOST", "metabase-db")
APP_DB_PORT = int(os.getenv("MB_APP_DB_PORT", "5432"))
APP_DB_NAME = os.getenv("MB_APP_DB_NAME", "metabase")
APP_DB_USER = os.getenv("MB_APP_DB_USER", "metabase")
APP_DB_PASS = os.getenv("MB_APP_DB_PASS", "metabase")


class MetabaseError(RuntimeError):
    pass


def request(method, path, payload=None, session_id=None):
    data = None
    headers = {"Content-Type": "application/json"}
    if session_id:
        headers["X-Metabase-Session"] = session_id
    if payload is not None:
        data = json.dumps(payload).encode("utf-8")

    req = urllib.request.Request(
        f"{METABASE_URL}{path}",
        data=data,
        headers=headers,
        method=method,
    )
    try:
        with urllib.request.urlopen(req, timeout=30) as response:
            body = response.read().decode("utf-8")
            return json.loads(body) if body else None
    except urllib.error.HTTPError as error:
        body = error.read().decode("utf-8", errors="replace")
        raise MetabaseError(f"{method} {path} failed with HTTP {error.code}: {body}") from error


def wait_for_metabase():
    print(f"Waiting for Metabase at {METABASE_URL}...")
    for _ in range(60):
        try:
            request("GET", "/api/health")
            return
        except Exception:
            time.sleep(2)
    raise MetabaseError("Metabase did not become healthy in time")


def login():
    response = request(
        "POST",
        "/api/session",
        {"username": ADMIN_EMAIL, "password": ADMIN_PASSWORD},
    )
    session_id = response.get("id") if isinstance(response, dict) else None
    if not session_id:
        raise MetabaseError(f"Could not log in to Metabase as {ADMIN_EMAIL}")
    return session_id


def first(items, predicate):
    return next((item for item in items if predicate(item)), None)


def find_database(session_id, name):
    response = request("GET", "/api/database", session_id=session_id)
    databases = response.get("data", []) if isinstance(response, dict) else []
    database = first(databases, lambda item: item.get("name") == name)
    if not database:
        raise MetabaseError(f"Metabase database '{name}' was not found. Run metabase-setup first.")
    return database


def ensure_collection(session_id, name):
    collections = request("GET", "/api/collection", session_id=session_id)
    collection = first(collections, lambda item: item.get("name") == name)
    if collection:
        print(f"Collection exists: {name}")
        return collection

    print(f"Creating collection: {name}")
    return request("POST", "/api/collection", {"name": name}, session_id=session_id)


def search(session_id, query, model):
    response = request(
        "GET",
        f"/api/search?q={urllib.parse.quote(query)}&models={urllib.parse.quote(model)}",
        session_id=session_id,
    )
    return response.get("data", []) if isinstance(response, dict) else response


def find_card(session_id, name, search_model="card"):
    results = search(session_id, name, search_model)
    return first(results, lambda item: item.get("name") == name)


def native_query_card_payload(item, database_id, collection_id):
    sql = item.get("sql") or f"SELECT * FROM {item['view']};"
    return {
        "name": item["name"],
        "description": item.get("description"),
        "display": item.get("display", "table"),
        "type": "question",
        "dataset_query": {
            "database": database_id,
            "type": "native",
            "native": {"query": sql},
        },
        "visualization_settings": item.get("visualization_settings", {}),
        "collection_id": collection_id,
    }


def upsert_question(session_id, item, database_id, collection_id):
    existing = find_card(session_id, item["name"], "card")
    payload = native_query_card_payload(item, database_id, collection_id)
    if existing:
        print(f"Updating question: {item['name']}")
        return request("PUT", f"/api/card/{existing['id']}", payload, session_id=session_id)

    print(f"Creating question: {item['name']}")
    return request("POST", "/api/card", payload, session_id=session_id)


def find_dashboard(session_id, name):
    results = search(session_id, name, "dashboard")
    return first(results, lambda item: item.get("name") == name)


def ensure_dashboard(session_id, dashboard, collection_id):
    existing = find_dashboard(session_id, dashboard["name"])
    payload = {
        "name": dashboard["name"],
        "description": dashboard.get("description"),
        "collection_id": collection_id,
        "width": dashboard.get("width", "full"),
    }
    if existing:
        print(f"Dashboard exists: {dashboard['name']}")
        request("PUT", f"/api/dashboard/{existing['id']}", payload, session_id=session_id)
        return request("GET", f"/api/dashboard/{existing['id']}", session_id=session_id)

    print(f"Creating dashboard: {dashboard['name']}")
    created = request("POST", "/api/dashboard", payload, session_id=session_id)
    dashboard_id = created.get("id") if isinstance(created, dict) else None
    if not dashboard_id:
        created = find_dashboard(session_id, dashboard["name"])
        dashboard_id = created.get("id") if created else None
    if not dashboard_id:
        raise MetabaseError(f"Dashboard '{dashboard['name']}' was created but could not be loaded")
    return request("GET", f"/api/dashboard/{dashboard_id}", session_id=session_id)


def add_cards_to_dashboard(session_id, loaded_dashboard, dashboard_config, question_cards):
    import psycopg

    dashboard_id = loaded_dashboard["id"]
    connection_info = {
        "host": APP_DB_HOST,
        "port": APP_DB_PORT,
        "dbname": APP_DB_NAME,
        "user": APP_DB_USER,
        "password": APP_DB_PASS,
    }

    with psycopg.connect(**connection_info) as conn:
        with conn.cursor() as cur:
            for index, card_config in enumerate(dashboard_config.get("cards", [])):
                question_name = card_config["question"]
                question = question_cards.get(question_name)
                if not question:
                    raise MetabaseError(f"Question '{question_name}' was not created")

                cur.execute(
                    """
                    SELECT id
                    FROM report_dashboardcard
                    WHERE dashboard_id = %s AND card_id = %s
                    """,
                    (dashboard_id, question["id"]),
                )
                existing = cur.fetchone()
                values = (
                    card_config.get("w", 12),
                    card_config.get("h", 8),
                    card_config.get("y", index * 8),
                    card_config.get("x", 0),
                    "[]",
                    "{}",
                )
                if existing:
                    print(f"Updating dashboard card: {question_name}")
                    cur.execute(
                        """
                        UPDATE report_dashboardcard
                        SET size_x = %s,
                            size_y = %s,
                            row = %s,
                            col = %s,
                            parameter_mappings = %s,
                            visualization_settings = %s,
                            updated_at = now()
                        WHERE id = %s
                        """,
                        (*values, existing[0]),
                    )
                else:
                    entity_id = "".join(random.choices(string.ascii_letters + string.digits, k=21))
                    print(f"Adding dashboard card: {question_name}")
                    cur.execute(
                        """
                        INSERT INTO report_dashboardcard
                            (dashboard_id, card_id, size_x, size_y, row, col,
                             parameter_mappings, visualization_settings, entity_id)
                        VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s)
                        """,
                        (dashboard_id, question["id"], *values, entity_id),
                    )
        conn.commit()


def main():
    with open(MANIFEST_PATH, "r", encoding="utf-8") as file:
        manifest = yaml.safe_load(file)

    wait_for_metabase()
    session_id = login()
    database = find_database(session_id, manifest["database"])
    collection = ensure_collection(session_id, manifest["collection"])

    question_cards = {}
    for question in manifest.get("questions", []):
        card = upsert_question(session_id, question, database["id"], collection["id"])
        question_cards[question["name"]] = card

    dashboard = ensure_dashboard(session_id, manifest["dashboard"], collection["id"])
    add_cards_to_dashboard(session_id, dashboard, manifest["dashboard"], question_cards)
    print("Dashboard setup complete.")


if __name__ == "__main__":
    try:
        main()
    except Exception as error:
        print(error, file=sys.stderr)
        sys.exit(1)
