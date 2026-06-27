CREATE TABLE check_ins (
    id                  INT IDENTITY(1,1) NOT NULL,
    booking_id          INT         NOT NULL,
    flight_instance_id  INT         NOT NULL,
    passenger_id        INT         NOT NULL,
    seat_assignment_id  INT         NOT NULL,
    boarding_group_id   INT         NOT NULL,
    checked_in_at       DATETIME    NOT NULL DEFAULT GETDATE(),
    channel             VARCHAR(20) NOT NULL DEFAULT 'COUNTER',
    boarding_pass_code  VARCHAR(20) NOT NULL,
    status              VARCHAR(20) NOT NULL DEFAULT 'CHECKED_IN',

    CONSTRAINT PK_check_ins
        PRIMARY KEY (id),
    CONSTRAINT FK_check_ins_booking
        FOREIGN KEY (booking_id) REFERENCES bookings(id),
    CONSTRAINT FK_check_ins_flight
        FOREIGN KEY (flight_instance_id) REFERENCES flight_instances(id),
    CONSTRAINT FK_check_ins_passenger
        FOREIGN KEY (passenger_id) REFERENCES passengers(id),
    CONSTRAINT FK_check_ins_seat
        FOREIGN KEY (seat_assignment_id) REFERENCES seat_assignments(id),
    CONSTRAINT FK_check_ins_boarding_group
        FOREIGN KEY (boarding_group_id) REFERENCES boarding_groups(id),
    CONSTRAINT UQ_check_ins_booking
        UNIQUE (booking_id),
    CONSTRAINT UQ_check_ins_boarding_pass
        UNIQUE (boarding_pass_code),
    CONSTRAINT CK_check_ins_channel
        CHECK (channel IN ('COUNTER','WEB','KIOSK','APP')),
    CONSTRAINT CK_check_ins_status
        CHECK (status IN ('CHECKED_IN','BOARDED','NO_SHOW'))
);
