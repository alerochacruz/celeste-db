SET QUOTED_IDENTIFIER ON;
GO
CREATE TABLE flight_manifests (
    id                      INT IDENTITY(1,1) NOT NULL,
    flight_instance_id      INT          NOT NULL,
    total_boarded           SMALLINT     NOT NULL DEFAULT 0,
    total_no_shows          SMALLINT     NOT NULL DEFAULT 0,
    baggage_weight_kg       DECIMAL(8,2) NOT NULL DEFAULT 0.00,
    estimated_pax_weight_kg DECIMAL(8,2) NOT NULL DEFAULT 0.00,
    total_weight_kg         AS (baggage_weight_kg + estimated_pax_weight_kg) PERSISTED,
    max_takeoff_weight_kg   DECIMAL(8,2) NOT NULL,
    load_factor_pct         AS (
        CASE
            WHEN (baggage_weight_kg + estimated_pax_weight_kg) = 0
                THEN CAST(0 AS DECIMAL(5,1))
            ELSE CAST(
                ROUND(
                    (baggage_weight_kg + estimated_pax_weight_kg)
                    / max_takeoff_weight_kg * 100,
                1) AS DECIMAL(5,1)
            )
        END
    ) PERSISTED,
    closed_at               DATETIME     NOT NULL DEFAULT GETDATE(),

    CONSTRAINT PK_flight_manifests
        PRIMARY KEY (id),
    CONSTRAINT FK_flight_manifests_flight
        FOREIGN KEY (flight_instance_id) REFERENCES flight_instances(id),
    CONSTRAINT UQ_flight_manifests_flight_instance
        UNIQUE (flight_instance_id),
    CONSTRAINT CK_flight_manifests_boarded
        CHECK (total_boarded >= 0),
    CONSTRAINT CK_flight_manifests_no_shows
        CHECK (total_no_shows >= 0),
    CONSTRAINT CK_flight_manifests_mtow
        CHECK (max_takeoff_weight_kg > 0)
);
