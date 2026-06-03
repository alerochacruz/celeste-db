GO
-- La ausencia del comando "GO" en la primera línea
-- arrojó el siguiente error en sqlcmd:
-- Msg 111, Level 15, State 1, Server 3a17bcf0ada7, Line 393
-- 'CREATE VIEW' must be the first statement in a query batch.
-- Comando ejecutado en sqlcmd que causó el error:
-- sqlcmd -S <host> -U <usr> -P <pwd> -i master_deploy.sql

CREATE VIEW vw_operative_fleet AS
SELECT
    a.id,
    a.registration_number,
    at2.manufacturer + ' ' + at2.model AS aircraft_type,
    sc.name                            AS seat_configuration,
    sc.economy_seats,
    sc.business_seats,
    sc.total_seats,
    ms.status_code
FROM aircrafts a
JOIN aircraft_types at2
    ON a.aircraft_type_id = at2.id
JOIN seat_configurations sc
    ON a.seat_config_id = sc.id
   AND a.aircraft_type_id = sc.aircraft_type_id -- Reflects relationship (composite foreign key)
JOIN maintenance_status ms
    ON a.current_status_id = ms.id
WHERE ms.is_operational = 1;
