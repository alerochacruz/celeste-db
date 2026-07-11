CREATE OR ALTER VIEW vw_dashboard_fleet_status AS
SELECT
    ms.status_code,
    ms.description AS status_description,
    ms.is_operational,
    COUNT(a.id) AS aircraft_count,
    SUM(sc.total_seats) AS total_seats,
    CAST(AVG(CAST(sc.total_seats AS DECIMAL(10,2))) AS DECIMAL(10,2)) AS avg_seats_per_aircraft
FROM maintenance_status ms
LEFT JOIN aircrafts a
    ON a.current_status_id = ms.id
LEFT JOIN seat_configurations sc
    ON sc.id = a.seat_config_id
GROUP BY
    ms.status_code,
    ms.description,
    ms.is_operational;
GO
