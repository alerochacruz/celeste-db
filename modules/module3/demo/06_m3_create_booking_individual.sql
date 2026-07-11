-- Datos de la reserva individual

-- -----------------------------------------------------------------------------
-- Titular:     Diego Ruiz     (DNI 38444555)
-- Vuelo:       QV856 CSX→VTE  (flight_instances.id: 162, 2026-11-06)
-- Asiento:     18F economy
-- Total:       USD 175.00
-- Estado:      PENDING (así se crea siempre desde sp_create_booking)
--
-- Propósito:  Preparar una reserva para demostrar la cancelación en el script 07.
--
-- Precondiciones:
--   - Script 03 ejecutado (pasajero Diego Ruiz registrado)
--
-- Resultado esperado:
--   - 1 booking nuevo en estado PENDING
--   - 1 seat_assignment creado

-- *****************************************************************************
-- 1. Recuperar el ID del titular.
-- *****************************************************************************
DECLARE @diego_id INT = (SELECT id FROM passengers WHERE document_type = 'DNI' AND document_number = '38444555');

-- *****************************************************************************
-- 2. Preparar lista de asientos.
-- *****************************************************************************
DECLARE @seats dbo.booking_seat_input;

INSERT INTO @seats (passenger_id, seat_number, class) VALUES
    (@diego_id, '18F', 'ECONOMY');

-- *****************************************************************************
-- 3. Ejecutar la creación de la reserva.
-- *****************************************************************************
EXEC sp_create_booking
    @booker_passenger_id = @diego_id,
    @flight_instance_id  = 162,      -- QV856 del 2026-11-06
    @total_amount        = 175.00,
    @seats               = @seats;