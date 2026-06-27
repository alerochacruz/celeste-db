SET QUOTED_IDENTIFIER ON;
GO
CREATE OR ALTER PROCEDURE sp_check_in_passenger
    @booking_id INT,
    @channel    VARCHAR(20) = 'COUNTER'
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @flight_instance_id  INT;
    DECLARE @passenger_id        INT;
    DECLARE @booking_status_code VARCHAR(20);
    DECLARE @flight_status       VARCHAR(20);
    DECLARE @seat_assignment_id  INT;
    DECLARE @class               VARCHAR(10);
    DECLARE @seat_number         VARCHAR(5);
    DECLARE @boarding_group_id   INT;
    DECLARE @boarding_pass_code  VARCHAR(20);
    DECLARE @check_in_id         INT;

    SELECT
        @flight_instance_id  = b.flight_instance_id,
        @passenger_id        = b.booker_passenger_id,
        @booking_status_code = bs.code
    FROM bookings b
    JOIN booking_statuses bs ON b.status_id = bs.id
    WHERE b.id = @booking_id;

    IF @flight_instance_id IS NULL
    BEGIN
        RAISERROR('Check-in fallido: la reserva #%d no existe.', 16, 1, @booking_id);
        RETURN;
    END;

    IF @booking_status_code <> 'CONFIRMED'
    BEGIN
        RAISERROR('Check-in fallido: la reserva #%d no esta CONFIRMED (estado: %s).', 16, 1, @booking_id, @booking_status_code);
        RETURN;
    END;

    IF EXISTS (SELECT 1 FROM check_ins WHERE booking_id = @booking_id)
    BEGIN
        RAISERROR('Check-in fallido: ya existe un check-in para la reserva #%d.', 16, 1, @booking_id);
        RETURN;
    END;

    SELECT @flight_status = status_code
    FROM flight_instances WHERE id = @flight_instance_id;

    IF @flight_status NOT IN ('SCHEDULED', 'DELAYED')
    BEGIN
        RAISERROR('Check-in fallido: el vuelo no acepta check-in en estado %s.', 16, 1, @flight_status);
        RETURN;
    END;

    SELECT
        @seat_assignment_id = sa.id,
        @seat_number        = sa.seat_number,
        @class              = sa.class
    FROM seat_assignments sa
    WHERE sa.booking_id = @booking_id AND sa.flight_instance_id = @flight_instance_id;

    IF @seat_assignment_id IS NULL
    BEGIN
        RAISERROR('Check-in fallido: no hay asiento asignado para la reserva #%d.', 16, 1, @booking_id);
        RETURN;
    END;

    SELECT @boarding_group_id = id
    FROM boarding_groups
    WHERE flight_instance_id = @flight_instance_id
      AND group_number = CASE WHEN @class = 'BUSINESS' THEN 1 ELSE 2 END;

    IF @boarding_group_id IS NULL
    BEGIN
        RAISERROR('Check-in fallido: no hay grupos de abordaje para el vuelo #%d.', 16, 1, @flight_instance_id);
        RETURN;
    END;

    SET @boarding_pass_code = 'BP-' + UPPER(SUBSTRING(REPLACE(CONVERT(VARCHAR(36), NEWID()), '-', ''), 1, 8));
    WHILE EXISTS (SELECT 1 FROM check_ins WHERE boarding_pass_code = @boarding_pass_code)
        SET @boarding_pass_code = 'BP-' + UPPER(SUBSTRING(REPLACE(CONVERT(VARCHAR(36), NEWID()), '-', ''), 1, 8));

    INSERT INTO check_ins (
        booking_id, flight_instance_id, passenger_id,
        seat_assignment_id, boarding_group_id,
        channel, boarding_pass_code, status
    )
    VALUES (
        @booking_id, @flight_instance_id, @passenger_id,
        @seat_assignment_id, @boarding_group_id,
        @channel, @boarding_pass_code, 'CHECKED_IN'
    );

    SET @check_in_id = SCOPE_IDENTITY();

    SELECT
        ci.id                             AS check_in_id,
        ci.boarding_pass_code,
        p.first_name + ' ' + p.last_name AS pasajero,
        sa.seat_number                    AS asiento,
        sa.class                          AS clase,
        bg.group_name                     AS grupo_abordaje,
        ci.checked_in_at,
        ci.channel                        AS canal
    FROM check_ins ci
    JOIN passengers       p  ON ci.passenger_id       = p.id
    JOIN seat_assignments sa ON ci.seat_assignment_id = sa.id
    JOIN boarding_groups  bg ON ci.boarding_group_id  = bg.id
    WHERE ci.id = @check_in_id;
END;
