CREATE OR ALTER PROCEDURE sp_register_payment
(
    @invoice_id INT
)
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS
    (
        SELECT 1
        FROM invoices
        WHERE id = @invoice_id
    )
    BEGIN
        RAISERROR('Invoice not found.',16,1);
        RETURN;
    END;

    IF EXISTS
    (
        SELECT 1
        FROM invoices
        WHERE id = @invoice_id
          AND status = 'PAID'
    )
    BEGIN
        RAISERROR('Invoice is already paid.',16,1);
        RETURN;
    END;

    IF EXISTS
    (
        SELECT 1
        FROM invoices
        WHERE id = @invoice_id
          AND status = 'CANCELLED'
    )
    BEGIN
        RAISERROR('Cancelled invoices cannot receive payments.',16,1);
        RETURN;
    END;

    UPDATE invoices
    SET
        status = 'PAID',
        payment_date = GETDATE()
    WHERE id = @invoice_id;
END;
