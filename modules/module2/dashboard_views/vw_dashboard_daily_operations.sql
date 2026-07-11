CREATE OR ALTER VIEW vw_dashboard_daily_operations AS
SELECT
    fi.flight_date,
    fi.status_code,
    r.origin_iata_code,
    r.dest_iata_code,
    CONCAT(r.origin_iata_code, ' -> ', r.dest_iata_code) AS route_code,
    COUNT(fi.id) AS flight_count,
    SUM(CASE WHEN fi.is_manifest_closed = 1 THEN 1 ELSE 0 END) AS closed_manifest_count
FROM flight_instances fi
INNER JOIN flight_schedules fs
    ON fs.id = fi.flight_schedule_id
INNER JOIN routes r
    ON r.id = fs.route_id
GROUP BY
    fi.flight_date,
    fi.status_code,
    r.origin_iata_code,
    r.dest_iata_code;
GO
