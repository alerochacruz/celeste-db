-- Obtener IDs de los miembros de la tripulación
DECLARE @JohnId INT = (SELECT id FROM crew_members WHERE email = 'john.smith@celeste.com');
DECLARE @DavidId INT = (SELECT id FROM crew_members WHERE email = 'david.chen@celeste.com');
DECLARE @EmilyId INT = (SELECT id FROM crew_members WHERE email = 'emily.watson@celeste.com');
DECLARE @AliceId INT = (SELECT id FROM crew_members WHERE email = 'alice.tan@celeste.com');

-- Obtener IDs de instancias de vuelo operadas por un A320 (tipo 1) en fechas específicas
-- Vuelo 1: 2026-03-03
DECLARE @Flight1Id INT = (
    SELECT TOP 1 fi.id 
    FROM flight_instances fi 
    JOIN aircrafts a ON fi.aircraft_id = a.id
    WHERE a.aircraft_type_id = 1 AND fi.flight_date = '2026-03-03'
);

-- Vuelo 2: 2026-03-04
DECLARE @Flight2Id INT = (
    SELECT TOP 1 fi.id 
    FROM flight_instances fi 
    JOIN aircrafts a ON fi.aircraft_id = a.id
    WHERE a.aircraft_type_id = 1 AND fi.flight_date = '2026-03-04'
);

-- Asignamos tripulación al Vuelo 1
IF @Flight1Id IS NOT NULL
BEGIN
    INSERT INTO crew_assignments (flight_instance_id, crew_member_id) VALUES
    (@Flight1Id, @JohnId),   -- Captain (Certificado A320)
    (@Flight1Id, @DavidId),  -- First Officer (Certificado A320)
    (@Flight1Id, @EmilyId),  -- Purser (No requiere cert)
    (@Flight1Id, @AliceId);  -- Cabin Crew (No requiere cert)
END

-- Asignamos la misma tripulación al Vuelo 2 (al día siguiente, > 10 horas de descanso)
IF @Flight2Id IS NOT NULL
BEGIN
    INSERT INTO crew_assignments (flight_instance_id, crew_member_id) VALUES
    (@Flight2Id, @JohnId),
    (@Flight2Id, @DavidId),
    (@Flight2Id, @EmilyId),
    (@Flight2Id, @AliceId);
END
