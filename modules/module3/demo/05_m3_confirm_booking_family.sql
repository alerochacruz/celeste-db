-- Datos de la operación
-- -----------------------------------------------------------------------------
-- Reserva:     Ana García (DNI 40111222)
-- Transición:  PENDING → CONFIRMED
--
-- Resultado:
--   - Reserva de la familia pasa a estado CONFIRMED
--   - A partir de este punto la reserva ya no puede confirmarse otra vez

-- *****************************************************************************
-- 1. Recuperar el booking_id de la reserva de Anna.
-- *****************************************************************************
DECLARE @booking_id INT = (
    SELECT TOP 1 b.id
    FROM bookings b
    JOIN passengers p ON b.booker_passenger_id = p.id
    WHERE p.document_type   = 'DNI'
      AND p.document_number = '40111222'
    ORDER BY b.id DESC
);

-- *****************************************************************************
-- 2. Confirmar la reserva.
-- *****************************************************************************
EXEC sp_confirm_booking @booking_id = @booking_id;