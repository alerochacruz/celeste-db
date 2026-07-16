CREATE OR ALTER VIEW vw_dashboard_revenue_by_flight AS
WITH invoice_totals AS
(
    SELECT
        i.flight_instance_id,
        COUNT(i.id) AS invoice_count,
        CAST(SUM(i.total_amount) AS DECIMAL(10,2)) AS total_invoice_amount,
        CAST(SUM(CASE WHEN i.status = 'PAID' THEN i.total_amount ELSE 0 END) AS DECIMAL(10,2)) AS paid_revenue,
        CAST(SUM(CASE WHEN i.status = 'PENDING' THEN i.total_amount ELSE 0 END) AS DECIMAL(10,2)) AS pending_amount,
        CAST(SUM(CASE WHEN i.status = 'CANCELLED' THEN i.total_amount ELSE 0 END) AS DECIMAL(10,2)) AS cancelled_amount
    FROM invoices i
    GROUP BY
        i.flight_instance_id
)
SELECT
    fi.id AS flight_instance_id,
    fs.flight_number,
    fi.flight_date,
    fi.status_code,
    CONCAT(r.origin_iata_code, ' -> ', r.dest_iata_code) AS route_code,
    COALESCE(it.invoice_count, 0) AS invoice_count,
    COALESCE(it.total_invoice_amount, 0) AS total_invoice_amount,
    COALESCE(it.paid_revenue, 0) AS paid_revenue,
    COALESCE(it.pending_amount, 0) AS pending_amount,
    COALESCE(it.cancelled_amount, 0) AS cancelled_amount
FROM flight_instances fi
INNER JOIN flight_schedules fs
    ON fs.id = fi.flight_schedule_id
INNER JOIN routes r
    ON r.id = fs.route_id
LEFT JOIN invoice_totals it
    ON it.flight_instance_id = fi.id;
GO
