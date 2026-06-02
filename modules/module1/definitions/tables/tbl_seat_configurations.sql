CREATE TABLE seat_configurations (
    id               INT IDENTITY(1,1) NOT NULL,
    aircraft_type_id INT          NOT NULL,
    name             VARCHAR(50)  NOT NULL,  -- e.g. 'A320 High-Density'
    economy_seats    SMALLINT     NOT NULL DEFAULT 0,
    business_seats   SMALLINT     NOT NULL DEFAULT 0,
    total_seats      AS (economy_seats + business_seats) PERSISTED,
    CONSTRAINT PK_seat_configurations PRIMARY KEY (id),
    CONSTRAINT FK_seat_config_type
        FOREIGN KEY (aircraft_type_id) REFERENCES aircraft_types(id),
    CONSTRAINT CK_seat_config_economy  CHECK (economy_seats  >= 0),
    CONSTRAINT CK_seat_config_business CHECK (business_seats >= 0),
    CONSTRAINT CK_seat_config_total    CHECK (economy_seats + business_seats > 0)
);
