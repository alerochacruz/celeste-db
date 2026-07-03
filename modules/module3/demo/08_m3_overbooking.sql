-- =============================================================================
-- ⚠️  IMPORTANTE
-- Este script depende del trigger tr_seat_assignment_overbooking, que aún NO
-- está implementado al momento de este commit.
--
-- Comportamiento actual  (sin el trigger): la reserva se creará exitosamente,
--     dejando el vuelo en estado de sobre-capacidad en clase business.
-- Comportamiento esperado (con el trigger): la reserva rebotará porque supera
--     la capacidad de business + margen de overbooking.
--
-- Este script queda armado para funcionar automáticamente en cuanto el trigger
-- se agregue al deploy. No requerirá cambios.
-- =============================================================================

-- Datos del intento de reserva
-- -----------------------------------------------------------------------------
-- Vuelo:        QV855 VTE→CSX  (flight_instances.id: 161)
-- Aeronave:     A320-777 (8 asientos business, 160 economy)
-- Overbooking:  5% (parametrizado en system_settings) → FLOOR(8 × 0.05) = 0
-- Máximo permitido en business: 8 asientos
-- Asientos intentados: 9 asientos business (uno por encima del máximo)
--
-- Resultado esperado con el trigger activo:
--   Error del trigger tr_seat_assignment_overbooking
--   Rollback de toda la reserva (ningún seat_assignment persiste)
--
-- Precondiciones:
--   - Base recién desplegada + scripts 01 a 07 ejecutados
--   - Ningún seat_assignment previo en clase business del vuelo 161

-- *****************************************************************************
-- 1. Recuperar los IDs de los pasajeros (todos ya registrados: seeds + Elena).
-- *****************************************************************************
DECLARE @elena_id  INT = (SELECT id FROM passengers WHERE document_type = 'DNI'      AND document_number = '41555666');
DECLARE @martin_id INT = (SELECT id FROM passengers WHERE document_type = 'DNI'      AND document_number = '32145678');
DECLARE @lucia_id  INT = (SELECT id FROM passengers WHERE document_type = 'DNI'      AND document_number = '28456789');
DECLARE @sofia_id  INT = (SELECT id FROM passengers WHERE document_type = 'PASSPORT' AND document_number = 'AB1234567');
DECLARE @joao_id   INT = (SELECT id FROM passengers WHERE document_type = 'PASSPORT' AND document_number = 'CD9876543');
DECLARE @emma_id   INT = (SELECT id FROM passengers WHERE document_type = 'PASSPORT' AND document_number = 'EF5555555');
DECLARE @pierre_id INT = (SELECT id FROM passengers WHERE document_type = 'PASSPORT' AND document_number = 'GH7777777');
DECLARE @camila_id INT = (SELECT id FROM passengers WHERE document_type = 'DNI'      AND document_number = '38999111');
DECLARE @yuki_id   INT = (SELECT id FROM passengers WHERE document_type = 'PASSPORT' AND document_number = 'IJ2468013');

-- *****************************************************************************
-- 2. Preparar lista de 9 asientos business (uno por encima del máximo).
-- *****************************************************************************
DECLARE @seats dbo.booking_seat_input;

INSERT INTO @seats (passenger_id, seat_number, class) VALUES
    (@elena_id,  '1A', 'BUSINESS'),
    (@martin_id, '1B', 'BUSINESS'),
    (@lucia_id,  '1C', 'BUSINESS'),
    (@sofia_id,  '1D', 'BUSINESS'),
    (@joao_id,   '1E', 'BUSINESS'),
    (@emma_id,   '1F', 'BUSINESS'),
    (@pierre_id, '2A', 'BUSINESS'),
    (@camila_id, '2B', 'BUSINESS'),
    (@yuki_id,   '2C', 'BUSINESS');  -- 9no asiento: dispara el trigger

-- *****************************************************************************
-- 3. Ejecutar el intento de reserva (debe fallar con el trigger activo).
-- *****************************************************************************
EXEC sp_create_booking
    @booker_passenger_id = @elena_id,
    @flight_instance_id  = 161,
    @total_amount        = 3600.00,
    @seats               = @seats;