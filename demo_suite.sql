-- ============================================================
-- Demo Suite Script
-- Este script centraliza y orquesta la ejecución de
-- los archivos .sql ubicados dentro de las subcarpetas "demo/"
-- de cada uno de los 5 módulos del proyecto.
-- IMPORTANTE:
-- Este script ejecuta únicamente el escenario exitoso "A"
-- ============================================================

-- Instrucciones para ejecutar este script con sqlcmd desde la terminal
-- Ejemplo:
-- sqlcmd -S localhost -U sa -P 'YourStrong!Passw0rd' -i demo_suite.sql

-- Seleccionar base de datos "celeste"
-- ============================================================
USE celeste;
GO

-- ============================================================
-- DEMO MÓDULO 1: Aeronaves y Flota
-- ============================================================
-- Registrar nueva aeronave Airbus A320-214
:r modules/module1/demo/a01_registrar_aeronave.sql
GO

