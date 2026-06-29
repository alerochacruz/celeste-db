-- Datos de la nueva aeronave
-- -----------------------------------------------------------------------------
-- Matrícula: "RDPL-34777"
-- Tipo de aeronave: "Airbus A320-777"
-- Asientos "Economy": 160
-- Asientos "Business": 8
-- Etiqueta configuración de asientos: "A320 High-Density 168"
-- Capacidad máxima de pasajeros: 180
-- Tipo de motor: "CFM56-5B4"

-- *****************************************************************************
-- 1. Agregar tipo de aeronave. Tabla "aircraft_types".
-- *****************************************************************************
INSERT INTO aircraft_types (
    manufacturer,
    model,
    engine_type,
    max_pax_capacity
)
VALUES
    ('Airbus', 'A320-777', 'CFM56-5B4', 180); -- aircraft_types.id: 5

-- *****************************************************************************
-- 2. Definir configuración de asientos. Tabla "seat_configurations".
-- *****************************************************************************
INSERT INTO seat_configurations (
    aircraft_type_id,
    name,
    economy_seats,
    business_seats
)
VALUES
    (5, 'A320 High-Density 168', 160, 8); -- seat_configurations.id: 7

-- *****************************************************************************
-- 3. Añadir estado de mantenimiento. Tabla "maintenance_status".
-- *****************************************************************************
-- Este paso se omite. Los tres tipos de estados posibles
-- "OPERATIONAL", "MAINTENANCE" y "GROUNDED" ya están definidos.
-- maintenance_status.id: 1

-- *****************************************************************************
-- 4. Registrar aeronave. Tabla "aircrafts".
-- *****************************************************************************
INSERT INTO aircrafts (
    registration_number,
    aircraft_type_id,
    seat_config_id,
    current_status_id
)
VALUES
    ('RDPL-34777', 5, 7, 1); -- aircrafts.id: 14

