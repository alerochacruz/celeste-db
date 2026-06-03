CREATE TABLE aircrafts (
    id                    INT IDENTITY(1,1) NOT NULL,

    registration_number   VARCHAR(20) NOT NULL,

    aircraft_type_id      INT NOT NULL,
    seat_config_id        INT NOT NULL,

    current_status_id     INT NOT NULL,

    manufactured_date     DATE NULL,
    last_maintenance_date DATE NULL,

    notes                 VARCHAR(200) NULL,

    CONSTRAINT PK_aircrafts
        PRIMARY KEY (id),

    CONSTRAINT UQ_aircrafts_registration
        UNIQUE (registration_number),

    CONSTRAINT FK_aircrafts_status
        FOREIGN KEY (current_status_id)
        REFERENCES maintenance_status(id),

    CONSTRAINT FK_aircrafts_configuration
        FOREIGN KEY (seat_config_id, aircraft_type_id) -- Composite foreign key
        REFERENCES seat_configurations (
            id,
            aircraft_type_id
        )
);
