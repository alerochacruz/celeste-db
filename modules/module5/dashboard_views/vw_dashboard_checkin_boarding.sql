CREATE OR ALTER VIEW vw_dashboard_checkin_boarding AS
SELECT
    fi.id AS flight_instance_id,
    fs.flight_number,
    fi.flight_date,
    CONCAT(r.origin_iata_code, ' -> ', r.dest_iata_code) AS route_code,
    COUNT(ci.id) AS checked_in_count,
    SUM(CASE WHEN ci.status = 'BOARDED' THEN 1 ELSE 0 END) AS boarded_count,
    SUM(CASE WHEN ci.status = 'NO_SHOW' THEN 1 ELSE 0 END) AS no_show_count,
    COUNT(bt.id) AS baggage_count,
    CAST(COALESCE(SUM(bt.weight_kg), 0) AS DECIMAL(10,2)) AS baggage_weight_kg
FROM flight_instances fi
INNER JOIN flight_schedules fs
    ON fs.id = fi.flight_schedule_id
INNER JOIN routes r
    ON r.id = fs.route_id
LEFT JOIN check_ins ci
    ON ci.flight_instance_id = fi.id
LEFT JOIN baggage_tags bt
    ON bt.check_in_id = ci.id
GROUP BY
    fi.id,
    fs.flight_number,
    fi.flight_date,
    r.origin_iata_code,
    r.dest_iata_code;
GO
