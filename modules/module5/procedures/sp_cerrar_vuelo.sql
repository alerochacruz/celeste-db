SET QUOTED_IDENTIFIER ON;
GO
CREATE OR ALTER PROCEDURE sp_cerrar_vuelo
    @flight_id INT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @is_closed         BIT;
    DECLARE @flight_status     VARCHAR(20);
    DECLARE @aircraft_id       INT;
    DECLARE @mtow_kg           DECIMAL(8,2);
    DECLARE @total_boarded     SMALLINT;
    DECLARE @total_no_shows    SMALLINT;
    DECLARE @baggage_weight_kg DECIMAL(8,2);
    DECLARE @est_pax_weight    DECIMAL(8,2);
    DECLARE @no_show_status_id INT;

    -- Validar que el vuelo exista
    SELECT
        @is_closed     = fi.is_manifest_closed,
        @flight_status = fi.status_code,
        @aircraft_id   = fi.aircraft_id
    FROM flight_instances fi
    WHERE fi.id = @flight_id;

    IF @aircraft_id IS NULL
    BEGIN
        RAISERROR('sp_cerrar_vuelo: el vuelo #%d no existe.', 16, 1, @flight_id);
        RETURN;
    END;

    IF @is_closed = 1
    BEGIN
        RAISERROR('sp_cerrar_vuelo: el vuelo #%d ya fue cerrado.', 16, 1, @flight_id);
        RETURN;
    END;

    IF @flight_status = 'CANCELLED'
    BEGIN
        RAISERROR('sp_cerrar_vuelo: el vuelo #%d esta cancelado.', 16, 1, @flight_id);
        RETURN;
    END;

    -- Calcular MTOW estimado: 20.000 kg base + 80 kg x capacidad maxima
    SELECT @mtow_kg = 20000.0 + (80.0 * at2.max_pax_capacity)
    FROM aircrafts a
    JOIN aircraft_types at2 ON a.aircraft_type_id = at2.id
    WHERE a.id = @aircraft_id;

    -- Marcar como NO_SHOW a quienes hicieron check-in pero no abordaron
    UPDATE check_ins
    SET    status = 'NO_SHOW'
    WHERE  flight_instance_id = @flight_id
      AND  status = 'CHECKED_IN';

    -- Propagar NO_SHOW a las reservas en bookings (M3)
    SELECT @no_show_status_id = id
    FROM   booking_statuses
    WHERE  code = 'NO_SHOW';

    UPDATE b
    SET    b.status_id = @no_show_status_id
    FROM   bookings b
    JOIN   check_ins ci ON ci.booking_id = b.id
    WHERE  ci.flight_instance_id = @flight_id
      AND  ci.status = 'NO_SHOW';

    -- Calcular totales de pasajeros
    SELECT
        @total_boarded  = SUM(CASE WHEN status = 'BOARDED'  THEN 1 ELSE 0 END),
        @total_no_shows = SUM(CASE WHEN status = 'NO_SHOW'  THEN 1 ELSE 0 END)
    FROM check_ins
    WHERE flight_instance_id = @flight_id;

    -- Calcular peso de equipaje bodega de pasajeros que abordaron
    SELECT @baggage_weight_kg = ISNULL(SUM(bt.weight_kg), 0)
    FROM   baggage_tags bt
    JOIN   check_ins ci ON bt.check_in_id = ci.id
    WHERE  ci.flight_instance_id = @flight_id
      AND  ci.status   = 'BOARDED'
      AND  bt.bag_type = 'HOLD';

    -- Peso estimado: 80 kg promedio por pasajero
    SET @est_pax_weight = ISNULL(@total_boarded, 0) * 80.0;

    -- Generar manifiesto final
    INSERT INTO flight_manifests (
        flight_instance_id,
        total_boarded,
        total_no_shows,
        baggage_weight_kg,
        estimated_pax_weight_kg,
        max_takeoff_weight_kg,
        closed_at
    )
    VALUES (
        @flight_id,
        ISNULL(@total_boarded,  0),
        ISNULL(@total_no_shows, 0),
        @baggage_weight_kg,
        @est_pax_weight,
        @mtow_kg,
        GETDATE()
    );

    -- Marcar vuelo como cerrado (columna preparada por M2)
    UPDATE flight_instances
    SET    is_manifest_closed = 1
    WHERE  id = @flight_id;

    -- Devolver resumen del manifiesto
    SELECT
        fm.flight_instance_id,
        fs.flight_number           AS numero_vuelo,
        fi.flight_date             AS fecha_vuelo,
        r.origin_iata_code         AS origen,
        r.dest_iata_code           AS destino,
        fm.total_boarded           AS pasajeros_embarcados,
        fm.total_no_shows          AS no_shows,
        sc.total_seats             AS capacidad_aeronave,
        fm.baggage_weight_kg       AS peso_equipaje_kg,
        fm.estimated_pax_weight_kg AS peso_pasajeros_kg,
        fm.total_weight_kg         AS peso_total_kg,
        fm.max_takeoff_weight_kg   AS mtow_kg,
        fm.load_factor_pct         AS factor_carga_pct,
        CASE
            WHEN fm.load_factor_pct > 95 THEN 'CRITICO'
            WHEN fm.load_factor_pct > 85 THEN 'ALERTA'
            ELSE 'OK'
        END                        AS balance_carga,
        fm.closed_at               AS cerrado_a
    FROM flight_manifests fm
    JOIN flight_instances   fi ON fm.flight_instance_id = fi.id
    JOIN flight_schedules   fs ON fi.flight_schedule_id = fs.id
    JOIN routes              r ON fs.route_id           = r.id
    JOIN aircrafts           a ON fi.aircraft_id        = a.id
    JOIN seat_configurations sc ON a.seat_config_id    = sc.id
                               AND a.aircraft_type_id  = sc.aircraft_type_id
    WHERE fm.flight_instance_id = @flight_id;
END;
