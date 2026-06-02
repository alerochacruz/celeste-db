CREATE TABLE routes (
    id          INT IDENTITY(1,1) NOT NULL,
    origin_iata_code   CHAR(3)        NOT NULL,   -- FK → airports.iata_code
    dest_iata_code     CHAR(3)        NOT NULL,   -- FK → airports.iata_code
    -- distance_km SMALLINT       NULL,       -- useful for pricing/fuel in later modules
    distance_km DECIMAL(8,2) NULL,   -- precise storage for CSV decimals

    flight_time_minutes SMALLINT NOT NULL,
    is_active   BIT            NOT NULL DEFAULT 1,

    CONSTRAINT PK_routes PRIMARY KEY (id),

    CONSTRAINT FK_routes_origin
        FOREIGN KEY (origin_iata_code) REFERENCES airports(iata_code),

    CONSTRAINT FK_routes_dest
        FOREIGN KEY (dest_iata_code)   REFERENCES airports(iata_code),

    CONSTRAINT CK_routes_no_selfloop
        CHECK (origin_iata_code <> dest_iata_code),

    CONSTRAINT UQ_routes_pair               -- no duplicate O-D pairs
        UNIQUE (origin_iata_code, dest_iata_code),

    CONSTRAINT CK_routes_flight_time
        CHECK (flight_time_minutes > 0)
);
