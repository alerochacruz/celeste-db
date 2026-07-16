# M6: Facturación

Este módulo agrega facturación al ciclo operativo de Celeste. La factura nace a partir de una reserva confirmada, puede pagarse o cancelarse, y funciona como requisito comercial para que M5 permita el check-in.

## Tablas

1. `invoices`: registra una factura por reserva.

Campos principales:

- `booking_id`: relación directa con `bookings`.
- `flight_instance_id`: vuelo asociado a la factura.
- `base_fare`, `taxes`, `extras`: componentes del importe.
- `total_amount`: columna calculada persistida.
- `status`: `PENDING`, `PAID` o `CANCELLED`.
- `issue_date`, `payment_date`: fechas de emisión y pago.

## Stored Procedures

1. `sp_generate_invoice`: genera una factura `PENDING` para una reserva `CONFIRMED`.
2. `sp_register_payment`: marca una factura como `PAID` y registra `payment_date`.
3. `sp_cancel_invoice`: marca una factura como `CANCELLED` si todavía no fue pagada.

## Integraciones

### M3: Reservas y Pasajeros

`sp_confirm_booking` confirma la reserva y genera la factura dentro de una misma transacción. Si falla la generación de la factura, se revierte la confirmación.

`sp_cancel_booking` cancela la reserva y, si existe factura asociada, intenta cancelarla dentro de la misma transacción. Las facturas `PAID` no pueden cancelarse.

### M5: Check-in y Operaciones

`sp_check_in_passenger` valida que la reserva tenga una factura en estado `PAID`. Si no existe factura o está `PENDING`/`CANCELLED`, el check-in falla.

## Seeds

`seeds/sql/seed_invoices.sql` crea facturas `PAID` para las reservas iniciales en estado `CONFIRMED` y `NO_SHOW`.

Las reservas `PENDING` y `CANCELLED` quedan sin factura inicial para conservar escenarios de prueba.

## Dashboard Views

1. `vw_dashboard_invoice_status`: facturas e importes por estado.
2. `vw_dashboard_revenue_by_route`: revenue pagado por ruta.
3. `vw_dashboard_revenue_by_flight`: revenue y facturación por instancia de vuelo.

Estas vistas alimentan las cards de facturación del dashboard de Metabase.

## Tests

### Test de M6

```bash
sqlcmd -S localhost -U sa -P 'YourStrong!Passw0rd' -d celeste -i modules/module6/tests/test_module6.sql
```

El test es transaccional y hace `ROLLBACK`. Cubre:

- generación de factura al confirmar reserva;
- registro de pago;
- bloqueo de cancelación de factura `PAID`;
- cancelación de factura `PENDING`;
- bloqueo de pago sobre factura `CANCELLED`.

### Test de integración M5-M6

```bash
sqlcmd -S localhost -U sa -P 'YourStrong!Passw0rd' -d celeste -i modules/module5/tests/test_check_in_requires_paid_invoice.sql
```

El test es transaccional y hace `ROLLBACK`. Cubre:

- check-in sin factura: falla;
- check-in con factura `PENDING`: falla;
- check-in con factura `PAID`: pasa.

## Demo Manual

Elegir una reserva `PENDING`:

```sql
SELECT
    b.id,
    b.booking_code,
    bs.code AS booking_status,
    b.flight_instance_id
FROM bookings b
INNER JOIN booking_statuses bs
    ON bs.id = b.status_id
WHERE bs.code = 'PENDING';
```

Confirmar la reserva. Esto genera una factura `PENDING`:

```sql
EXEC sp_confirm_booking @booking_id = 4;
```

Registrar el pago:

```sql
DECLARE @invoice_id INT;

SELECT @invoice_id = id
FROM invoices
WHERE booking_id = 4;

EXEC sp_register_payment @invoice_id = @invoice_id;
```

Verificar estado final:

```sql
SELECT
    b.id,
    b.booking_code,
    bs.code AS booking_status,
    i.status AS invoice_status,
    i.total_amount,
    i.payment_date
FROM bookings b
INNER JOIN booking_statuses bs
    ON bs.id = b.status_id
LEFT JOIN invoices i
    ON i.booking_id = b.id
WHERE b.id = 4;
```
