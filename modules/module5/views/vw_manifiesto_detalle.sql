SET QUOTED_IDENTIFIER ON;
GO
CREATE OR ALTER VIEW vw_manifiesto_detalle AS
SELECT
    ci.flight_instance_id,
    fs.flight_number                   AS numero_vuelo,
    fi.flight_date                     AS fecha_vuelo,
    r.origin_iata_code                 AS origen,
    r.dest_iata_code                   AS destino,
    p.first_name + ' ' + p.last_name  AS pasajero,
    p.document_type                    AS tipo_documento,
    p.document_number                  AS numero_documento,
    sa.seat_number                     AS asiento,
    sa.class                           AS clase,
    bg.group_name                      AS grupo_abordaje,
    ci.boarding_pass_code              AS boarding_pass,
    ci.channel                         AS canal_checkin,
    ci.checked_in_at                   AS hora_checkin,
    ci.status                          AS estado,
    ISNULL(SUM(bt.weight_kg), 0)      AS equipaje_bodega_kg,
    COUNT(bt.id)                       AS piezas_equipaje
FROM check_ins ci
JOIN passengers       p  ON ci.passenger_id       = p.id
JOIN seat_assignments sa ON ci.seat_assignment_id = sa.id
JOIN boarding_groups  bg ON ci.boarding_group_id  = bg.id
JOIN flight_instances fi ON ci.flight_instance_id = fi.id
JOIN flight_schedules fs ON fi.flight_schedule_id = fs.id
JOIN routes            r ON fs.route_id           = r.id
LEFT JOIN baggage_tags bt ON bt.check_in_id = ci.id
                         AND bt.bag_type    = 'HOLD'
GROUP BY
    ci.flight_instance_id, fs.flight_number, fi.flight_date,
    r.origin_iata_code, r.dest_iata_code,
    p.first_name, p.last_name, p.document_type, p.document_number,
    sa.seat_number, sa.class, bg.group_name,
    ci.boarding_pass_code, ci.channel, ci.checked_in_at, ci.status;
