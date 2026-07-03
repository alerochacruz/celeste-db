CREATE TYPE dbo.booking_seat_input AS TABLE (
    passenger_id INT          NOT NULL,
    seat_number  VARCHAR(5)   NOT NULL,
    class        VARCHAR(10)  NOT NULL
);
GO