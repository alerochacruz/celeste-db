CREATE TABLE booking_statuses
(
    id          INT IDENTITY (1,1) NOT NULL,
    code        VARCHAR(20)        NOT NULL, -- 'PENDING', 'CONFIRMED', 'CANCELLED', 'NO_SHOW'
    description VARCHAR(100)       NULL,

    CONSTRAINT PK_booking_statuses PRIMARY KEY (id),
    CONSTRAINT UQ_booking_statuses_code UNIQUE (code)
);