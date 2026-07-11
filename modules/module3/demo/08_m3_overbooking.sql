-- =============================================================================
-- Demo del rechazo por overbooking en clase ECONOMY
-- =============================================================================
-- Vuelo:        QV855 VTE→CSX (flight_instances.id: 161)
-- Aeronave:     A320-777 (160 asientos economy nominales)
-- Overbooking:  5% (parametrizado en system_settings)
-- Máximo permitido: 160 + FLOOR(160 × 0.05) = 168 asientos
--
-- Precondiciones:
--   - Script 08_m3_overbooking_setup ejecutado (168 reservas activas cargadas)
--
-- Postcondiciones:
--   - Ninguna: la reserva rebota, rollback total del intento
-- =============================================================================

DECLARE @extra_id INT = (SELECT id FROM passengers WHERE document_number = 'DEMO169');
DECLARE @seats dbo.booking_seat_input;

INSERT INTO @seats (passenger_id, seat_number, class) VALUES
    (@extra_id, '99A', 'ECONOMY');

EXEC sp_create_booking
    @booker_passenger_id = @extra_id,
    @flight_instance_id  = 161,
    @total_amount        = 150.00,
    @seats               = @seats;