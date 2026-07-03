-- Datos de la operación
-- -----------------------------------------------------------------------------
-- Reserva:     Diego Ruiz (DNI 38444555)
-- Transición:  PENDING → CANCELLED

-- Efecto colateral relevante:
--   La reserva sale del cómputo de overbooking del vuelo 162 (el trigger de
--   overbooking cuenta solo reservas en estado PENDING o CONFIRMED). Es decir,
--   cancelar libera capacidad.

-- Postcondiciones:
--   - Reserva de Diego pasa a estado CANCELLED
--   - El seat_assignment 18F queda registrado pero deja de contar
--     para overbooking y libera esa posición para nuevas reservas
--     (validado en el trigger de overbooking al filtrar por estados activos)

-- *****************************************************************************
-- 1. Recuperar el booking_id creado en el script anterior.
-- *****************************************************************************
DECLARE @booking_id INT = (
    SELECT TOP 1 b.id
    FROM bookings b
    JOIN passengers p ON b.booker_passenger_id = p.id
    WHERE p.document_type   = 'DNI'
      AND p.document_number = '38444555'
    ORDER BY b.id DESC
);

-- *****************************************************************************
-- 2. Cancelar la reserva.
-- *****************************************************************************
EXEC sp_cancel_booking @booking_id = @booking_id;