GO

CREATE OR ALTER TRIGGER tr_seat_assignment_consistency
    ON seat_assignments
    AFTER INSERT, UPDATE
    AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (SELECT 1
               FROM inserted i
                        JOIN bookings b ON b.id = i.booking_id
               WHERE i.flight_instance_id != b.flight_instance_id )
        BEGIN
            THROW 50001, 'La asignacion de asiento se hizo en un vuelo diferente al de su reserva', 1;
        END
END

GO