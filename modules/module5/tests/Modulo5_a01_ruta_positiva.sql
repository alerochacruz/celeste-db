--Esta es una prueba de ruta positiva para el módulo 5 del proyecto Celeste.- test
USE celeste;
GO

-- Antes de llegar a M5, esto ya fue registrado por los otros módulos del equipo


-- M1: La aeronave está operativa
SELECT
    a.registration_number               AS matricula,
    at2.manufacturer + ' ' + at2.model AS aeronave,
    sc.economy_seats                    AS asientos_economy,
    sc.business_seats                   AS asientos_business,
    sc.total_seats                      AS capacidad_total,
    ms.description                      AS estado
FROM aircrafts a
JOIN aircraft_types      at2 ON a.aircraft_type_id  = at2.id
JOIN seat_configurations sc  ON a.seat_config_id    = sc.id
                            AND a.aircraft_type_id  = sc.aircraft_type_id
JOIN maintenance_status  ms  ON a.current_status_id = ms.id
WHERE a.id = 1;
GO

-- M2: El vuelo está programado
SELECT
    fs.flight_number                            AS numero_vuelo,
    r.origin_iata_code + ' → ' + r.dest_iata_code AS ruta,
    CAST(fs.departure_time AS VARCHAR)          AS hora_salida,
    fi.flight_date                              AS fecha,
    fi.status_code                              AS estado_vuelo,
    fi.is_manifest_closed                       AS manifiesto_cerrado
FROM flight_instances fi
JOIN flight_schedules fs ON fi.flight_schedule_id = fs.id
JOIN routes           r  ON fs.route_id           = r.id
WHERE fi.id = 1;
GO

-- M3: Los pasajeros tienen reservas confirmadas con asientos
SELECT
    b.booking_code                          AS codigo_reserva,
    p.first_name + ' ' + p.last_name       AS pasajero,
    sa.seat_number                          AS asiento,
    sa.class                                AS clase,
    bs.code                                 AS estado_reserva
FROM bookings b
JOIN booking_statuses  bs ON b.status_id           = bs.id
JOIN passengers        p  ON b.booker_passenger_id = p.id
JOIN flight_instances  fi ON b.flight_instance_id  = fi.id
LEFT JOIN seat_assignments sa ON sa.booking_id     = b.id
WHERE fi.id = 1
  AND bs.code = 'CONFIRMED'
ORDER BY sa.class DESC, sa.seat_number;
GO

-- M4: La tripulación está asignada y certificada
SELECT
    cr.name                                 AS rol,
    cm.first_name + ' ' + cm.last_name     AS tripulante
FROM crew_assignments ca
JOIN crew_members cm ON ca.crew_member_id     = cm.id
JOIN crew_roles   cr ON ca.role_id            = cr.id
WHERE ca.flight_instance_id = 1
ORDER BY ca.role_id;
GO


-- PUNTO 5 DEL TP: DÍA DEL VUELO — CHECK-IN
-- "El pasajero hace check-in, se confirma asiento y
--  se emite la tarjeta de embarque"

-- Grupos de abordaje configurados para el vuelo
SELECT
    group_number    AS numero_grupo,
    group_name      AS nombre,
    boarding_order  AS orden_llamada
FROM boarding_groups
WHERE flight_instance_id = 1
ORDER BY boarding_order;
GO

-- Check-ins ya registrados 
-- Check-ins registrados con tarjetas de embarque --
SELECT
    ci.boarding_pass_code               AS tarjeta_embarque,
    p.first_name + ' ' + p.last_name   AS pasajero,
    sa.seat_number                      AS asiento,
    sa.class                            AS clase,
    bg.group_name                       AS grupo_abordaje,
    ci.channel                          AS canal_checkin,
    ci.checked_in_at                    AS hora_checkin,
    ci.status                           AS estado
FROM check_ins ci
JOIN passengers       p  ON ci.passenger_id       = p.id
JOIN seat_assignments sa ON ci.seat_assignment_id = sa.id
JOIN boarding_groups  bg ON ci.boarding_group_id  = bg.id
WHERE ci.flight_instance_id = 1
ORDER BY sa.class DESC, ci.id;
GO

-- Equipaje registrado en el check-in

SELECT
    p.first_name + ' ' + p.last_name   AS pasajero,
    bt.tag_code                         AS etiqueta,
    bt.weight_kg                        AS peso_kg,
    bt.bag_type                         AS tipo,
    bt.status                           AS estado
FROM baggage_tags bt
JOIN check_ins ci ON bt.check_in_id  = ci.id
JOIN passengers p  ON ci.passenger_id = p.id
WHERE ci.flight_instance_id = 1
ORDER BY ci.id, bt.id;
GO


-- Estado del vuelo en este momento
-- Martín → BOARDED | Sofia → CHECKED_IN (aún no abordó)
SELECT
    p.first_name + ' ' + p.last_name   AS pasajero,
    sa.seat_number                      AS asiento,
    sa.class                            AS clase,
    ci.boarding_pass_code               AS tarjeta_embarque,
    ci.status                           AS estado,
    CASE ci.status
        WHEN 'BOARDED'     THEN 'Abordó correctamente'
        WHEN 'CHECKED_IN'  THEN 'Hizo check-in — esperando abordar'
        WHEN 'NO_SHOW'     THEN 'No se presentó'
    END                                 AS descripcion
FROM check_ins ci
JOIN passengers       p  ON ci.passenger_id       = p.id
JOIN seat_assignments sa ON ci.seat_assignment_id = sa.id
WHERE ci.flight_instance_id = 1
ORDER BY ci.id;
GO

-- 30 minutos antes de salida:
--  - Sofia queda como NO_SHOW automáticamente
--  - Se genera el manifiesto final
--  - El vuelo queda cerrado

-- sp_cerrar_vuelo — 30 min antes de salida

EXEC sp_cerrar_vuelo @flight_id = 1;
GO

-- Estado final de los pasajeros después del cierre
SELECT
    p.first_name + ' ' + p.last_name   AS pasajero,
    sa.seat_number                      AS asiento,
    sa.class                            AS clase,
    ci.boarding_pass_code               AS tarjeta_embarque,
    ci.status                           AS estado_final,
    CASE ci.status
        WHEN 'BOARDED'  THEN 'Embarcó correctamente'
        WHEN 'NO_SHOW'  THEN 'No se presentó — asiento liberado'
    END                                 AS descripcion
FROM check_ins ci
JOIN passengers       p  ON ci.passenger_id       = p.id
JOIN seat_assignments sa ON ci.seat_assignment_id = sa.id
WHERE ci.flight_instance_id = 1
ORDER BY ci.id;
GO

-- Verificar que la reserva de Sofia cambió a NO_SHOW en M3
SELECT
    b.booking_code                          AS codigo_reserva,
    p.first_name + ' ' + p.last_name       AS pasajero,
    bs.code                                 AS estado_reserva,
    bs.description                          AS descripcion
FROM bookings b
JOIN booking_statuses bs ON b.status_id           = bs.id
JOIN passengers       p  ON b.booker_passenger_id = p.id
WHERE b.flight_instance_id = 1
ORDER BY b.id;
GO

-- Verificar que el vuelo quedó cerrado en M2
SELECT
    fi.id,
    fs.flight_number        AS numero_vuelo,
    fi.flight_date          AS fecha,
    fi.status_code          AS estado_vuelo,
    fi.is_manifest_closed   AS manifiesto_cerrado
FROM flight_instances fi
JOIN flight_schedules fs ON fi.flight_schedule_id = fs.id
WHERE fi.id = 1;
GO

-- Operaciones y Comercial consultan los resultados
-- vw_manifiesto_detalle: Lista final de pasajeros
SELECT
    numero_vuelo,
    origen + ' → ' + destino           AS ruta,
    pasajero,
    tipo_documento,
    numero_documento,
    asiento,
    clase,
    grupo_abordaje,
    boarding_pass,
    canal_checkin,
    estado,
    equipaje_bodega_kg                  AS equipaje_kg
FROM vw_manifiesto_detalle
WHERE flight_instance_id = 1
ORDER BY clase DESC, asiento;
GO

-- Panel operacional en tiempo real — todos los vuelos
-- vw_check_in_status: Panel operacional en tiempo real 
SELECT
    numero_vuelo,
    fecha_vuelo,
    origen + ' → ' + destino           AS ruta,
    capacidad_total,
    total_checkins                      AS con_checkin,
    embarcados,
    no_shows,
    pendientes_abordar,
    CAST(pct_ocupacion AS VARCHAR) + '%' AS pct_ocupacion,
    CASE manifiesto_cerrado
        WHEN 1 THEN 'CERRADO'
        ELSE 'ABIERTO'
    END                                 AS manifiesto
FROM vw_check_in_status
ORDER BY flight_instance_id;
GO

-- Análisis de no-shows — para área comercial
-- vw_tasa_no_show: Análisis comercial de no-shows 
SELECT
    numero_vuelo,
    origen + ' → ' + destino               AS ruta,
    fecha_vuelo,
    capacidad_aeronave,
    embarcados,
    no_shows,
    total_con_checkin,
    CAST(tasa_no_show_pct AS VARCHAR) + '%'  AS tasa_no_show,
    CAST(pct_ocupacion_real AS VARCHAR) + '%' AS ocupacion_real,
    peso_total_kg,
    mtow_kg,
    CAST(factor_carga_pct AS VARCHAR) + '%'  AS factor_carga,
    'OK'                                     AS balance_carga
FROM vw_tasa_no_show;
GO




-- Limpieza final del escenario de prueba 
USE celeste;

-- Limpiar manifiesto del vuelo 1
DELETE FROM flight_manifests WHERE flight_instance_id = 1;

-- Reabrir el vuelo
UPDATE flight_instances SET is_manifest_closed = 0 WHERE id = 1;

-- Resetear check-ins del vuelo 1 al estado original del seed
UPDATE check_ins SET status = 'BOARDED'  WHERE booking_id = 1;
UPDATE check_ins SET status = 'CHECKED_IN' WHERE booking_id = 2;

-- Resetear equipaje
UPDATE baggage_tags SET status = 'LOADED' WHERE check_in_id = 1;
UPDATE baggage_tags SET status = 'TAGGED' WHERE check_in_id = 2;

-- Resetear reserva de Sofia a CONFIRMED
UPDATE bookings 
SET status_id = (SELECT id FROM booking_statuses WHERE code = 'CONFIRMED')
WHERE id = 2;



