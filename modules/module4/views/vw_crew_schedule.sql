CREATE OR ALTER VIEW vw_crew_schedule AS
SELECT 
    cm.id AS crew_member_id,
    cm.first_name,
    cm.last_name,
    cr.role_name AS crew_role,
    fi.id AS flight_instance_id,
    fi.flight_date,
    fs.flight_number,
    r.origin_iata_code,
    r.dest_iata_code,
    fs.scheduled_departure_time,
    fs.scheduled_arrival_time,
    fi.actual_departure_time,
    fi.actual_arrival_time,
    fi.status_code AS flight_status
FROM crew_assignments ca
JOIN crew_members cm ON ca.crew_member_id = cm.id
JOIN crew_roles cr ON cm.crew_role_id = cr.id
JOIN flight_instances fi ON ca.flight_instance_id = fi.id
JOIN flight_schedules fs ON fi.flight_schedule_id = fs.id
JOIN routes r ON fs.route_id = r.id;
