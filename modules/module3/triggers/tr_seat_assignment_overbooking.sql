SET QUOTED_IDENTIFIER ON;
GO
CREATE OR ALTER TRIGGER tr_seat_assignment_overbooking
ON seat_assignments
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @margin_pct INT = dbo.fn_get_setting_int('OVERBOOKING_MARGIN_PCT', 0);
    DECLARE @flight_id  INT;
    DECLARE @class      VARCHAR(10);
    DECLARE @capacity   INT;
    DECLARE @max_allow  INT;
    DECLARE @actual     INT;

    ;WITH affected_slots AS (
        SELECT DISTINCT
            i.flight_instance_id,
            i.class
        FROM inserted i
    ),
    capacity_per_slot AS (
        SELECT
            slot.flight_instance_id,
            slot.class,
            CASE slot.class
                WHEN 'ECONOMY'  THEN sc.economy_seats
                WHEN 'BUSINESS' THEN sc.business_seats
            END AS nominal_capacity
        FROM affected_slots slot
        JOIN flight_instances    fi ON fi.id                = slot.flight_instance_id
        JOIN aircrafts            a ON a.id                 = fi.aircraft_id
        JOIN seat_configurations sc ON sc.id                = a.seat_config_id
                                   AND sc.aircraft_type_id = a.aircraft_type_id
    ),
    current_load AS (
        SELECT
            sa.flight_instance_id,
            sa.class,
            COUNT(*) AS active_count
        FROM seat_assignments sa
        JOIN bookings         b  ON b.id  = sa.booking_id
        JOIN booking_statuses bs ON bs.id = b.status_id
        WHERE bs.code IN ('PENDING', 'CONFIRMED')
          AND EXISTS (
              SELECT 1
              FROM inserted i
              WHERE i.flight_instance_id = sa.flight_instance_id
                AND i.class              = sa.class
          )
        GROUP BY sa.flight_instance_id, sa.class
    )
    SELECT TOP 1
        @flight_id  = c.flight_instance_id,
        @class      = c.class,
        @capacity   = c.nominal_capacity,
        @max_allow  = c.nominal_capacity + FLOOR(c.nominal_capacity * @margin_pct / 100.0),
        @actual     = l.active_count
    FROM capacity_per_slot c
    JOIN current_load l ON l.flight_instance_id = c.flight_instance_id
                       AND l.class              = c.class
    WHERE l.active_count > c.nominal_capacity + FLOOR(c.nominal_capacity * @margin_pct / 100.0);

    IF @flight_id IS NOT NULL
    BEGIN
        RAISERROR(
            'tr_seat_assignment_overbooking: overbooking excedido en vuelo #%d clase %s. Capacidad: %d, margen %d%%, maximo permitido: %d, intentado: %d.',
            16, 1,
            @flight_id, @class, @capacity, @margin_pct, @max_allow, @actual
        );
    END;
END;
GO