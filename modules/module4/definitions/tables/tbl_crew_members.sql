CREATE TABLE crew_members (
    id            INT IDENTITY(1,1) NOT NULL,
    first_name    VARCHAR(50) NOT NULL,
    last_name     VARCHAR(50) NOT NULL,
    crew_role_id  INT NOT NULL,
    hire_date     DATE NOT NULL,
    email         VARCHAR(100) NULL,
    phone         VARCHAR(30) NULL,
    languages     VARCHAR(200) NULL,
    is_active     BIT NOT NULL DEFAULT 1,

    CONSTRAINT PK_crew_members
        PRIMARY KEY (id),

    CONSTRAINT FK_crew_members_role
        FOREIGN KEY (crew_role_id)
        REFERENCES crew_roles(id),

    CONSTRAINT UQ_crew_members_email
        UNIQUE (email)
);
