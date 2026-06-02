CREATE TABLE maintenance_status (
    id             INT IDENTITY(1,1) NOT NULL,
    status_code    VARCHAR(30)  NOT NULL,  -- 'OPERATIONAL', 'MAINTENANCE', 'GROUNDED'
    description    VARCHAR(100) NULL,
    is_operational BIT          NOT NULL DEFAULT 0,
    CONSTRAINT PK_maintenance_status PRIMARY KEY (id),
    CONSTRAINT UQ_maintenance_status_code UNIQUE (status_code)
);
