INSERT INTO maintenance_status (
    status_code,
    description,
    is_operational
)
VALUES
    ('OPERATIONAL', 'Aircraft is airworthy and available for scheduling', 1),
    ('MAINTENANCE', 'Undergoing scheduled or unscheduled maintenance',    0),
    ('GROUNDED',    'Removed from service, not available for flights',    0);
