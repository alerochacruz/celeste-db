-- ============================================================
-- DEMO MÓDULO 4: Tripulaciones y Asignaciones
-- Este script asigna la tripulación para los vuelos creados
-- en el demo del Módulo 2 (vuelos QV855 y QV856).
-- ============================================================

USE celeste;
GO

-- 1. Obtener los IDs necesarios
DECLARE @AircraftTypeId INT = (SELECT id FROM aircraft_types WHERE model = 'A320-777');
DECLARE @JohnId INT = (SELECT id FROM crew_members WHERE email = 'john.smith@celeste.com');
DECLARE @DavidId INT = (SELECT id FROM crew_members WHERE email = 'david.chen@celeste.com');
DECLARE @EmilyId INT = (SELECT id FROM crew_members WHERE email = 'emily.watson@celeste.com');
DECLARE @AliceId INT = (SELECT id FROM crew_members WHERE email = 'alice.tan@celeste.com');

DECLARE @FlightQV855 INT = (
    SELECT fi.id 
    FROM flight_instances fi
    JOIN flight_schedules fs ON fi.flight_schedule_id = fs.id
    WHERE fs.flight_number = 'QV855' AND fi.flight_date = '2026-11-02'
);

DECLARE @FlightQV856 INT = (
    SELECT fi.id 
    FROM flight_instances fi
    JOIN flight_schedules fs ON fi.flight_schedule_id = fs.id
    WHERE fs.flight_number = 'QV856' AND fi.flight_date = '2026-11-06'
);

-- 2. Habilitar la certificación para el nuevo avión Airbus A320-777
-- Si no insertamos estas certificaciones, el trigger del Módulo 4 bloquearía la asignación.
IF NOT EXISTS (SELECT 1 FROM crew_certifications WHERE crew_member_id = @JohnId AND aircraft_type_id = @AircraftTypeId)
BEGIN
    INSERT INTO crew_certifications (crew_member_id, aircraft_type_id, issue_date, expiration_date, certification_number)
    VALUES (@JohnId, @AircraftTypeId, '2026-01-01', '2027-01-01', 'CERT-JS-A320-777');
END;

IF NOT EXISTS (SELECT 1 FROM crew_certifications WHERE crew_member_id = @DavidId AND aircraft_type_id = @AircraftTypeId)
BEGIN
    INSERT INTO crew_certifications (crew_member_id, aircraft_type_id, issue_date, expiration_date, certification_number)
    VALUES (@DavidId, @AircraftTypeId, '2026-01-01', '2027-01-01', 'CERT-DC-A320-777');
END;

-- 3. Asignar tripulación para el vuelo QV855 (VTE-CSX, 2026-11-02)
-- Asignamos Capitán, Primer Oficial, Purser y Tripulación de Cabina
INSERT INTO crew_assignments (flight_instance_id, crew_member_id)
VALUES 
    (@FlightQV855, @JohnId),  -- Capitán
    (@FlightQV855, @DavidId), -- Primer Oficial
    (@FlightQV855, @EmilyId), -- Purser (Jefa de Cabina)
    (@FlightQV855, @AliceId); -- Tripulante de Cabina

-- 4. Asignar tripulación para el vuelo QV856 (CSX-VTE, 2026-11-06)
-- La tripulación regresa en el siguiente vuelo programado unos días después (se cumplen las 10hs de descanso)
INSERT INTO crew_assignments (flight_instance_id, crew_member_id)
VALUES 
    (@FlightQV856, @JohnId),  -- Capitán
    (@FlightQV856, @DavidId), -- Primer Oficial
    (@FlightQV856, @EmilyId), -- Purser
    (@FlightQV856, @AliceId); -- Tripulante de Cabina

PRINT 'Demo Módulo 4: Tripulaciones asignadas con éxito a los vuelos QV855 y QV856.';
GO
