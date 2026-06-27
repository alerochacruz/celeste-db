CREATE TABLE boarding_groups (
    id                  INT IDENTITY(1,1) NOT NULL,
    flight_instance_id  INT         NOT NULL,
    group_number        TINYINT     NOT NULL,
    group_name          VARCHAR(50) NOT NULL,
    boarding_order      TINYINT     NOT NULL,
    boarding_started_at DATETIME    NULL,

    CONSTRAINT PK_boarding_groups
        PRIMARY KEY (id),
    CONSTRAINT FK_boarding_groups_flight
        FOREIGN KEY (flight_instance_id) REFERENCES flight_instances(id),
    CONSTRAINT UQ_boarding_groups_flight_group
        UNIQUE (flight_instance_id, group_number),
    CONSTRAINT CK_boarding_groups_number
        CHECK (group_number > 0),
    CONSTRAINT CK_boarding_groups_order
        CHECK (boarding_order > 0)
);
