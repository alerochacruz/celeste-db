# M1: Aeronaves y Flota

## Tablas

1. `aircraft_types.sql`
2. `seat_configurations.sql`
3. `maintenance_status.sql`
4. `aircrafts.sql`

## Vistas

1. `vw_operative_fleet.sql`

## Pruebas

Consulta para probar `vw_operative_fleet`:

```sql
SELECT
  *
FROM
  vw_operative_fleet;
```

Seleccionando colúmnas específicas:

```sql
SELECT
  id,
  registration_number,
  aircraft_type,
  seat_configuration,
  total_seats,
  status_code
FROM
  vw_operative_fleet
ORDER BY
  registration_number;
```

## Recursos

Sitios web:

- [How to determine the aircraft tail number on a particular flight? - Aviation Stack Exchange](https://aviation.stackexchange.com/questions/16441/how-to-determine-the-aircraft-tail-number-on-a-particular-flight)
- [Lao Airlines (QV/LAO) Fleet, Routes & Reviews | Flightradar24](https://www.flightradar24.com/data/airlines/qv-lao/fleet)
    - Para obtener información de flota: buscar vuelo "QV101", luego seleccionar "Show fleet".
- [Fleet Information - Lao Airlines Official Website](https://laoairlines.com/en/fleet-information/)
- [Aircraft Layout (Seat Maps) - Lao Airlines Official Website](https://laoairlines.com/en/aircraft-layout/)
- [Flight Schedule - Lao Airlines Official Website](https://laoairlines.com/en/flight-schedule/)

Librerías de Python:

- [sqlcsvsql · PyPI](https://pypi.org/project/sqlcsvsql/)

Troubleshooting:

- [sql - 'CREATE VIEW' must be the first statement in a query batch - Stack Overflow](https://stackoverflow.com/questions/13340332/create-view-must-be-the-first-statement-in-a-query-batch)

