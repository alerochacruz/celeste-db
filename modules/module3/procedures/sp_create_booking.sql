SET QUOTED_IDENTIFIER ON;
GO
CREATE OR ALTER PROCEDURE sp_create_booking
    @booker_passenger_id INT,
    @flight_instance_id  INT,
    @total_amount        DECIMAL(10, 2) = NULL,
    @seats               dbo.booking_seat_input READONLY
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @is_manifest_closed BIT;
    DECLARE @flight_status      VARCHAR(20);
    DECLARE @pending_status_id  INT;
    DECLARE @seat_count         INT;
    DECLARE @invalid_passengers INT;
    DECLARE @duplicate_seats    INT;
    DECLARE @booking_code       VARCHAR(8);
    DECLARE @booking_id         INT;

    -- ============================================================
    -- Validaciones previas (fuera de transacción)
    -- ============================================================

    -- Validar que el flight_instance exista
    SELECT
        @is_manifest_closed = is_manifest_closed,
        @flight_status      = status_code
    FROM flight_instances
    WHERE id = @flight_instance_id;

    IF @is_manifest_closed IS NULL
    BEGIN
        RAISERROR('sp_create_booking: el vuelo #%d no existe.', 16, 1, @flight_instance_id);
        RETURN;
    END;

    IF @is_manifest_closed = 1
    BEGIN
        RAISERROR('sp_create_booking: el vuelo #%d ya cerro su manifiesto, no acepta reservas nuevas.', 16, 1, @flight_instance_id);
        RETURN;
    END;

    IF @flight_status IN ('CANCELLED', 'COMPLETED')
    BEGIN
        RAISERROR('sp_create_booking: el vuelo #%d esta en estado %s, no acepta reservas.', 16, 1, @flight_instance_id, @flight_status);
        RETURN;
    END;

    -- Validar que el titular exista
    IF NOT EXISTS (SELECT 1 FROM passengers WHERE id = @booker_passenger_id)
    BEGIN
        RAISERROR('sp_create_booking: el pasajero titular #%d no existe.', 16, 1, @booker_passenger_id);
        RETURN;
    END;

    -- Validar que haya al menos un asiento
    SELECT @seat_count = COUNT(*) FROM @seats;

    IF @seat_count = 0
    BEGIN
        RAISERROR('sp_create_booking: debe indicar al menos un asiento.', 16, 1);
        RETURN;
    END;

    -- Validar que todos los pasajeros de la lista existan
    SELECT @invalid_passengers = COUNT(*)
    FROM @seats s
    WHERE NOT EXISTS (SELECT 1 FROM passengers p WHERE p.id = s.passenger_id);

    IF @invalid_passengers > 0
    BEGIN
        RAISERROR('sp_create_booking: %d pasajero(s) de la lista no existen en la base.', 16, 1, @invalid_passengers);
        RETURN;
    END;

    -- Validar que no haya asientos duplicados dentro de la misma reserva
    SELECT @duplicate_seats = COUNT(*)
    FROM (
        SELECT seat_number
        FROM @seats
        GROUP BY seat_number
        HAVING COUNT(*) > 1
    ) d;

    IF @duplicate_seats > 0
    BEGIN
        RAISERROR('sp_create_booking: la lista de asientos contiene numeros duplicados.', 16, 1);
        RETURN;
    END;

    -- Buscar status_id de PENDING
    SELECT @pending_status_id = id
    FROM booking_statuses
    WHERE code = 'PENDING';

    IF @pending_status_id IS NULL
    BEGIN
        RAISERROR('sp_create_booking: no se encontro el estado PENDING en el catalogo.', 16, 1);
        RETURN;
    END;

    -- Generar booking_code unico (patron NEWID)
    SET @booking_code = UPPER(SUBSTRING(REPLACE(CONVERT(VARCHAR(36), NEWID()), '-', ''), 1, 8));
    WHILE EXISTS (SELECT 1 FROM bookings WHERE booking_code = @booking_code)
        SET @booking_code = UPPER(SUBSTRING(REPLACE(CONVERT(VARCHAR(36), NEWID()), '-', ''), 1, 8));

    -- ============================================================
    -- Escritura transaccional
    -- ============================================================
    BEGIN TRY
        BEGIN TRANSACTION;

            -- INSERT del booking
            INSERT INTO bookings (
                booking_code, booker_passenger_id, flight_instance_id,
                status_id, booking_date, total_amount
            )
            VALUES (
                @booking_code, @booker_passenger_id, @flight_instance_id,
                @pending_status_id, GETDATE(), @total_amount
            );

            SET @booking_id = SCOPE_IDENTITY();

            -- INSERT de todos los seat_assignments desde el TVP
            -- Cada fila dispara los triggers de consistencia y overbooking
            INSERT INTO seat_assignments (
                passenger_id, booking_id, flight_instance_id,
                seat_number, class
            )
            SELECT
                s.passenger_id, @booking_id, @flight_instance_id,
                s.seat_number, s.class
            FROM @seats s;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        -- Re-lanzar el error original
        DECLARE @err_msg NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @err_sev INT = ERROR_SEVERITY();
        DECLARE @err_state INT = ERROR_STATE();
        RAISERROR('sp_create_booking fallo: %s', @err_sev, @err_state, @err_msg);
        RETURN;
    END CATCH;

    -- ============================================================
    -- Devolver resumen
    -- ============================================================
    SELECT
        b.id                              AS reserva_id,
        b.booking_code                    AS codigo_reserva,
        p.first_name + ' ' + p.last_name  AS titular,
        b.flight_instance_id              AS vuelo_id,
        bs.code                           AS estado,
        b.booking_date                    AS fecha_reserva,
        b.total_amount                    AS monto_total,
        (SELECT COUNT(*) FROM seat_assignments WHERE booking_id = b.id) AS pasajeros_incluidos
    FROM bookings b
    JOIN passengers p        ON b.booker_passenger_id = p.id
    JOIN booking_statuses bs ON b.status_id           = bs.id
    WHERE b.id = @booking_id;

    -- Devolver detalle de asientos asignados
    SELECT
        sa.id                            AS seat_assignment_id,
        pas.first_name + ' ' + pas.last_name AS pasajero,
        sa.seat_number                   AS asiento,
        sa.class                         AS clase,
        sa.assigned_at                   AS asignado_a
    FROM seat_assignments sa
    JOIN passengers pas ON sa.passenger_id = pas.id
    WHERE sa.booking_id = @booking_id
    ORDER BY sa.seat_number;
END;
GO