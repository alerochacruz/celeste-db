-- =============================================================================
-- Setup previo a la demo del rechazo por overbooking (script 09).
-- NO se muestra en el video. Se ejecuta antes de grabar para dejar el vuelo
-- 161 con exactamente 168 reservas activas de clase ECONOMY (el máximo
-- permitido por el trigger tr_seat_assignment_overbooking).
-- =============================================================================
--
-- Estrategia:
--   1. Registrar 170 pasajeros dummy con documentos 'DEMO001' a 'DEMO170'.
--   2. Sembrar 168 bookings (uno por pasajero) en estado CONFIRMED,
--      cada uno con un seat_assignment en clase ECONOMY.
--   3. El pasajero DEMO169 queda libre para el intento del script 09.
--
-- Justificación técnica del INSERT directo (bypass de sp_create_booking):
--   - El SP dispara el trigger de overbooking en cada llamada; con 168
--     llamadas, esto sería costoso.
--   - Con INSERT directo, el trigger dispara una sola vez con las 168 filas
--     en la tabla `inserted`, equivalente en resultado y mucho más eficiente.
--
-- Precondiciones:
--   - Base recién desplegada + scripts 01, 02 y 03 ejecutados
--   - Ningún seat_assignment previo en clase ECONOMY del vuelo 161
-- =============================================================================


-- *****************************************************************************
-- 1. Registrar 170 pasajeros dummy (idempotente).
-- *****************************************************************************
DECLARE @i INT = 1;
DECLARE @doc VARCHAR(20);

WHILE @i <= 170
BEGIN
    SET @doc = 'DEMO' + RIGHT('000' + CAST(@i AS VARCHAR(3)), 3);

    IF NOT EXISTS (SELECT 1 FROM passengers WHERE document_number = @doc)
    BEGIN
        INSERT INTO passengers (
            document_type, document_number,
            first_name, last_name,
            birth_date, nationality_code
        )
        VALUES (
            'DNI', @doc,
            'PaxDemo', CAST(@i AS VARCHAR(3)),
            '1990-01-01', 'AR'
        );
    END;

    SET @i = @i + 1;
END;


-- *****************************************************************************
-- 2. Sembrar 165 bookings CONFIRMED con sus 165 seat_assignments.
-- *****************************************************************************
DECLARE @confirmed_status_id INT = (SELECT id FROM booking_statuses WHERE code = 'CONFIRMED');

DECLARE @seed_i INT = 1;
DECLARE @booking_id INT;
DECLARE @seat_number VARCHAR(5);
DECLARE @passenger_id INT;

WHILE @seed_i <= 165
BEGIN
    -- Recuperar el passenger_id del DEMO correspondiente
    SELECT @passenger_id = id
    FROM passengers
    WHERE document_number = 'DEMO' + RIGHT('000' + CAST(@seed_i AS VARCHAR(3)), 3);

    -- Crear un booking por pasajero (evita el UQ passenger_per_booking)
    INSERT INTO bookings (
        booking_code, booker_passenger_id, flight_instance_id,
        status_id, booking_date, total_amount
    )
    VALUES (
        'SEED' + RIGHT('0000' + CAST(@seed_i AS VARCHAR(4)), 4),
        @passenger_id,
        161,
        @confirmed_status_id,
        GETDATE(),
        150.00
    );

    SET @booking_id = SCOPE_IDENTITY();

    -- Numeración de asientos: 5 asientos por fila (A-E), 34 filas necesarias
    SET @seat_number = CAST(((@seed_i - 1) / 5) + 20 AS VARCHAR(3))
                 + CHAR(65 + ((@seed_i - 1) % 5));

    INSERT INTO seat_assignments (
        passenger_id, booking_id, flight_instance_id, seat_number, class
    )
    VALUES (
        @passenger_id, @booking_id, 161, @seat_number, 'ECONOMY'
    );

    SET @seed_i = @seed_i + 1;
END;

PRINT '==============================================================';
PRINT 'Setup completo:';
PRINT '  - 170 pasajeros DEMO creados';
PRINT '  - 168 bookings CONFIRMED en vuelo 161';
PRINT '  - 168 seat_assignments clase ECONOMY (maximo permitido)';
PRINT '  - Pasajero DEMO169 disponible para el intento del script 09';
PRINT '==============================================================';