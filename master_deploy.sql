-- ============================================================
-- Master Deployment Script
-- Proyecto: base de datos para aerolínea
-- Este script centraliza y orquesta la ejecución de todos
-- los archivos .sql usando la directiva :r de sqlcmd.
-- ============================================================

-- Instrucciones para ejecutar este script con sqlcmd desde la terminal
-- Ejemplo:
-- sqlcmd -S localhost -U sa -P 'YourStrong!Passw0rd' -i master_deploy.sql
-- Nota: evite pasar contraseñas en texto plano; use autenticación integrada,
-- variables de entorno o el parámetro -E cuando sea posible.

-- Inicialización (database, logins, users)
-- ============================================================
:r docker/init/create_database.sql
:r docker/init/create_login.sql
:r docker/init/create_user.sql

-- ============================================================
-- I. Module Definitions (tables, constraints, indexes)
-- ============================================================

-- MÓDULO 1: Aeronaves y Flota
-- Agregar aquí scripts (tables, constraints, index etc.) en el orden que deben ejecutarse
:r modules/module1/definitions/tables/tbl_aircraft_types.sql
:r modules/module1/definitions/tables/tbl_seat_configurations.sql
:r modules/module1/definitions/tables/tbl_maintenance_status.sql
:r modules/module1/definitions/tables/tbl_aircrafts.sql

-- MÓDULO 2: Rutas y Programación
:r modules/module2/definitions/tables/tbl_airports.sql
:r modules/module2/definitions/tables/tbl_terminals.sql
:r modules/module2/definitions/tables/tbl_routes.sql

-- MÓDULO 3: Reservas y Pasajeros
-- :r modules/module3_reservations_passengers/definitions/tables/tbl_passengers.sql

-- MÓDULO 4: Tripulación y Asignaciones
-- :r modules/module4_crew_assignments/definitions/tables/tbl_crew_members.sql

-- MÓDULO 5: Check-in y Operaciones
-- :r modules/module5_checkin_operations/definitions/tables/tbl_check_ins.sql

-- ============================================================
-- II. Seed Data (CSV imports or SQL inserts)
-- ============================================================

-- MÓDULO 1 Seeds
:r modules/module1/seeds/sql/seed_maintenace_status.sql
:r modules/module1/seeds/sql/seed_aircraft_types.sql
:r modules/module1/seeds/sql/seed_seat_configurations.sql
:r modules/module1/seeds/sql/seed_aircrafts.sql

-- MÓDULO 2 Seeds
:r modules/module2/seeds/sql/seed_airports.sql
:r modules/module2/seeds/sql/seed_terminals.sql
:r modules/module2/seeds/sql/seed_routes.sql

-- Agregar seeds para otros módulos según sea necesario

-- ============================================================
-- III. Business Logic (functions, procedures, triggers, views)
-- ============================================================

-- MÓDULO 1 Views
:r modules/module1/views/vw_operative_fleet.sql

-- MÓDULO 2 Functions/Procedures
-- :r modules/module2_routes_schedule/functions/fn_calculate_distance.sql
-- :r modules/module2_routes_schedule/procedures/sp_create_route.sql

-- Agregar otro module logic aquí

-- ============================================================
-- IV. Tests (Unit tests, Integration tests...)
-- ============================================================

-- MÓDULO 2 Tests
-- :r modules/module2_routes_schedule/tests/test_routes.sql

-- Agregar otros module tests aquí

