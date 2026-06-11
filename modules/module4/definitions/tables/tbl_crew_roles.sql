CREATE TABLE crew_roles (
    id          INT IDENTITY(1,1) NOT NULL,
    role_name   VARCHAR(50) NOT NULL, -- e.g. 'Captain', 'First Officer', 'Purser', 'Cabin Crew'
    description VARCHAR(200) NULL,

    CONSTRAINT PK_crew_roles
        PRIMARY KEY (id),

    CONSTRAINT UQ_crew_roles_name
        UNIQUE (role_name)
);
