SET NOCOUNT ON;

PRINT 'M5-M6 TEST SETUP';

DECLARE @booking_id INT;
DECLARE @invoice_id INT;

BEGIN TRY
    BEGIN TRANSACTION;

    SELECT TOP 1 @booking_id = b.id
    FROM bookings b
    INNER JOIN booking_statuses bs
        ON bs.id = b.status_id
    INNER JOIN flight_instances fi
        ON fi.id = b.flight_instance_id
    WHERE bs.code = 'CONFIRMED'
      AND fi.status_code IN ('SCHEDULED', 'DELAYED')
      AND fi.is_manifest_closed = 0
      AND EXISTS
      (
          SELECT 1
          FROM seat_assignments sa
          WHERE sa.booking_id = b.id
            AND sa.flight_instance_id = b.flight_instance_id
      )
      AND EXISTS
      (
          SELECT 1
          FROM boarding_groups bg
          WHERE bg.flight_instance_id = b.flight_instance_id
      )
      AND EXISTS
      (
          SELECT 1
          FROM check_ins ci
          WHERE ci.booking_id = b.id
      )
    ORDER BY b.id;

    IF @booking_id IS NULL
    BEGIN
        THROW 57000, 'M5-M6 test setup failed: no eligible confirmed booking with check-in seed was found.', 1;
    END;

    DELETE bt
    FROM baggage_tags bt
    INNER JOIN check_ins ci
        ON ci.id = bt.check_in_id
    WHERE ci.booking_id = @booking_id;

    DELETE FROM check_ins
    WHERE booking_id = @booking_id;

    DELETE FROM invoices
    WHERE booking_id = @booking_id;

    PRINT 'TEST 1: check-in without invoice must fail';

    BEGIN TRY
        EXEC sp_check_in_passenger
            @booking_id = @booking_id,
            @channel = 'WEB';

        THROW 57001, 'TEST 1 failed: check-in without invoice should have failed.', 1;
    END TRY
    BEGIN CATCH
        IF ERROR_NUMBER() = 57001
            THROW;
    END CATCH;

    PRINT 'TEST 2: check-in with PENDING invoice must fail';

    EXEC sp_generate_invoice @booking_id = @booking_id;

    SELECT @invoice_id = id
    FROM invoices
    WHERE booking_id = @booking_id;

    BEGIN TRY
        EXEC sp_check_in_passenger
            @booking_id = @booking_id,
            @channel = 'WEB';

        THROW 57002, 'TEST 2 failed: check-in with PENDING invoice should have failed.', 1;
    END TRY
    BEGIN CATCH
        IF ERROR_NUMBER() = 57002
            THROW;
    END CATCH;

    PRINT 'TEST 3: check-in with PAID invoice must succeed';

    EXEC sp_register_payment @invoice_id = @invoice_id;

    EXEC sp_check_in_passenger
        @booking_id = @booking_id,
        @channel = 'WEB';

    IF NOT EXISTS (SELECT 1 FROM check_ins WHERE booking_id = @booking_id)
    BEGIN
        THROW 57003, 'TEST 3 failed: check-in was not created for PAID invoice.', 1;
    END;

    ROLLBACK TRANSACTION;

    PRINT 'M5-M6 TESTS PASSED';
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;

    THROW;
END CATCH;
