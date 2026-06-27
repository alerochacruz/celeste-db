SET QUOTED_IDENTIFIER ON;
GO
CREATE OR ALTER VIEW vw_check_in_status AS
SELECT
    fi.id                                                          AS flight_instance_id,
    fs.flight_number                                               AS numero_vuelo,
    fi.flight_date                                                 AS fecha_vuelo,
    r.origin_iata_code                                             AS origen,
    r.dest_iata_code                                               AS destino,
    fi.status_code                                                 AS estado_vuelo,
    fi.is_manifest_closed                                          AS manifiesto_cerrado,
    sc.total_seats                                                 AS capacidad_total,
    COUNT(ci.id)                                                   AS total_checkins,
    SUM(CASE WHEN ci.status = 'CHECKED_IN' THEN 1 ELSE 0 END)     AS pendientes_abordar,
    SUM(CASE WHEN ci.status = 'BOARDED'    THEN 1 ELSE 0 END)     AS embarcados,
    SUM(CASE WHEN ci.status = 'NO_SHOW'    THEN 1 ELSE 0 END)     AS no_shows,
    CASE
        WHEN sc.total_seats = 0 THEN CAST(0 AS DECIMAL(5,1))
        ELSE CAST(
            ROUND(
                CAST(SUM(CASE WHEN ci.status = 'BOARDED' THEN 1 ELSE 0 END) AS DECIMAL(5,2))
                / sc.total_seats * 100,
            1) AS DECIMAL(5,1)
        )
    END                                                            AS pct_ocupacion
FROM flight_instances    fi
JOIN flight_schedules    fs ON fi.flight_schedule_id = fs.id
JOIN routes               r ON fs.route_id           = r.id
JOIN aircrafts            a ON fi.aircraft_id        = a.id
JOIN seat_configurations sc ON a.seat_config_id     = sc.id
                           AND a.aircraft_type_id   = sc.aircraft_type_id
LEFT JOIN check_ins      ci ON ci.flight_instance_id = fi.id
GROUP BY
    fi.id, fs.flight_number, fi.flight_date,
    r.origin_iata_code, r.dest_iata_code,
    fi.status_code, fi.is_manifest_closed,
    sc.total_seats;
