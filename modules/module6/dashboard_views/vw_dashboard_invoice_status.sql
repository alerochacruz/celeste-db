CREATE OR ALTER VIEW vw_dashboard_invoice_status AS
SELECT
    i.status,
    COUNT(i.id) AS invoice_count,
    CAST(SUM(i.total_amount) AS DECIMAL(10,2)) AS total_amount,
    CAST(SUM(CASE WHEN i.status = 'PAID' THEN i.total_amount ELSE 0 END) AS DECIMAL(10,2)) AS paid_amount,
    CAST(AVG(i.total_amount) AS DECIMAL(10,2)) AS avg_invoice_amount
FROM invoices i
GROUP BY
    i.status;
GO
