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
GO
:r docker/init/create_login.sql
GO
:r docker/init/create_user.sql
GO

-- ============================================================
-- I. Module Definitions (tables, constraints, indexes)
-- ============================================================

-- MÓDULO 0: CORE
:r modules/module0/definitions/tables/system_settings.sql
GO

-- MÓDULO 1: Aeronaves y Flota
-- Agregar aquí scripts (tables, constraints, index etc.) en el orden que deben ejecutarse
:r modules/module1/definitions/tables/tbl_aircraft_types.sql
GO
:r modules/module1/definitions/tables/tbl_seat_configurations.sql
GO
:r modules/module1/definitions/tables/tbl_maintenance_status.sql
GO
:r modules/module1/definitions/tables/tbl_aircrafts.sql
GO

-- MÓDULO 2: Rutas y Programación
:r modules/module2/definitions/tables/tbl_airports.sql
GO
:r modules/module2/definitions/tables/tbl_terminals.sql
GO
:r modules/module2/definitions/tables/tbl_routes.sql
GO
:r modules/module2/definitions/tables/tbl_flight_schedules.sql
GO
:r modules/module2/definitions/tables/tbl_flight_instances.sql
GO

-- MÓDULO 3: Reservas y Pasajeros
:r modules/module3/definitions/tables/tbl_booking_statuses.sql
GO
:r modules/module3/definitions/tables/tbl_passengers.sql
GO
:r modules/module3/definitions/tables/tbl_bookings.sql
GO
:r modules/module3/definitions/tables/tbl_seat_assignments.sql
GO
:r modules/module3/definitions/types/tp_booking_seat_input.sql
GO


-- MÓDULO 4: Tripulación y Asignaciones
:r modules/module4/definitions/tables/tbl_crew_roles.sql
GO
:r modules/module4/definitions/tables/tbl_crew_members.sql
GO
:r modules/module4/definitions/tables/tbl_crew_certifications.sql
GO
:r modules/module4/definitions/tables/tbl_crew_assignments.sql
GO

-- MÓDULO 5: Check-in y Operaciones
-- :r modules/module5_checkin_operations/definitions/tables/tbl_check_ins.sql

:r modules/module5/definitions/tables/tbl_boarding_groups.sql
GO
:r modules/module5/definitions/tables/tbl_check_ins.sql
GO
:r modules/module5/definitions/tables/tbl_baggage_tags.sql
GO
:r modules/module5/definitions/tables/tbl_flight_manifests.sql
GO

-- MÓDULO 6: Facturación
:r modules/module6/definitions/tables/tbl_invoices.sql
GO

-- ============================================================
-- II. Seed Data (CSV imports or SQL inserts)
-- ============================================================

-- MÓDULO 0 Seeds
:r modules/module0/seeds/sql/seed_system_settings.sql
GO

-- MÓDULO 1 Seeds
:r modules/module1/seeds/sql/seed_maintenace_status.sql
GO
:r modules/module1/seeds/sql/seed_aircraft_types.sql
GO
:r modules/module1/seeds/sql/seed_seat_configurations.sql
GO
:r modules/module1/seeds/sql/seed_aircrafts.sql
GO

-- MÓDULO 2 Seeds
:r modules/module2/seeds/sql/seed_airports.sql
GO
:r modules/module2/seeds/sql/seed_terminals.sql
GO
:r modules/module2/seeds/sql/seed_routes.sql
GO
:r modules/module2/seeds/sql/seed_flight_schedules.sql
GO
:r modules/module2/seeds/sql/seed_flight_instances.sql
GO

-- MÓDULO 3 Seeds
:r modules/module3/seeds/sql/seed_passengers.sql
GO
:r modules/module3/seeds/sql/seed_booking_statuses.sql
GO
:r modules/module3/seeds/sql/seed_bookings.sql
GO
:r modules/module3/seeds/sql/seed_seat_assignments.sql
GO

-- MÓDULO 4 Seeds
:r modules/module4/seeds/sql/seed_crew_roles.sql
GO
:r modules/module4/seeds/sql/seed_crew_members.sql
GO
:r modules/module4/seeds/sql/seed_crew_certifications.sql
GO
:r modules/module4/seeds/sql/seed_crew_assignments.sql
GO


-- MÓDULO 6 Seeds
:r modules/module6/seeds/sql/seed_invoices.sql
GO

-- MÓDULO 5 Seeds
:r modules/module5/seeds/sql/seed_boarding_groups.sql
GO
:r modules/module5/seeds/sql/seed_check_ins.sql
GO
:r modules/module5/seeds/sql/seed_baggage_tags.sql
GO
-- Agregar seeds para otros módulos según sea necesario

-- ============================================================
-- III. Business Logic (functions, procedures, triggers, views)
-- ============================================================

-- MÓDULO 1 Views
:r modules/module1/views/vw_operative_fleet.sql
GO

-- MÓDULO 1 Dashboard Views
:r modules/module1/dashboard_views/vw_dashboard_fleet_status.sql
GO

-- MÓDULO 2 Functions/Procedures
-- :r modules/module2_routes_schedule/functions/fn_calculate_distance.sql
-- :r modules/module2_routes_schedule/procedures/sp_create_route.sql

-- MÓDULO 2 Views
:r modules/module2/views/vw_flight_schedules_extended.sql
GO
:r modules/module2/views/vw_flight_instances_extended.sql
GO

-- MÓDULO 2 Dashboard Views
:r modules/module2/dashboard_views/vw_dashboard_daily_operations.sql
GO

-- MÓDULO 6 Procedures
-- Se despliegan antes dado que son requeridos por el M3
:r modules/module6/procedures/sp_generate_invoice.sql
GO
:r modules/module6/procedures/sp_register_payment.sql
GO
:r modules/module6/procedures/sp_cancel_invoice.sql
GO

-- MÓDULO 3
-- Functions
:r modules/module3/functions/fn_get_setting_int.sql
GO
-- Triggers
:r modules/module3/triggers/tr_seat_assignment_overbooking.sql
GO
:r modules/module3/triggers/tr_seat_assignment_consistency.sql
GO
-- Procedures
:r modules/module3/procedures/sp_register_passenger.sql
GO
:r modules/module3/procedures/sp_cancel_booking.sql
GO
:r modules/module3/procedures/sp_confirm_booking.sql
GO
:r modules/module3/procedures/sp_create_booking.sql
GO

-- MÓDULO 3 Dashboard Views
:r modules/module3/dashboard_views/vw_dashboard_flight_occupancy.sql
GO


-- MÓDULO 4 View & Triggers
:r modules/module4/views/vw_crew_schedule.sql
GO
:r modules/module4/triggers/trg_validate_crew_assignment.sql
GO

-- MÓDULO 4 Dashboard Views
:r modules/module4/dashboard_views/vw_dashboard_crew_assignments.sql
GO


-- MÓDULO 5 Procedures & Views
:r modules/module5/procedures/sp_check_in_passenger.sql
GO
:r modules/module5/procedures/sp_board_passenger.sql
GO
:r modules/module5/procedures/sp_cerrar_vuelo.sql
GO
:r modules/module5/views/vw_check_in_status.sql
GO
:r modules/module5/views/vw_manifiesto_detalle.sql
GO
:r modules/module5/views/vw_tasa_no_show.sql
GO

-- MÓDULO 5 Dashboard Views
:r modules/module5/dashboard_views/vw_dashboard_checkin_boarding.sql
GO

-- MÓDULO 6 Dashboard Views
:r modules/module6/dashboard_views/vw_dashboard_invoice_status.sql
GO
:r modules/module6/dashboard_views/vw_dashboard_revenue_by_route.sql
GO
:r modules/module6/dashboard_views/vw_dashboard_revenue_by_flight.sql
GO

-- Agregar otro module logic aquí

-- ============================================================
-- IV. Tests (Unit tests, Integration tests...)
-- ============================================================

-- MÓDULO 2 Tests
-- :r modules/module2_routes_schedule/tests/test_routes.sql

-- MÓDULO 4 Tests
-- :r modules/module4/tests/test_crew_assignments.sql

-- Agregar otros module tests aqu
