-- Datos de la reserva familiar
-- -----------------------------------------------------------------------------
-- Titular:     Ana García     (DNI 40111222)
-- Vuelo:       QV855 VTE→CSX  (flight_instances.id: 161, 2026-11-02)
-- Asientos:    12A economy    - Ana García
--              12B economy    - Bruno García
--              12C economy    - Clara Vega
--
-- Total:       USD 450.00
-- Estado inicial: PENDING
--
-- Resultados:
--   - 1 booking nuevo en estado PENDING
--   - 3 seat_assignments creados con clase ECONOMY

-- *****************************************************************************
-- 1. Recuperar IDs de los pasajeros por documento.
-- *****************************************************************************
DECLARE @ana_id   INT = (SELECT id FROM passengers WHERE document_type = 'DNI' AND document_number = '40111222');
DECLARE @bruno_id INT = (SELECT id FROM passengers WHERE document_type = 'DNI' AND document_number = '45222333');
DECLARE @clara_id INT = (SELECT id FROM passengers WHERE document_type = 'DNI' AND document_number = '42333444');

-- *****************************************************************************
-- 2. Preparar lista de asientos con parámetros definidos en tabla
-- *****************************************************************************
DECLARE @seats dbo.booking_seat_input;

INSERT INTO @seats (passenger_id, seat_number, class) VALUES
    (@ana_id,   '12A', 'ECONOMY'),  -- Ana García (titular)
    (@bruno_id, '12B', 'ECONOMY'),  -- Bruno García
    (@clara_id, '12C', 'ECONOMY');  -- Clara Vega

-- *****************************************************************************
-- 3. Ejecutar la creación de la reserva
-- *****************************************************************************
EXEC sp_create_booking
    @booker_passenger_id = @ana_id,
    @flight_instance_id  = 161,      -- QV855 del 2026-11-02
    @total_amount        = 450.00,
    @seats               = @seats;