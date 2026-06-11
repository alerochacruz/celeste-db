USE celeste;
GO

-- ============================================================
-- PRUEBAS DE TRIGGER DEL MÓDULO 4
-- ============================================================

-- TEST 1: Intento de asignación de piloto sin certificación
-- John Smith es piloto, pero NO está certificado para ATR-500 (tipo 2)
PRINT '------------------------------------------------------------';
PRINT 'TEST 1: Asignar piloto a avion para el cual no esta certificado';
PRINT '------------------------------------------------------------';
DECLARE @JohnId INT = (SELECT id FROM crew_members WHERE email = 'john.smith@celeste.com');
DECLARE @ATR500FlightId INT = (
    SELECT TOP 1 fi.id 
    FROM flight_instances fi
    JOIN aircrafts a ON fi.aircraft_id = a.id
    WHERE a.aircraft_type_id = 2 AND fi.flight_date = '2026-03-15'
);

BEGIN TRANSACTION;
BEGIN TRY
    INSERT INTO crew_assignments (flight_instance_id, crew_member_id)
    VALUES (@ATR500FlightId, @JohnId);
    PRINT 'ERROR: El Test 1 debio fallar pero se inserto correctamente.';
    ROLLBACK TRANSACTION;
END TRY
BEGIN CATCH
    PRINT 'EXITO (Esperado): Fallo la insercion.';
    PRINT 'Mensaje de error: ' + ERROR_MESSAGE();
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
END CATCH;
GO

-- TEST 2: Intento de asignación con menos de 10 horas de descanso
-- Maria Gonzalez está certificada para el ATR-500 (tipo 2)
-- Intentamos asignarla a dos vuelos del 2026-03-01 con 1 hora y 8 minutos de diferencia
PRINT '';
PRINT '------------------------------------------------------------';
PRINT 'TEST 2: Asignar tripulante a dos vuelos con descanso insuficiente (<10hs)';
PRINT '------------------------------------------------------------';
DECLARE @MariaId INT = (SELECT id FROM crew_members WHERE email = 'maria.gonzalez@celeste.com');
DECLARE @FlightShortRest1 INT = (
    SELECT id FROM flight_instances WHERE flight_date = '2026-03-01' AND actual_departure_time = '2026-03-01 12:40:00'
);
DECLARE @FlightShortRest2 INT = (
    SELECT id FROM flight_instances WHERE flight_date = '2026-03-01' AND actual_departure_time = '2026-03-01 14:30:00'
);

BEGIN TRANSACTION;
BEGIN TRY
    -- Primera asignación (debe tener éxito ya que no hay conflictos aún)
    INSERT INTO crew_assignments (flight_instance_id, crew_member_id)
    VALUES (@FlightShortRest1, @MariaId);
    PRINT 'Asignacion 1 exitosa para Maria Gonzalez.';

    -- Segunda asignación (debe fallar por descanso insuficiente)
    INSERT INTO crew_assignments (flight_instance_id, crew_member_id)
    VALUES (@FlightShortRest2, @MariaId);
    PRINT 'ERROR: El Test 2 debio fallar pero se inserto correctamente.';
    
    ROLLBACK TRANSACTION;
END TRY
BEGIN CATCH
    PRINT 'EXITO (Esperado): Fallo la segunda insercion.';
    PRINT 'Mensaje de error: ' + ERROR_MESSAGE();
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
END CATCH;
GO

-- TEST 3: Asignación exitosa que cumple todas las reglas
-- David Chen (First Officer) está certificado para A320 y no tiene vuelos asignados ese día
PRINT '';
PRINT '------------------------------------------------------------';
PRINT 'TEST 3: Asignacion valida (Certificacion correcta y suficiente descanso)';
PRINT '------------------------------------------------------------';
DECLARE @DavidId INT = (SELECT id FROM crew_members WHERE email = 'david.chen@celeste.com');
DECLARE @A320FlightAId INT = (
    SELECT TOP 1 fi.id 
    FROM flight_instances fi 
    JOIN aircrafts a ON fi.aircraft_id = a.id
    WHERE a.aircraft_type_id = 1 AND fi.flight_date = '2026-03-06'
);

BEGIN TRANSACTION;
BEGIN TRY
    INSERT INTO crew_assignments (flight_instance_id, crew_member_id)
    VALUES (@A320FlightAId, @DavidId);
    PRINT 'EXITO: Se asigno correctamente a David Chen al vuelo A320.';
    ROLLBACK TRANSACTION; -- Hacemos rollback para mantener limpia la base de datos
END TRY
BEGIN CATCH
    PRINT 'ERROR: El Test 3 debio ser exitoso pero fallo.';
    PRINT 'Mensaje de error: ' + ERROR_MESSAGE();
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
END CATCH;
GO
