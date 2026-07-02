
-- Pruebas a realizar para el M5: Check-in y Operaciones

USE celeste;
GO

-- Prueba 1: Verificar que las tablas de M5 existen y tienen datos


PRINT '-- Tabla boarding_groups:';
SELECT
    bg.id,
    bg.flight_instance_id,
    bg.group_number,
    bg.group_name,
    bg.boarding_order
FROM boarding_groups bg
ORDER BY bg.flight_instance_id, bg.group_number;

PRINT '-- Tabla check_ins:';
SELECT
    ci.id,
    ci.booking_id,
    p.first_name + ' ' + p.last_name   AS pasajero,
    ci.flight_instance_id,
    sa.seat_number                      AS asiento,
    sa.class                            AS clase,
    ci.boarding_pass_code,
    ci.channel,
    ci.status
FROM check_ins ci
JOIN passengers       p  ON ci.passenger_id       = p.id
JOIN seat_assignments sa ON ci.seat_assignment_id = sa.id
ORDER BY ci.id;

PRINT '-- Tabla baggage_tags:';
SELECT
    bt.id,
    bt.check_in_id,
    bt.tag_code,
    bt.weight_kg,
    bt.bag_type,
    bt.status
FROM baggage_tags bt
ORDER BY bt.check_in_id, bt.id;
GO


-- Prueba 2: sp_check_in_passenger — casos de éxito y error

-- TEST 2.1: Check-in exitoso (booking 3 → João, vuelo 2)
-- NOTA: el seed ya insertó este check-in, así que este test
-- mostrará el error esperado de duplicado.
-- Para ver el éxito, primero borrar el registro del seed:
--   DELETE FROM check_ins WHERE booking_id = 3;
-- Luego ejecutar:
PRINT '-- TEST 2.1: Check-in de João (booking 3) - ya existe en seed, debe mostrar error de duplicado:';
BEGIN TRY
    EXEC sp_check_in_passenger
        @booking_id = 3,
        @channel    = 'WEB';
    PRINT 'Check-in realizado (solo si se borró el seed previamente).';
END TRY
BEGIN CATCH
    PRINT 'Resultado: ' + ERROR_MESSAGE();
END CATCH;
GO

-- TEST 2.2: Booking que no existe
PRINT '-- TEST 2.2: Booking inexistente (id=999) - debe fallar:';
BEGIN TRY
    EXEC sp_check_in_passenger @booking_id = 999;
END TRY
BEGIN CATCH
    PRINT 'OK - Error esperado: ' + ERROR_MESSAGE();
END CATCH;
GO

-- TEST 2.3: Booking CANCELLED (booking 6 → Camila, status CANCELLED)
PRINT '-- TEST 2.3: Booking CANCELLED (id=6, Camila) - debe fallar:';
BEGIN TRY
    EXEC sp_check_in_passenger @booking_id = 6;
END TRY
BEGIN CATCH
    PRINT 'OK - Error esperado: ' + ERROR_MESSAGE();
END CATCH;
GO

-- TEST 2.4: Booking PENDING (booking 4 → Emma, status PENDING)
PRINT '-- TEST 2.4: Booking PENDING (id=4, Emma) - debe fallar:';
BEGIN TRY
    EXEC sp_check_in_passenger @booking_id = 4;
END TRY
BEGIN CATCH
    PRINT 'OK - Error esperado: ' + ERROR_MESSAGE();
END CATCH;
GO

-- TEST 2.5: Booking NO_SHOW (booking 8 → Liam, status NO_SHOW)
PRINT '-- TEST 2.5: Booking NO_SHOW (id=8, Liam) - debe fallar:';
BEGIN TRY
    EXEC sp_check_in_passenger @booking_id = 8;
END TRY
BEGIN CATCH
    PRINT 'OK - Error esperado: ' + ERROR_MESSAGE();
END CATCH;
GO



-- Prueba 3: sp_board_passenger — casos de éxito y error


-- TEST 3.1: Abordar a Yuki (estaba CHECKED_IN en el seed → debe cambiar a BOARDED)
PRINT '-- TEST 3.1: Abordar a Yuki (BP-YUKI0007, vuelo 6) - debe ser EXITOSO:';
EXEC sp_board_passenger
    @boarding_pass_code = 'BP-YUKI0007',
    @flight_instance_id = 6;
GO

-- TEST 3.2: Intentar abordar a Martín que ya está BOARDED → debe fallar
PRINT '-- TEST 3.2: Abordar a Martín que ya abordó (BP-MARTIN01) - debe fallar:';
BEGIN TRY
    EXEC sp_board_passenger
        @boarding_pass_code = 'BP-MARTIN01',
        @flight_instance_id = 1;
END TRY
BEGIN CATCH
    PRINT 'OK - Error esperado: ' + ERROR_MESSAGE();
END CATCH;
GO

-- TEST 3.3: Intentar abordar a Sofia que es NO_SHOW → debe fallar
PRINT '-- TEST 3.3: Abordar a Sofia que es NO_SHOW (BP-SOFIA002) - debe fallar:';
BEGIN TRY
    EXEC sp_board_passenger
        @boarding_pass_code = 'BP-SOFIA002',
        @flight_instance_id = 1;
END TRY
BEGIN CATCH
    PRINT 'OK - Error esperado: ' + ERROR_MESSAGE();
END CATCH;
GO

-- TEST 3.4: Tarjeta de embarque inexistente → debe fallar
PRINT '-- TEST 3.4: Tarjeta inexistente (BP-INVALIDA) - debe fallar:';
BEGIN TRY
    EXEC sp_board_passenger
        @boarding_pass_code = 'BP-INVALIDA',
        @flight_instance_id = 1;
END TRY
BEGIN CATCH
    PRINT 'OK - Error esperado: ' + ERROR_MESSAGE();
END CATCH;
GO

-- TEST 3.5: Tarjeta válida pero vuelo incorrecto → debe fallar
PRINT '-- TEST 3.5: Tarjeta de Martín (vuelo 1) usada en vuelo 2 - debe fallar:';
BEGIN TRY
    EXEC sp_board_passenger
        @boarding_pass_code = 'BP-MARTIN01',
        @flight_instance_id = 2;
END TRY
BEGIN CATCH
    PRINT 'OK - Error esperado: ' + ERROR_MESSAGE();
END CATCH;
GO


-- Prueba 4: sp_cerrar_vuelo — casos de éxito y error



-- TEST 4.1: Cerrar vuelo 1 (tiene Martín BOARDED y Sofia NO_SHOW)
PRINT '-- TEST 4.1: Cerrar vuelo 1 - debe ser EXITOSO:';
EXEC sp_cerrar_vuelo @flight_id = 1;
GO

-- TEST 4.2: Intentar cerrar vuelo 1 de nuevo → debe fallar
PRINT '-- TEST 4.2: Cerrar vuelo 1 de nuevo - debe fallar:';
BEGIN TRY
    EXEC sp_cerrar_vuelo @flight_id = 1;
END TRY
BEGIN CATCH
    PRINT 'OK - Error esperado: ' + ERROR_MESSAGE();
END CATCH;
GO

-- TEST 4.3: Cerrar vuelo inexistente → debe fallar
PRINT '-- TEST 4.3: Cerrar vuelo inexistente (id=999) - debe fallar:';
BEGIN TRY
    EXEC sp_cerrar_vuelo @flight_id = 999;
END TRY
BEGIN CATCH
    PRINT 'OK - Error esperado: ' + ERROR_MESSAGE();
END CATCH;
GO

-- TEST 4.4: Cerrar vuelo 2 (tiene a João BOARDED)
PRINT '-- TEST 4.4: Cerrar vuelo 2 - debe ser EXITOSO:';
EXEC sp_cerrar_vuelo @flight_id = 2;
GO


-- Prueba 5: Vistas



-- TEST 5.1: vw_check_in_status — ver todos los vuelos con check-ins
PRINT '-- TEST 5.1: vw_check_in_status (vuelos con check-ins):';
SELECT *
FROM vw_check_in_status
WHERE total_checkins > 0
ORDER BY flight_instance_id;
GO

-- TEST 5.2: vw_manifiesto_detalle del vuelo 1
PRINT '-- TEST 5.2: vw_manifiesto_detalle del vuelo 1:';
SELECT *
FROM vw_manifiesto_detalle
WHERE flight_instance_id = 1
ORDER BY numero_grupo, asiento;
GO

-- TEST 5.3: vw_manifiesto_detalle del vuelo 2
PRINT '-- TEST 5.3: vw_manifiesto_detalle del vuelo 2:';
SELECT *
FROM vw_manifiesto_detalle
WHERE flight_instance_id = 2;
GO

-- TEST 5.4: vw_tasa_no_show — solo muestra vuelos cerrados
PRINT '-- TEST 5.4: vw_tasa_no_show (vuelos cerrados):';
SELECT *
FROM vw_tasa_no_show
ORDER BY fecha_vuelo;
GO


-- Prueba 6: Verificación final del estado de la base


-- Ver tabla flight_manifests generada
PRINT '-- Manifiestos generados:';
SELECT * FROM flight_manifests;
GO

-- Ver is_manifest_closed en flight_instances
PRINT '-- Estado de is_manifest_closed en flight_instances:';
SELECT
    fi.id,
    fs.flight_number,
    fi.flight_date,
    fi.status_code,
    fi.is_manifest_closed
FROM flight_instances fi
JOIN flight_schedules fs ON fi.flight_schedule_id = fs.id
WHERE fi.id IN (1, 2, 4, 6, 8, 9)
ORDER BY fi.id;
GO

-- Ver estado final de check_ins
PRINT '-- Estado final de todos los check_ins:';
SELECT
    ci.id,
    p.first_name + ' ' + p.last_name   AS pasajero,
    ci.flight_instance_id               AS vuelo,
    ci.boarding_pass_code,
    ci.status
FROM check_ins ci
JOIN passengers p ON ci.passenger_id = p.id
ORDER BY ci.flight_instance_id, ci.id;
GO

-- Ver estado final del equipaje
PRINT '-- Estado final del equipaje:';
SELECT
    bt.tag_code,
    p.first_name + ' ' + p.last_name   AS pasajero,
    bt.bag_type,
    bt.weight_kg,
    bt.status
FROM baggage_tags bt
JOIN check_ins ci ON bt.check_in_id  = ci.id
JOIN passengers p ON ci.passenger_id = p.id
ORDER BY ci.id, bt.id;
GO


PRINT 'Pruebas de funcionalidad';

USE celeste;
SELECT TABLE_NAME 
FROM INFORMATION_SCHEMA.TABLES 
WHERE TABLE_TYPE = 'BASE TABLE'
ORDER BY TABLE_NAME;


USE celeste;
SELECT 
    ci.id,
    p.first_name + ' ' + p.last_name AS pasajero,
    sa.seat_number AS asiento,
    ci.boarding_pass_code,
    ci.status
FROM check_ins ci
JOIN passengers p ON ci.passenger_id = p.id
JOIN seat_assignments sa ON ci.seat_assignment_id = sa.id
ORDER BY ci.id;



USE celeste;
EXEC sp_board_passenger
    @boarding_pass_code = 'BP-YUKI0007',
    @flight_instance_id = 6;


USE celeste;
EXEC sp_cerrar_vuelo @flight_id = 1;

USE celeste;
SELECT * FROM vw_check_in_status WHERE total_checkins > 0;
SELECT * FROM vw_manifiesto_detalle WHERE flight_instance_id = 1;
SELECT * FROM vw_tasa_no_show;


USE celeste;
SELECT * FROM vw_check_in_status WHERE total_checkins > 0;


USE celeste;
SELECT * FROM vw_manifiesto_detalle WHERE flight_instance_id = 1;



USE celeste;
SELECT * FROM vw_tasa_no_show;




