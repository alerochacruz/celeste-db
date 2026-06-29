-- Datos de las instancias
-- -----------------------------------------------------------------------------
-- Instancia 1:
--   Ruta: VTE-CSX
--   Número de vuelo: QV855
-- Instancia 2:
--   Ruta: CSX-VTE
--   Número de vuelo: QV856
-- Aeronave:
--   Tipo: "Airbus A320-777"
--   Matrícula: "RDPL-34777"

-- *****************************************************************************
-- 1. Añadir aeropuerto "CSX". Tabla "airports".
-- *****************************************************************************
INSERT INTO airports (
    iata_code,
    name,
    full_name,
    timezone,
    country_code,
    country
)

VALUES
  ('CSX', 'Changsha Huanghua', 'Changsha Huanghua International Airport', 'Asia/Shanghai', 'CN', 'China'); -- airports.iata_code: 25

-- *****************************************************************************
-- 2. Añadir terminales de "CSX". Tabla "terminals".
-- *****************************************************************************
INSERT INTO terminals (
    airport_iata_code,
    name
)

VALUES
    ('CSX', '1'), -- terminals.id: 105
    ('CSX', '2'); -- terminals.id: 106

-- *****************************************************************************
-- 3. Añadir rutas "VTE-CSX" y "CSX-VTE". Tabla "routes".
-- *****************************************************************************
INSERT INTO routes (
    origin_iata_code,
    dest_iata_code,
    distance_km,
    flight_time_minutes,
    is_active
)

VALUES
    ('VTE', 'CSX', 1572.14, 135, 1), -- routes.id: 107
    ('CSX', 'VTE', 1572.14, 135, 1); -- routes.id: 108

-- *****************************************************************************
-- 4. Registrar vuelos QV855 y QV856. Tabla "flight_schedules".
-- *****************************************************************************
INSERT INTO flight_schedules (
    route_id,
    flight_number,
    departure_terminal_id,
    arrival_terminal_id,
    scheduled_departure_time,
    scheduled_arrival_time,
    days_of_week,
    is_active
)

VALUES
  (107, 'QV855', 102, 106, '13:25:00', '16:40:00', 'MON, FRI', 1), -- flight_schedules.id: 39
  (108, 'QV856', 106, 102, '17:40:00', '19:20:00', 'MON, FRI', 1); -- flight_schedules.id: 40

-- *****************************************************************************
-- 5. Crear instancias de QV855 y QV856. Tabla "flight_instances".
-- *****************************************************************************
INSERT INTO flight_instances (
    flight_schedule_id,
    aircraft_id,
    flight_date,
    actual_departure_time,
    actual_arrival_time,
    status_code,
    is_manifest_closed
)

VALUES
  (39, 14, '2026-11-02', '2026-11-02 13:35:00', '2026-11-02 16:50:00', 'SCHEDULED', 0), -- flight_instances.id: 161
  (40, 14, '2026-11-06', '2026-11-06 17:50:00', '2026-11-06 19:30:00', 'SCHEDULED', 0); -- flight_instances.id: 162

-- aircraft.id[14]
--   registration_number: RDPL-34777
--   aircraft_type: Airbus A320-777
--   ...
