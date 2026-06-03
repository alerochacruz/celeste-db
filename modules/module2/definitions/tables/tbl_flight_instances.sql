CREATE TABLE flight_instances (
    id                 INT IDENTITY(1,1) NOT NULL,
    flight_schedule_id INT          NOT NULL,   -- FK → flight_schedules.id
    aircraft_id        INT          NOT NULL,   -- FK → aircrafts.id
    flight_date        DATE         NOT NULL,
    actual_departure_time DATETIME NULL,
    actual_arrival_time   DATETIME NULL,
    status_code        VARCHAR(20)  NOT NULL DEFAULT 'SCHEDULED', 
                       -- e.g. 'SCHEDULED', 'DELAYED', 'CANCELLED', 'COMPLETED'
                       
    -- IMPORTANT: Crucial anchor column to easily support M5's sp_close_flight
    is_manifest_closed    BIT          NOT NULL DEFAULT 0,

    CONSTRAINT PK_flight_instances PRIMARY KEY (id),
    CONSTRAINT FK_flight_instances_schedule
        FOREIGN KEY (flight_schedule_id) REFERENCES flight_schedules(id),
    CONSTRAINT FK_flight_instances_aircraft
        FOREIGN KEY (aircraft_id) REFERENCES aircrafts(id),
    CONSTRAINT CK_flight_instances_actual_times 
        CHECK (actual_arrival_time >= actual_departure_time)
);
