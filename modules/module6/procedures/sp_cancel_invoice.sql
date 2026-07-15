CREATE OR ALTER PROCEDURE sp_cancel_invoice
(
    @booking_id INT
)
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS
    (
        SELECT 1
        FROM invoices
        WHERE booking_id = @booking_id
    )
        RAISERROR('Invoice not found.',16,1);

    IF EXISTS
    (
        SELECT 1
        FROM invoices
        WHERE booking_id = @booking_id
          AND status = 'PAID'
    )
        RAISERROR('Paid invoices cannot be cancelled.',16,1);
        RETURN;

    UPDATE invoices
    SET
        status = 'CANCELLED'
    WHERE booking_id = @booking_id
      AND status <> 'CANCELLED';
END;
