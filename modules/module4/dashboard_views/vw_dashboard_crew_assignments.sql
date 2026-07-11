CREATE OR ALTER VIEW vw_dashboard_crew_assignments AS
SELECT
    fi.id AS flight_instance_id,
    fs.flight_number,
    fi.flight_date,
    CONCAT(r.origin_iata_code, ' -> ', r.dest_iata_code) AS route_code,
    cr.role_name,
    COUNT(ca.id) AS assigned_crew_count,
    SUM(CASE WHEN cm.is_active = 1 THEN 1 ELSE 0 END) AS active_crew_count
FROM flight_instances fi
INNER JOIN flight_schedules fs
    ON fs.id = fi.flight_schedule_id
INNER JOIN routes r
    ON r.id = fs.route_id
LEFT JOIN crew_assignments ca
    ON ca.flight_instance_id = fi.id
LEFT JOIN crew_members cm
    ON cm.id = ca.crew_member_id
LEFT JOIN crew_roles cr
    ON cr.id = cm.crew_role_id
GROUP BY
    fi.id,
    fs.flight_number,
    fi.flight_date,
    r.origin_iata_code,
    r.dest_iata_code,
    cr.role_name;
GO
