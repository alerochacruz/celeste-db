CREATE TABLE crew_assignments (
    id                 INT IDENTITY(1,1) NOT NULL,
    flight_instance_id INT NOT NULL,
    crew_member_id     INT NOT NULL,

    CONSTRAINT PK_crew_assignments
        PRIMARY KEY (id),

    CONSTRAINT FK_crew_assignments_flight_instance
        FOREIGN KEY (flight_instance_id)
        REFERENCES flight_instances(id),

    CONSTRAINT FK_crew_assignments_crew_member
        FOREIGN KEY (crew_member_id)
        REFERENCES crew_members(id),

    CONSTRAINT UQ_crew_assignments_member_flight
        UNIQUE (flight_instance_id, crew_member_id)
);
