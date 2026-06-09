CREATE TABLE seat_assignments
(
    id                 INT IDENTITY (1,1) NOT NULL,
    passenger_id       INT                NOT NULL,
    booking_id         INT                NOT NULL,
    flight_instance_id INT                NOT NULL,
    seat_number        VARCHAR(5)         NOT NULL,
    class              VARCHAR(10)        NOT NULL,                                         --ECONOMY, BUSINESS
    assigned_at        DATETIME           NOT NULL DEFAULT GETDATE(),

    CONSTRAINT PK_seat_assignments PRIMARY KEY (id),
    CONSTRAINT FK_seat_assignments_passenger
        FOREIGN KEY (passenger_id) REFERENCES passengers (id),
    CONSTRAINT FK_seat_assignments_booking
        FOREIGN KEY (booking_id) REFERENCES bookings (id),
    CONSTRAINT FK_seat_assignments_flight_instance
        FOREIGN KEY (flight_instance_id) REFERENCES flight_instances (id),
    CONSTRAINT UQ_seat_assignments_seat UNIQUE (flight_instance_id, seat_number),           -- No puede haber dos pasajeros del mismo vuelo en el mismo asiento
    CONSTRAINT UQ_seat_assignments_passenger_per_booking UNIQUE (passenger_id, booking_id), -- No puede repetirse pasajero en misma reserva
    CONSTRAINT CK_seat_assignments_class CHECK (class IN ('ECONOMY', 'BUSINESS'))
);