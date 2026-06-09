CREATE TABLE bookings
(
    id                  INT IDENTITY (1,1) NOT NULL,
    booking_code        VARCHAR(8)         NOT NULL,
    booker_passenger_id INT                NOT NULL,
    flight_instance_id  INT                NOT NULL,
    status_id           INT                NOT NULL,
    booking_date        DATETIME           NOT NULL DEFAULT GETDATE(),
    total_amount        DECIMAL(10, 2)     NULL,

    CONSTRAINT PK_bookings PRIMARY KEY (id),
    CONSTRAINT UQ_bookings_code UNIQUE (booking_code),
    CONSTRAINT FK_bookings_passenger
        FOREIGN KEY (booker_passenger_id) REFERENCES passengers(id),
    CONSTRAINT FK_bookings_flight_instance
        FOREIGN KEY (flight_instance_id) REFERENCES flight_instances(id),
    CONSTRAINT FK_bookings_status
        FOREIGN KEY (status_id) REFERENCES booking_statuses(id),
    CONSTRAINT CK_bookings_total_amount CHECK (total_amount IS NULL OR total_amount >= 0)
);