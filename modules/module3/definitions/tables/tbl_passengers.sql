CREATE TABLE passengers
(
    id               INT IDENTITY (1,1) NOT NULL,
    document_type    VARCHAR(10)        NOT NULL,
    document_number  VARCHAR(20)        NOT NULL,
    first_name       VARCHAR(50)        NOT NULL,
    last_name        VARCHAR(50)        NOT NULL,
    birth_date       DATE               NOT NULL,
    nationality_code CHAR(2)            NOT NULL,
    email            VARCHAR(100)       NULL,
    phone            VARCHAR(20)        NULL,

    CONSTRAINT PK_passengers PRIMARY KEY (id),
    CONSTRAINT UQ_passengers_document UNIQUE (document_type, document_number),
    CONSTRAINT CK_passengers_document_type CHECK (document_type IN ('DNI', 'PASSPORT')),
    CONSTRAINT CK_passengers_nationality_code CHECK (nationality_code LIKE '[A-Z][A-Z]')
);