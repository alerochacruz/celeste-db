SET QUOTED_IDENTIFIER ON;
GO
CREATE OR ALTER PROCEDURE sp_board_passenger
    @boarding_pass_code VARCHAR(20),
    @flight_instance_id INT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @check_in_id    INT;
    DECLARE @current_status VARCHAR(20);
    DECLARE @passenger_name VARCHAR(105);
    DECLARE @seat_number    VARCHAR(5);

    SELECT
        @check_in_id     = ci.id,
        @current_status  = ci.status,
        @passenger_name  = p.first_name + ' ' + p.last_name,
        @seat_number     = sa.seat_number
    FROM check_ins ci
    JOIN passengers       p  ON ci.passenger_id       = p.id
    JOIN seat_assignments sa ON ci.seat_assignment_id = sa.id
    WHERE ci.boarding_pass_code = @boarding_pass_code
      AND ci.flight_instance_id = @flight_instance_id;

    IF @check_in_id IS NULL
    BEGIN
        RAISERROR('Abordaje fallido: tarjeta "%s" no valida para el vuelo #%d.', 16, 1, @boarding_pass_code, @flight_instance_id);
        RETURN;
    END;

    IF @current_status = 'BOARDED'
    BEGIN
        RAISERROR('Abordaje fallido: el pasajero ya abordo (boarding pass: %s).', 16, 1, @boarding_pass_code);
        RETURN;
    END;

    IF @current_status = 'NO_SHOW'
    BEGIN
        RAISERROR('Abordaje fallido: el pasajero fue marcado NO_SHOW (boarding pass: %s).', 16, 1, @boarding_pass_code);
        RETURN;
    END;

    UPDATE check_ins
    SET    status = 'BOARDED'
    WHERE  id = @check_in_id;

    UPDATE baggage_tags
    SET    status = 'LOADED'
    WHERE  check_in_id = @check_in_id
      AND  bag_type    = 'HOLD'
      AND  status      = 'TAGGED';

    SELECT
        @passenger_name     AS pasajero,
        @seat_number        AS asiento,
        @boarding_pass_code AS boarding_pass,
        'BOARDED'           AS nuevo_estado,
        GETDATE()           AS hora_abordaje;
END;
