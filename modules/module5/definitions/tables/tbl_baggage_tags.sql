CREATE TABLE baggage_tags (
    id          INT IDENTITY(1,1) NOT NULL,
    check_in_id INT          NOT NULL,
    tag_code    VARCHAR(20)  NOT NULL,
    weight_kg   DECIMAL(5,2) NOT NULL,
    bag_type    VARCHAR(10)  NOT NULL DEFAULT 'HOLD',
    status      VARCHAR(20)  NOT NULL DEFAULT 'TAGGED',

    CONSTRAINT PK_baggage_tags
        PRIMARY KEY (id),
    CONSTRAINT FK_baggage_tags_ci
        FOREIGN KEY (check_in_id) REFERENCES check_ins(id),
    CONSTRAINT UQ_baggage_tags_code
        UNIQUE (tag_code),
    CONSTRAINT CK_baggage_tags_weight
        CHECK (weight_kg > 0),
    CONSTRAINT CK_baggage_tags_type
        CHECK (bag_type IN ('HOLD','CABIN','SPECIAL')),
    CONSTRAINT CK_baggage_tags_status
        CHECK (status IN ('TAGGED','LOADED','DELIVERED','MISSING'))
);
