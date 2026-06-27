SET QUOTED_IDENTIFIER ON;
GO
CREATE OR ALTER VIEW vw_tasa_no_show AS
SELECT
    fm.flight_instance_id,
    fs.flight_number                       AS numero_vuelo,
    fi.flight_date                         AS fecha_vuelo,
    r.origin_iata_code                     AS origen,
    r.dest_iata_code                       AS destino,
    sc.total_seats                         AS capacidad_aeronave,
    fm.total_boarded                       AS embarcados,
    fm.total_no_shows                      AS no_shows,
    (fm.total_boarded + fm.total_no_shows) AS total_con_checkin,
    CASE
        WHEN (fm.total_boarded + fm.total_no_shows) = 0
            THEN CAST(0 AS DECIMAL(5,2))
        ELSE CAST(
            ROUND(
                CAST(fm.total_no_shows AS DECIMAL(5,2))
                / (fm.total_boarded + fm.total_no_shows) * 100,
            2) AS DECIMAL(5,2)
        )
    END                                    AS tasa_no_show_pct,
    CASE
        WHEN sc.total_seats = 0
            THEN CAST(0 AS DECIMAL(5,1))
        ELSE CAST(
            ROUND(
                CAST(fm.total_boarded AS DECIMAL(5,2)) / sc.total_seats * 100,
            1) AS DECIMAL(5,1)
        )
    END                                    AS pct_ocupacion_real,
    fm.total_weight_kg                     AS peso_total_kg,
    fm.max_takeoff_weight_kg               AS mtow_kg,
    fm.load_factor_pct                     AS factor_carga_pct,
    fm.closed_at                           AS cerrado_a
FROM flight_manifests fm
JOIN flight_instances   fi ON fm.flight_instance_id = fi.id
JOIN flight_schedules   fs ON fi.flight_schedule_id = fs.id
JOIN routes              r ON fs.route_id           = r.id
JOIN aircrafts           a ON fi.aircraft_id        = a.id
JOIN seat_configurations sc ON a.seat_config_id    = sc.id
                           AND a.aircraft_type_id  = sc.aircraft_type_id;
