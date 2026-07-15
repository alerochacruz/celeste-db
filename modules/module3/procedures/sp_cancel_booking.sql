SET QUOTED_IDENTIFIER ON;
GO
CREATE OR ALTER PROCEDURE sp_cancel_booking
    @booking_id INT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @current_status_code  VARCHAR(20);
    DECLARE @flight_instance_id   INT;
    DECLARE @is_manifest_closed   BIT;
    DECLARE @cancelled_status_id  INT;

    -- Validar existencia y traer datos del booking
    SELECT
        @current_status_code = bs.code,
        @flight_instance_id  = b.flight_instance_id
    FROM bookings b
    JOIN booking_statuses bs ON b.status_id = bs.id
    WHERE b.id = @booking_id;

    IF @flight_instance_id IS NULL
    BEGIN
        RAISERROR('sp_cancel_booking: la reserva #%d no existe.', 16, 1, @booking_id);
        RETURN;
    END;

    -- Validar que no esté ya cancelada
    IF @current_status_code = 'CANCELLED'
    BEGIN
        RAISERROR('sp_cancel_booking: la reserva #%d ya se encuentra cancelada.', 16, 1, @booking_id);
        RETURN;
    END;

    -- Validar que el vuelo no esté cerrado
    SELECT @is_manifest_closed = is_manifest_closed
    FROM flight_instances
    WHERE id = @flight_instance_id;

    IF @is_manifest_closed = 1
    BEGIN
        RAISERROR('sp_cancel_booking: no se puede cancelar reserva del vuelo #%d, el manifiesto ya fue cerrado.', 16, 1, @flight_instance_id);
        RETURN;
    END;

    -- Buscar status_id de CANCELLED
    SELECT @cancelled_status_id = id
    FROM booking_statuses
    WHERE code = 'CANCELLED';

    IF @cancelled_status_id IS NULL
    BEGIN
        RAISERROR('sp_cancel_booking: no se encontro el estado CANCELLED en el catalogo.', 16, 1);
        RETURN;
    END;

    -- Actualizar estado
    UPDATE bookings
    SET status_id = @cancelled_status_id
    WHERE id = @booking_id;

    -- *************************************************************************
    -- Módulo Facturación
    -- Cancelar factura asociada
    -- *************************************************************************
    EXEC sp_cancel_invoice
    @booking_id = @booking_id;
    -- *************************************************************************

    -- Devolver resumen
    SELECT
        b.id                                    AS reserva_id,
        b.booking_code                          AS codigo_reserva,
        p.first_name + ' ' + p.last_name        AS titular,
        b.flight_instance_id                    AS vuelo_id,
        bs.code                                 AS estado_nuevo,
        GETDATE()                               AS cancelada_a
    FROM bookings b
    JOIN passengers p        ON b.booker_passenger_id = p.id
    JOIN booking_statuses bs ON b.status_id           = bs.id
    WHERE b.id = @booking_id;
END;
GO
