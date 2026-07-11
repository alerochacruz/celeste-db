CREATE OR ALTER VIEW vw_dashboard_flight_occupancy AS
SELECT
    fi.id AS flight_instance_id,
    fs.flight_number,
    fi.flight_date,
    fi.status_code,
    CONCAT(r.origin_iata_code, ' -> ', r.dest_iata_code) AS route_code,
    a.registration_number,
    sc.total_seats,
    COUNT(sa.id) AS assigned_seats,
    CAST(
        COUNT(sa.id) * 100.0 / NULLIF(sc.total_seats, 0)
        AS DECIMAL(6,2)
    ) AS occupancy_pct
FROM flight_instances fi
INNER JOIN flight_schedules fs
    ON fs.id = fi.flight_schedule_id
INNER JOIN routes r
    ON r.id = fs.route_id
INNER JOIN aircrafts a
    ON a.id = fi.aircraft_id
INNER JOIN seat_configurations sc
    ON sc.id = a.seat_config_id
LEFT JOIN seat_assignments sa
    ON sa.flight_instance_id = fi.id
GROUP BY
    fi.id,
    fs.flight_number,
    fi.flight_date,
    fi.status_code,
    r.origin_iata_code,
    r.dest_iata_code,
    a.registration_number,
    sc.total_seats;
GO
