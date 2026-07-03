PRINT 'TEST: tr_seat_assignment_consistency';

PRINT '';
PRINT '--- Test A: Asignacion valida ---';

BEGIN TRANSACTION;
    BEGIN TRY
        INSERT INTO seat_assignments (passenger_id, booking_id, flight_instance_id, seat_number, class)
        VALUES (4, 1, 1, '30A', 'ECONOMY');

        PRINT '✅ PASS: Insert válido aceptado';
    END TRY
    BEGIN CATCH
        PRINT '❌ FAIL: Insert válido fue rechazado. Error: ' + ERROR_MESSAGE();
    END CATCH
ROLLBACK TRANSACTION;

PRINT '';
PRINT '--- Test A: Asignacion invalida ---';

BEGIN TRANSACTION;
    BEGIN TRY
        INSERT INTO seat_assignments (passenger_id, booking_id, flight_instance_id, seat_number, class)
        VALUES (4, 1, 2, '30A', 'ECONOMY');

        PRINT '✅ PASS: Insert válido aceptado';
    END TRY
    BEGIN CATCH
        PRINT '❌ FAIL: Insert válido fue rechazado. Error: ' + ERROR_MESSAGE();
    END CATCH
ROLLBACK TRANSACTION;