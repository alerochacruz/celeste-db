-- terminals
CREATE TABLE terminals (
    id INT IDENTITY(1,1) NOT NULL,
    airport_id CHAR(3) NOT NULL, 
    name VARCHAR(20) NOT NULL,

    CONSTRAINT PK_terminals PRIMARY KEY (id),
    CONSTRAINT FK_terminals_airports 
        FOREIGN KEY (airport_id) REFERENCES airports(id)
        ON DELETE CASCADE 
);

