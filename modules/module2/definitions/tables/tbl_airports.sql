-- airports
CREATE TABLE airports (
    id CHAR(3) NOT NULL, --IATA code
    name VARCHAR(50) NOT NULL,
    full_name VARCHAR(100) NOT NULL,
    timezone VARCHAR(50) NOT NULL,
    country_code CHAR(2) NOT NULL, 
    country VARCHAR(50) NOT NULL,
    CONSTRAINT PK_airports PRIMARY KEY (id),
    CONSTRAINT CK_airports_country_code CHECK (country_code LIKE '[A-Z][A-Z]')
);

