CREATE TABLE invoices
(
    id                 INT IDENTITY (1,1) NOT NULL,
    booking_id         INT                NOT NULL,
    flight_instance_id INT                NOT NULL,

    base_fare          DECIMAL(10,2)      NOT NULL,
    taxes              DECIMAL(10,2)      NOT NULL DEFAULT (0),
    extras             DECIMAL(10,2)      NOT NULL DEFAULT (0),

    total_amount AS (base_fare + taxes + extras) PERSISTED,

    status             VARCHAR(20)        NOT NULL DEFAULT ('PENDING'),

    issue_date         DATETIME           NOT NULL DEFAULT GETDATE(),
    payment_date       DATETIME           NULL,

    CONSTRAINT PK_invoices
        PRIMARY KEY (id),

    CONSTRAINT UQ_invoices_booking
        UNIQUE (booking_id),

    CONSTRAINT FK_invoices_booking
        FOREIGN KEY (booking_id)
        REFERENCES bookings(id),

    CONSTRAINT FK_invoices_flight_instance
        FOREIGN KEY (flight_instance_id)
        REFERENCES flight_instances(id),

    CONSTRAINT CK_invoices_status
        CHECK (status IN ('PENDING','PAID','CANCELLED')),

    CONSTRAINT CK_invoices_amounts
        CHECK
        (
            base_fare >= 0
            AND taxes >= 0
            AND extras >= 0
        )
);
