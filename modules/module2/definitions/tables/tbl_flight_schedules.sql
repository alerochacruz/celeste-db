CREATE TABLE flight_schedules (
    id                    INT IDENTITY(1,1) NOT NULL,
    route_id              INT          NOT NULL,   -- FK → routes.id
    flight_number         VARCHAR(10)  NOT NULL,   -- e.g. 'AA123'
    
    -- Enforces that every schedule must have designated terminals
    departure_terminal_id INT          NOT NULL,   -- FK → terminals.id
    arrival_terminal_id   INT          NOT NULL,   -- FK → terminals.id
    
    scheduled_departure_time TIME      NOT NULL,   -- local time of origin
    scheduled_arrival_time   TIME      NOT NULL,   -- local time of destination
    days_of_week          VARCHAR(50)  NOT NULL,   -- e.g. 'DAILY', 'MON, WED, FRI'
    is_active             BIT          NOT NULL DEFAULT 1,

    CONSTRAINT PK_flight_schedules PRIMARY KEY (id),
    CONSTRAINT FK_flight_schedules_route
        FOREIGN KEY (route_id) REFERENCES routes(id),
    CONSTRAINT FK_flight_schedules_departure_terminal
        FOREIGN KEY (departure_terminal_id) REFERENCES terminals(id),
    CONSTRAINT FK_flight_schedules_arrival_terminal
        FOREIGN KEY (arrival_terminal_id) REFERENCES terminals(id),
    CONSTRAINT CK_flight_schedules_times
        CHECK (scheduled_departure_time <> scheduled_arrival_time)
);
