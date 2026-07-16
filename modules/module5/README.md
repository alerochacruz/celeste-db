# M5: Check-in y Operaciones

Este módulo gestiona el proceso completo del día del vuelo: check-in de pasajeros, abordaje y cierre operacional. Es la última parte del ciclo de vida de un vuelo — toma las reservas confirmadas de M3, los vuelos programados de M2 y genera el manifiesto final que reporta la operación real.

---

## Estructura de archivos

```
module5/
├── definitions/
│   └── tables/
│       ├── tbl_boarding_groups.sql
│       ├── tbl_check_ins.sql
│       ├── tbl_baggage_tags.sql
│       └── tbl_flight_manifests.sql
├── procedures/
│   ├── sp_check_in_passenger.sql
│   ├── sp_board_passenger.sql
│   └── sp_cerrar_vuelo.sql
├── views/
│   ├── vw_check_in_status.sql
│   ├── vw_manifiesto_detalle.sql
│   └── vw_tasa_no_show.sql
├── seeds/
│   └── sql/
│       ├── seed_boarding_groups.sql
│       ├── seed_check_ins.sql
│       └── seed_baggage_tags.sql
├── tests/
│   └── test_module5.sql
└── README.md
```

---

## Dependencias

| Módulo                     | Tablas que usa M5 |
|----------------------------|-------------------|
| M1 – Aeronaves             | `aircrafts`, `aircraft_types`, `seat_configurations` |
| M2 – Vuelos                | `flight_instances`, `flight_schedules`, `routes` |
| M3 – Reservas              | `bookings`, `booking_statuses`, `passengers`, `seat_assignments` |
| M6 – Facturación           | `invoices` |

> **Nota:** La tabla `flight_instances` (M2) incluye la columna `is_manifest_closed BIT` preparada específicamente para que `sp_cerrar_vuelo` la actualice al cerrar el vuelo.

---

## Tablas

### `boarding_groups`
Define los grupos de prioridad de abordaje por vuelo. Business aborda primero (group_number = 1), luego Economy (group_number = 2).

### `check_ins`
Tabla central del módulo. Registra el check-in de cada pasajero con su tarjeta de embarque. Un pasajero pasa de tener una reserva CONFIRMED a tener un boarding_pass_code único. Estados posibles: `CHECKED_IN` → `BOARDED` o `NO_SHOW`.

### `baggage_tags`
Registra cada pieza de equipaje vinculada a un check-in. Avanza de estado `TAGGED` → `LOADED` cuando el pasajero aborda.

### `flight_manifests`
Manifiesto final generado por `sp_cerrar_vuelo`. Contiene totales de pasajeros, pesos y el factor de carga. Las columnas `total_weight_kg` y `load_factor_pct` son calculadas y persistidas por SQL Server.

---

## Procedimientos

### `sp_check_in_passenger`
Registra el check-in de un pasajero. Valida que la reserva sea `CONFIRMED`, que exista una factura `PAID`, que el vuelo esté activo, que no exista check-in previo y que haya asiento asignado. Genera un `boarding_pass_code` único con formato `BP-XXXXXXXX`.

```sql
EXEC sp_check_in_passenger
    @booking_id = 3,
    @channel    = 'WEB';
```

### `sp_board_passenger`
Marca a un pasajero como BOARDED al escanear su tarjeta en la puerta. Actualiza también el equipaje de bodega a LOADED.

```sql
EXEC sp_board_passenger
    @boarding_pass_code = 'BP-YUKI0007',
    @flight_instance_id = 6;
```

### `sp_cerrar_vuelo`
Cierre operacional del vuelo (~30 min antes de salida). Marca no-shows, propaga el estado a bookings, calcula pesos, genera el manifiesto y cierra el vuelo.

```sql
EXEC sp_cerrar_vuelo @flight_id = 1;
```

---

## Vistas

### `vw_check_in_status`
Estado en tiempo real del check-in por vuelo: cuántos hicieron check-in, cuántos abordaron, cuántos son no-show y el porcentaje de ocupación.

### `vw_manifiesto_detalle`
Lista completa de pasajeros con asiento, clase, grupo de abordaje, boarding pass y equipaje. Sirve como manifiesto imprimible.

### `vw_tasa_no_show`
Tasa de no-show por vuelo cerrado, para análisis comercial y ajuste de overbooking en M3.

---
### Paso 2 — Ejecutar las tablas (en orden)

Abrí cada archivo, asegurate de que la conexión a `celeste` esté activa abajo a la derecha en VS Code, y ejecutá con `Ctrl + Shift + E`. El orden importa por las FK:

1. `definitions/tables/tbl_boarding_groups.sql`
2. `definitions/tables/tbl_check_ins.sql`
3. `definitions/tables/tbl_baggage_tags.sql`
4. `definitions/tables/tbl_flight_manifests.sql`

Cada uno debe mostrar `Commands completed successfully` antes de pasar al siguiente.

### Paso 3 — Ejecutar los seeds (en orden)

5. `seeds/sql/seed_boarding_groups.sql`
6. `seeds/sql/seed_check_ins.sql`
7. `seeds/sql/seed_baggage_tags.sql`

### Paso 4 — Ejecutar los procedures y vistas (cualquier orden)

8. `procedures/sp_check_in_passenger.sql`
9. `procedures/sp_board_passenger.sql`
10. `procedures/sp_cerrar_vuelo.sql`
11. `views/vw_check_in_status.sql`
12. `views/vw_manifiesto_detalle.sql`
13. `views/vw_tasa_no_show.sql`

### Paso 5 — Correr los tests

Abrí `tests/test_module5.sql` y ejecutá con `Ctrl + Shift + E`. En el panel de resultados inferior vas a ver la salida de cada test con `PRINT` como separadores.

Para validar la integración con facturación, ejecutá también:

```bash
sqlcmd -S localhost -U sa -P 'YourStrong!Passw0rd' -d celeste -i modules/module5/tests/test_check_in_requires_paid_invoice.sql
```

---

## Flujo completo del día del vuelo

```
[Reserva CONFIRMED en M3 + factura PAID en M6]
         │
         ▼
sp_check_in_passenger()  →  check_ins.status = 'CHECKED_IN'
                             boarding_pass_code generado
         │
         ▼
sp_board_passenger()     →  check_ins.status = 'BOARDED'
                             baggage_tags.status = 'LOADED'
         │
         │  (~30 min antes de salida)
         ▼
sp_cerrar_vuelo()        →  CHECKED_IN → NO_SHOW
                             bookings.status_id → NO_SHOW
                             flight_manifests INSERT
                             flight_instances.is_manifest_closed = 1
```

---

## Resultado esperado de los tests

| Test | Descripción                       | Resultado esperado |
|------|-----------------------------------|-------------------|
| 2.1 | Check-in duplicado (ya en seed)    | Error: ya existe check-in |
| 2.2 | Booking inexistente                | Error: reserva no existe |
| 2.3 | Booking CANCELLED                  | Error: estado inválido |
| 2.4 | Booking PENDING                    | Error: estado inválido |
| 2.5 | Booking NO_SHOW                    | Error: estado inválido |
| 3.1 | Abordar a Yuki (CHECKED_IN)        | Éxito: nuevo estado BOARDED |
| 3.2 | Abordar a Martín (ya BOARDED)      | Error: ya abordó |
| 3.3 | Abordar a Sofia (NO_SHOW)          | Error: es no-show |
| 3.4 | Tarjeta inexistente                | Error: tarjeta no válida |
| 3.5 | Tarjeta correcta, vuelo incorrecto | Error: tarjeta no válida |
| 4.1 | Cerrar vuelo 1                     | Éxito: manifiesto generado |
| 4.2 | Cerrar vuelo 1 de nuevo            | Error: ya cerrado |
| 4.3 | Cerrar vuelo inexistente           | Error: vuelo no existe |
| 4.4 | Cerrar vuelo 2                     | Éxito: manifiesto generado |
| 5.1 | vw_check_in_status                 | Filas con conteos por vuelo |
| 5.2 | vw_manifiesto_detalle vuelo 1      | Lista de pasajeros del vuelo 1 |
| 5.3 | vw_manifiesto_detalle vuelo 2      | Lista de pasajeros del vuelo 2 |
| 5.4 | vw_tasa_no_show                    | Filas de vuelos cerrados con tasa |
