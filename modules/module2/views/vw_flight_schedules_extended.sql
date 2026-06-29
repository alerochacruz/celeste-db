CREATE OR ALTER VIEW vw_flight_schedules_extended AS
SELECT 
    fs.id, 
    fs.route_id, 
    r.origin_iata_code, 
    r.dest_iata_code, 
    fs.flight_number, 
    fs.departure_terminal_id, 
    t_dep.name AS departure_terminal_name, 
    fs.arrival_terminal_id, 
    t_arr.name AS arrival_terminal_name, 
    -- Format: HH:MM:SS (Style 108 is specifically for 24-hour time formatting)
    CONVERT(CHAR(8), fs.scheduled_departure_time, 108) AS scheduled_departure_time, 
    CONVERT(CHAR(8), fs.scheduled_arrival_time, 108) AS scheduled_arrival_time, 
    fs.days_of_week, 
    fs.is_active
FROM flight_schedules fs
INNER JOIN routes r 
    ON fs.route_id = r.id
INNER JOIN terminals t_dep 
    ON fs.departure_terminal_id = t_dep.id
INNER JOIN terminals t_arr 
    ON fs.arrival_terminal_id = t_arr.id;
