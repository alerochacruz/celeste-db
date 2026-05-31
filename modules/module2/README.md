# M2: Rutas y Programación

## Tablas

1. `airports`
2. `terminals`
3. `routes`

### Tabla `airports`

El campo `id` (*primary key*) de la tabla `airports` contiene el [código de aeropuertos de IATA](https://es.wikipedia.org/wiki/C%C3%B3digo_de_aeropuertos_de_IATA).

## TO-DO

- `flight_schedules`
- `flight_instances`

Dependencias:

- `flight_schedules` probablemente necesita la tabla `aircraft_types` del Módulo 1.
- `flight_instances` probablemente necesita la tabla `aircrafts` del Módulo 1.

## Recursos

Librerías de Python:

- [airports-py · PyPI](https://pypi.org/project/airports-py/)
- [brokolisql · PyPI](https://pypi.org/project/brokolisql/)
- [pandas · PyPI](https://pypi.org/project/pandas/)

Sitios web:

- [FlightConnections: All flights worldwide on a map!](https://www.flightconnections.com/)
    - [Flights from Bokeo to Vientiane: BOR to VTE Flights + Flight Schedule](https://www.flightconnections.com/flights-from-bor-to-vte)
- [Trip.com Official Site | Travel Deals and Promotions](https://www.trip.com/?locale=en-XX&curr=USD)
    - [Wattay International Airport (VTE) - Cheap Flights Air Tickets, Airport Information | Trip.com](https://www.trip.com/flights/airport-vte/)

