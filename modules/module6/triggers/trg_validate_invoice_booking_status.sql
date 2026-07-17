CREATE OR ALTER TRIGGER trg_validate_invoice_booking_status
ON invoices
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS
    (
        SELECT 1
        FROM inserted i
        INNER JOIN bookings b
            ON b.id = i.booking_id
        INNER JOIN booking_statuses bs
            ON bs.id = b.status_id
        WHERE bs.code <> 'CONFIRMED'
    )
    BEGIN
        RAISERROR('Invoice operation failed: booking must be CONFIRMED.', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END;
END;
GO
