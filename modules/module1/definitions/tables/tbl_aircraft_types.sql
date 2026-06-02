CREATE TABLE aircraft_types (
    id               INT IDENTITY(1,1) NOT NULL,
    manufacturer     VARCHAR(50)  NOT NULL,  -- e.g. 'Airbus', 'ATR'
    model            VARCHAR(50)  NOT NULL,  -- e.g. 'A320-214', '72-500'
    engine_type      VARCHAR(50)  NULL,
    max_pax_capacity SMALLINT     NOT NULL,
    CONSTRAINT PK_aircraft_types PRIMARY KEY (id),
    CONSTRAINT UQ_aircraft_types_model UNIQUE (manufacturer, model),
    CONSTRAINT CK_aircraft_types_capacity CHECK (max_pax_capacity > 0)
);
