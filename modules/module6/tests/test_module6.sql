SET NOCOUNT ON;

PRINT 'M6 TEST SETUP';

DECLARE @pending_booking_id INT;
DECLARE @cancel_booking_id INT;
DECLARE @invoice_id INT;
DECLARE @cancelled_invoice_id INT;
DECLARE @status VARCHAR(20);

BEGIN TRY
    BEGIN TRANSACTION;

    SELECT TOP 1 @pending_booking_id = b.id
    FROM bookings b
    INNER JOIN booking_statuses bs
        ON bs.id = b.status_id
    WHERE bs.code = 'PENDING'
      AND NOT EXISTS (SELECT 1 FROM invoices i WHERE i.booking_id = b.id)
    ORDER BY b.id;

    IF @pending_booking_id IS NULL
    BEGIN
        THROW 56000, 'M6 test setup failed: no PENDING booking without invoice was found.', 1;
    END;

    PRINT 'TEST 1: generating invoice for confirmed booking';

    EXEC sp_confirm_booking @booking_id = @pending_booking_id;

    SELECT @invoice_id = id
    FROM invoices
    WHERE booking_id = @pending_booking_id;

    IF @invoice_id IS NULL
    BEGIN
        THROW 56001, 'TEST 1 failed: invoice was not generated.', 1;
    END;

    SELECT @status = status
    FROM invoices
    WHERE id = @invoice_id;

    IF @status <> 'PENDING'
    BEGIN
        THROW 56002, 'TEST 1 failed: generated invoice is not PENDING.', 1;
    END;

    PRINT 'TEST 2: registering invoice payment';

    EXEC sp_register_payment @invoice_id = @invoice_id;

    SELECT @status = status
    FROM invoices
    WHERE id = @invoice_id;

    IF @status <> 'PAID'
    BEGIN
        THROW 56003, 'TEST 2 failed: invoice was not marked as PAID.', 1;
    END;

    IF NOT EXISTS (SELECT 1 FROM invoices WHERE id = @invoice_id AND payment_date IS NOT NULL)
    BEGIN
        THROW 56004, 'TEST 2 failed: payment_date was not set.', 1;
    END;

    PRINT 'TEST 3: paid invoice cannot be cancelled';

    BEGIN TRY
        EXEC sp_cancel_invoice @booking_id = @pending_booking_id;
        THROW 56005, 'TEST 3 failed: paid invoice cancellation should have failed.', 1;
    END TRY
    BEGIN CATCH
        IF ERROR_NUMBER() = 56005
            THROW;
    END CATCH;

    SELECT @status = status
    FROM invoices
    WHERE id = @invoice_id;

    IF @status <> 'PAID'
    BEGIN
        THROW 56006, 'TEST 3 failed: paid invoice status changed.', 1;
    END;

    PRINT 'TEST 4: pending invoice can be cancelled';

    SELECT TOP 1 @cancel_booking_id = b.id
    FROM bookings b
    INNER JOIN booking_statuses bs
        ON bs.id = b.status_id
    WHERE bs.code = 'CONFIRMED'
      AND b.id <> @pending_booking_id
    ORDER BY b.id;

    IF @cancel_booking_id IS NULL
    BEGIN
        THROW 56007, 'M6 test setup failed: no CONFIRMED booking was found.', 1;
    END;

    DELETE FROM invoices
    WHERE booking_id = @cancel_booking_id;

    EXEC sp_generate_invoice @booking_id = @cancel_booking_id;
    EXEC sp_cancel_invoice @booking_id = @cancel_booking_id;

    SELECT
        @cancelled_invoice_id = id,
        @status = status
    FROM invoices
    WHERE booking_id = @cancel_booking_id;

    IF @cancelled_invoice_id IS NULL OR @status <> 'CANCELLED'
    BEGIN
        THROW 56008, 'TEST 4 failed: pending invoice was not cancelled.', 1;
    END;

    PRINT 'TEST 5: cancelled invoice cannot receive payment';

    BEGIN TRY
        EXEC sp_register_payment @invoice_id = @cancelled_invoice_id;
        THROW 56009, 'TEST 5 failed: cancelled invoice payment should have failed.', 1;
    END TRY
    BEGIN CATCH
        IF ERROR_NUMBER() = 56009
            THROW;
    END CATCH;

    ROLLBACK TRANSACTION;

    PRINT 'M6 TESTS PASSED';
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;

    THROW;
END CATCH;
