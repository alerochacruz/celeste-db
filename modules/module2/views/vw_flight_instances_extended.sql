CREATE OR ALTER VIEW vw_flight_instances_extended AS
SELECT 
    fi.flight_schedule_id,
    fi.aircraft_id,
    act.manufacturer AS aircraft_manufacturer,
    act.model AS aircraft_model,
    -- Format: YYYY-MM-DD
    CONVERT(CHAR(10), fi.flight_date, 120) AS flight_date,
    -- Format: YYYY-MM-DD HH:MM:SS
    CONVERT(CHAR(19), fi.actual_departure_time, 120) AS actual_departure_time,
    CONVERT(CHAR(19), fi.actual_arrival_time, 120) AS actual_arrival_time,
    fi.status_code,
    fi.is_manifest_closed
FROM flight_instances fi
INNER JOIN aircrafts ac 
    ON fi.aircraft_id = ac.id
INNER JOIN aircraft_types act 
    ON ac.aircraft_type_id = act.id;
