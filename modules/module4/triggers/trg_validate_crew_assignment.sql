CREATE OR ALTER TRIGGER trg_validate_crew_assignment
ON crew_assignments
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    -- 1. VALIDACIÓN DE CERTIFICACIONES DE PILOTOS
    -- Si el tripulante asignado es un piloto (Captain o First Officer),
    -- debe tener una certificación vigente para el tipo de aeronave en la fecha del vuelo.
    IF EXISTS (
        SELECT 1
        FROM inserted i
        JOIN crew_members cm ON i.crew_member_id = cm.id
        JOIN crew_roles cr ON cm.crew_role_id = cr.id
        JOIN flight_instances fi ON i.flight_instance_id = fi.id
        JOIN aircrafts a ON fi.aircraft_id = a.id
        WHERE 
            cr.role_name IN ('Captain', 'First Officer')
            AND NOT EXISTS (
                SELECT 1
                FROM crew_certifications cc
                WHERE cc.crew_member_id = cm.id
                  AND cc.aircraft_type_id = a.aircraft_type_id
                  -- La fecha del vuelo debe estar dentro del rango de vigencia de la certificación
                  AND fi.flight_date >= cc.issue_date
                  AND fi.flight_date <= cc.expiration_date
            )
    )
    BEGIN
        RAISERROR('Error: Uno o más pilotos asignados no cuentan con una certificación vigente para el tipo de aeronave del vuelo asignado.', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END;

    -- 2. VALIDACIÓN DE DESCANSO REGULATORIO (Mínimo 10 horas = 600 minutos) Y SUPERPOSICIÓN DE VUELOS
    -- Para cada asignación modificada/insertada, se valida contra otras asignaciones del mismo tripulante.
    IF EXISTS (
        SELECT 1
        FROM inserted i
        JOIN flight_instances fi_new ON i.flight_instance_id = fi_new.id
        JOIN flight_schedules fs_new ON fi_new.flight_schedule_id = fs_new.id
        CROSS APPLY (
            SELECT 
                COALESCE(fi_new.actual_departure_time, CAST(CONCAT(fi_new.flight_date, ' ', fs_new.scheduled_departure_time) AS DATETIME)) AS NewStart,
                COALESCE(fi_new.actual_arrival_time, 
                    CASE WHEN fs_new.scheduled_arrival_time < fs_new.scheduled_departure_time 
                         THEN DATEADD(day, 1, CAST(CONCAT(fi_new.flight_date, ' ', fs_new.scheduled_arrival_time) AS DATETIME)) 
                         ELSE CAST(CONCAT(fi_new.flight_date, ' ', fs_new.scheduled_arrival_time) AS DATETIME) 
                    END) AS NewEnd
        ) AS times_new
        JOIN crew_assignments ca ON ca.crew_member_id = i.crew_member_id AND ca.flight_instance_id <> i.flight_instance_id
        JOIN flight_instances fi_other ON ca.flight_instance_id = fi_other.id
        JOIN flight_schedules fs_other ON fi_other.flight_schedule_id = fs_other.id
        CROSS APPLY (
            SELECT 
                COALESCE(fi_other.actual_departure_time, CAST(CONCAT(fi_other.flight_date, ' ', fs_other.scheduled_departure_time) AS DATETIME)) AS OtherStart,
                COALESCE(fi_other.actual_arrival_time, 
                    CASE WHEN fs_other.scheduled_arrival_time < fs_other.scheduled_departure_time 
                         THEN DATEADD(day, 1, CAST(CONCAT(fi_other.flight_date, ' ', fs_other.scheduled_arrival_time) AS DATETIME)) 
                         ELSE CAST(CONCAT(fi_other.flight_date, ' ', fs_other.scheduled_arrival_time) AS DATETIME) 
                    END) AS OtherEnd
        ) AS times_other
        WHERE 
            -- A. Superposición de horarios: los vuelos se solapan
            (times_other.OtherStart < times_new.NewEnd AND times_new.NewStart < times_other.OtherEnd)
            OR
            -- B. El vuelo anterior (Other) termina antes de que empiece el nuevo vuelo (New), pero hay menos de 10 horas de diferencia
            (times_other.OtherEnd <= times_new.NewStart AND DATEDIFF(minute, times_other.OtherEnd, times_new.NewStart) < 600)
            OR
            -- C. El nuevo vuelo (New) termina antes de que empiece el vuelo siguiente (Other), pero hay menos de 10 horas de diferencia
            (times_new.NewEnd <= times_other.OtherStart AND DATEDIFF(minute, times_new.NewEnd, times_other.OtherStart) < 600)
    )
    BEGIN
        RAISERROR('Error: Conflicto de itinerario. El tripulante tiene otro vuelo asignado que se superpone o no cumple con las 10 horas mínimas de descanso regulatorio.', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END;
END;
