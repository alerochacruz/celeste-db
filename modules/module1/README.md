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

Consulta para verificar que se agregaron las aeronaves "Comac":

```sql
SELECT
  a.registration_number,
  CONCAT(at.manufacturer, ' ', at.model) AS aircraft_type,
  sc.name AS seat_configuration,
  sc.economy_seats,
  sc.business_seats,
  sc.total_seats,
  ms.status_code
FROM
  aircrafts a
  INNER JOIN aircraft_types at ON a.aircraft_type_id = at.id
  INNER JOIN seat_configurations sc ON a.seat_config_id = sc.id
  AND a.aircraft_type_id = sc.aircraft_type_id
  INNER JOIN maintenance_status ms ON a.current_status_id = ms.id
ORDER BY
  a.registration_number;
```

## Aeronaves

Referencia rápida de aeronaves:

| Registration | AircraftType     | EconomySeats | BusinessSeats | EngineType |
| ------------ | ---------------- | ------------ | ------------- | ---------- |
| RDPL-34188   | Airbus A320-214  | 126          | 16            | CFM56-5B4  |
| RDPL-34199   | Airbus A320-214  | 126          | 16            | CFM56-5B4  |
| RDPL-34223   | Airbus A320-214  | 150          | 8             | CFM56-5B4  |
| RDPL-34224   | Airbus A320-214  | 150          | 8             | CFM56-5B4  |
| RDPL-34173   | ATR 72-500       | 70           | 0             | PW127F     |
| RDPL-34174   | ATR 72-500       | 70           | 0             | PW127F     |
| RDPL-34175   | ATR 72-500       | 70           | 0             | PW127F     |
| RDPL-34176   | ATR 72-500       | 70           | 0             | PW127F     |
| RDPL-34222   | ATR 72-600       | 70           | 0             | PW127M     |
| RDPL-34225   | ATR 72-600       | 70           | 0             | PW127M     |
| RDPL-34228   | ATR 72-600       | 70           | 0             | PW127M     |
| RDPL-34229   | Comac ARJ-21-700 | 85           | 4             | CF34-10A   |
| RDPL-34266   | Comac ARJ-21-700 | 90           | 0             | CF34-10A   |

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

