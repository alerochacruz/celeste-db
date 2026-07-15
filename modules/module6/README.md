# M6: Facturación

## Tablas

1. `invoices`

## Stored Procedures

1. `sp_generate_invoice`
2. `sp_cancel_invoice` 
3. `sp_register_payment` 

## Demo

### Antes de empezar

Comprobar que existe la tarifa por defecto:

```sql
SELECT *
FROM system_settings
WHERE setting_key = 'DEFAULT_BASE_FARE';
```

Y muestra que inicialmente no existen facturas:

```sql
SELECT *
FROM invoices;
```

### Paso 1: Elegir una reserva PENDING

```sql
SELECT
    b.id,
    bs.code AS booking_status,
    b.flight_instance_id,
    b.booking_date
FROM bookings b
INNER JOIN booking_statuses bs
    ON bs.id = b.status_id
WHERE bs.code = 'PENDING';
```

Supongamos que devuelve:

```text
id = 4
```

### Paso 2: Confirmar la reserva

```sql
EXEC sp_confirm_booking
    @booking_id = 4;
```

Este procedimiento confirma la reserva y automáticamente genera la factura.

### Paso 3: Mostrar la factura creada

```sql
SELECT *
FROM invoices
WHERE booking_id = 4;
```

Debería verse algo parecido a:

| id | booking_id | base_fare | taxes | extras | total_amount | status  |
| -- | ---------- | --------- | ----- | ------ | ------------ | ------- |
| 1  | 4          | 250.00    | 37.50 | 0      | 287.50       | PENDING |

La tarifa base proviene de `system_settings`, los impuestos se calculan automáticamente y el total es una columna calculada.

### Paso 3: Registrar el pago

Primero obtener el id:

```sql
SELECT id
FROM invoices
WHERE booking_id = 4;
```

Supongamos:

```text
id = 1
```

Ahora:

```sql
EXEC sp_register_payment
    @invoice_id = 1;
```

Mostrar el resultado:

```sql
SELECT *
FROM invoices
WHERE id = 1;
```

Ahora deberá aparecer:

```text
status = PAID

payment_date = ...
```

### Paso 5: Intentar cancelar la factura

```sql
EXEC sp_cancel_invoice
    @booking_id = 4;
```

El procedimiento debe producir el error:

```text
Paid invoices cannot be cancelled.
```

Eso demuestra que existen reglas de negocio.

### Paso 6: Mostrar el estado final

```sql
SELECT
    b.id,
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

De esta manera se pueden visualizar ambas tablas relacionadas.

