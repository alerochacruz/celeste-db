CREATE TABLE crew_certifications (
    id                   INT IDENTITY(1,1) NOT NULL,
    crew_member_id       INT NOT NULL,
    aircraft_type_id     INT NOT NULL,
    issue_date           DATE NOT NULL,
    expiration_date      DATE NOT NULL,
    certification_number VARCHAR(50) NOT NULL,

    CONSTRAINT PK_crew_certifications
        PRIMARY KEY (id),

    CONSTRAINT FK_crew_certifications_member
        FOREIGN KEY (crew_member_id)
        REFERENCES crew_members(id),

    CONSTRAINT FK_crew_certifications_aircraft_type
        FOREIGN KEY (aircraft_type_id)
        REFERENCES aircraft_types(id),

    CONSTRAINT UQ_crew_certifications_number
        UNIQUE (certification_number),

    CONSTRAINT CK_crew_certifications_dates
        CHECK (expiration_date > issue_date)
);
