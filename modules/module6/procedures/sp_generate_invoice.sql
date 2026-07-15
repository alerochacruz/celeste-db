CREATE OR ALTER PROCEDURE sp_generate_invoice
(
    @booking_id INT
)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE
        @flight_instance_id INT,
        @status_code VARCHAR(20),
        @base_fare DECIMAL(10,2),
        @taxes DECIMAL(10,2),
        @extras DECIMAL(10,2);

    SELECT
        @flight_instance_id = b.flight_instance_id,
        @status_code = bs.code
    FROM bookings b
    INNER JOIN booking_statuses bs
        ON bs.id = b.status_id
    WHERE b.id = @booking_id;

    IF @status_code IS NULL
    BEGIN
        RAISERROR('Booking not found.',16,1);
        RETURN;
    END;

    IF @status_code <> 'CONFIRMED'
    BEGIN
        RAISERROR('Booking must be CONFIRMED.',16,1);
        RETURN;
    END;

    IF EXISTS
    (
        SELECT 1
        FROM invoices
        WHERE booking_id = @booking_id
    )
    BEGIN
        RAISERROR('Invoice already exists for this booking.',16,1);
        RETURN;
    END;

    SELECT
        @base_fare = TRY_CAST(setting_value AS DECIMAL(10,2))
    FROM system_settings
    WHERE setting_key = 'DEFAULT_BASE_FARE';

    IF @base_fare IS NULL
    BEGIN
        RAISERROR('DEFAULT_BASE_FARE is not configured.',16,1);
        RETURN;
    END;

    SET @taxes = ROUND(@base_fare * 0.15,2);
    SET @extras = 0;

    INSERT INTO invoices
    (
        booking_id,
        flight_instance_id,
        base_fare,
        taxes,
        extras
    )
    VALUES
    (
        @booking_id,
        @flight_instance_id,
        @base_fare,
        @taxes,
        @extras
    );
END;
