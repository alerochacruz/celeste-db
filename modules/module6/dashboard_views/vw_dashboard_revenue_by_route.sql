CREATE OR ALTER VIEW vw_dashboard_revenue_by_route AS
SELECT
    CONCAT(r.origin_iata_code, ' -> ', r.dest_iata_code) AS route_code,
    r.origin_iata_code,
    r.dest_iata_code,
    COUNT(i.id) AS invoice_count,
    CAST(SUM(CASE WHEN i.status = 'PAID' THEN i.total_amount ELSE 0 END) AS DECIMAL(10,2)) AS paid_revenue,
    CAST(SUM(CASE WHEN i.status = 'PENDING' THEN i.total_amount ELSE 0 END) AS DECIMAL(10,2)) AS pending_amount,
    CAST(SUM(CASE WHEN i.status = 'CANCELLED' THEN i.total_amount ELSE 0 END) AS DECIMAL(10,2)) AS cancelled_amount
FROM invoices i
INNER JOIN flight_instances fi
    ON fi.id = i.flight_instance_id
INNER JOIN flight_schedules fs
    ON fs.id = fi.flight_schedule_id
INNER JOIN routes r
    ON r.id = fs.route_id
GROUP BY
    r.origin_iata_code,
    r.dest_iata_code;
GO
