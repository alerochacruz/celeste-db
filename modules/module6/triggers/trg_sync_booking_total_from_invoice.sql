CREATE OR ALTER TRIGGER trg_sync_booking_total_from_invoice
ON invoices
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE b
    SET b.total_amount = i.total_amount
    FROM bookings b
    INNER JOIN inserted i
        ON i.booking_id = b.id;
END;
GO
