#!/bin/sh
set -eu

METABASE_URL="${METABASE_URL:-http://metabase:3000}"
ADMIN_EMAIL="${MB_SETUP_ADMIN_EMAIL:-admin@celeste.local}"
ADMIN_PASSWORD="${MB_SETUP_ADMIN_PASSWORD:-Celeste2026!}"
ADMIN_FIRST_NAME="${MB_SETUP_ADMIN_FIRST_NAME:-Celeste}"
ADMIN_LAST_NAME="${MB_SETUP_ADMIN_LAST_NAME:-Admin}"
SITE_NAME="${MB_SITE_NAME:-Celeste}"

SQLSERVER_DB_NAME="${SQLSERVER_DB_NAME:-celeste}"
SQLSERVER_DB_HOST="${SQLSERVER_DB_HOST:-sqlserver}"
SQLSERVER_DB_PORT="${SQLSERVER_DB_PORT:-1433}"
SQLSERVER_DB_USER="${SQLSERVER_DB_USER:-sa}"
SQLSERVER_DB_PASS="${SQLSERVER_DB_PASS:-${SA_PASSWORD:-YourStrong!Passw0rd}}"

post_json() {
  url="$1"
  body="$2"
  shift 2
  curl -fsS -X POST "$url" -H 'Content-Type: application/json' "$@" -d "$body"
}

echo "Waiting for Metabase at $METABASE_URL..."
until curl -fsS "$METABASE_URL/api/health" >/dev/null; do
  sleep 2
done

properties="$(curl -fsS "$METABASE_URL/api/session/properties")"
setup_token="$(printf '%s' "$properties" | sed -n 's/.*"setup-token":"\([^"]*\)".*/\1/p')"
has_user_setup="$(printf '%s' "$properties" | sed -n 's/.*"has-user-setup":\([^,}]*\).*/\1/p')"

if [ "$has_user_setup" = "false" ] && [ -n "$setup_token" ]; then
  echo "Running Metabase first-time setup..."
  setup_payload="{
    \"token\": \"$setup_token\",
    \"user\": {
      \"first_name\": \"$ADMIN_FIRST_NAME\",
      \"last_name\": \"$ADMIN_LAST_NAME\",
      \"email\": \"$ADMIN_EMAIL\",
      \"password\": \"$ADMIN_PASSWORD\"
    },
    \"prefs\": {
      \"site_name\": \"$SITE_NAME\",
      \"site_locale\": \"es\",
      \"allow_tracking\": false
    }
  }"
  post_json "$METABASE_URL/api/setup" "$setup_payload" >/dev/null
else
  echo "Metabase is already configured; skipping first-time setup."
fi

session_payload="{\"username\":\"$ADMIN_EMAIL\",\"password\":\"$ADMIN_PASSWORD\"}"
session_id="$(post_json "$METABASE_URL/api/session" "$session_payload" | sed -n 's/.*"id":"\([^"]*\)".*/\1/p')"

if [ -z "$session_id" ]; then
  echo "Could not log in to Metabase with $ADMIN_EMAIL; skipping SQL Server datasource setup."
  exit 0
fi

if curl -fsS "$METABASE_URL/api/database" -H "X-Metabase-Session: $session_id" | grep -q "\"name\":\"Celeste SQL Server\""; then
  echo "SQL Server datasource already exists."
  exit 0
fi

database_payload="{
  \"name\": \"Celeste SQL Server\",
  \"engine\": \"sqlserver\",
  \"details\": {
    \"host\": \"$SQLSERVER_DB_HOST\",
    \"port\": $SQLSERVER_DB_PORT,
    \"db\": \"$SQLSERVER_DB_NAME\",
    \"user\": \"$SQLSERVER_DB_USER\",
    \"password\": \"$SQLSERVER_DB_PASS\",
    \"ssl\": false,
    \"tunnel-enabled\": false
  }
}"

echo "Creating SQL Server datasource in Metabase..."
for attempt in 1 2 3 4 5 6 7 8 9 10; do
  if post_json "$METABASE_URL/api/database" "$database_payload" -H "X-Metabase-Session: $session_id" >/dev/null 2>&1; then
    echo "SQL Server datasource created."
    exit 0
  fi
  echo "Datasource creation failed; retrying ($attempt/10)..."
  sleep 5
done

echo "Could not create SQL Server datasource. Make sure database '$SQLSERVER_DB_NAME' exists and credentials are valid."
exit 0
