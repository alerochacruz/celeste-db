SET QUOTED_IDENTIFIER ON;
GO

CREATE OR ALTER PROCEDURE sp_register_passenger
    @document_type    VARCHAR(10),
    @document_number  VARCHAR(20),
    @first_name       VARCHAR(50),
    @last_name        VARCHAR(50),
    @birth_date       DATE,
    @nationality_code CHAR(2),
    @email            VARCHAR(100) = NULL,
    @phone            VARCHAR(20)  = NULL
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @passenger_id INT;

    -- Validacion DNI
    IF @document_type NOT IN ('DNI', 'PASSPORT')
    BEGIN
        RAISERROR('sp_register_passenger: tipo de documento invalido "%s". Valores permitidos: DNI, PASSPORT.', 16, 1, @document_type);
        RETURN;
    END;

    -- Unicidad documento
    IF EXISTS (
        SELECT 1 FROM passengers
        WHERE document_type = @document_type
          AND document_number = @document_number
    )
    BEGIN
        RAISERROR('sp_register_passenger: ya existe un pasajero con documento %s %s.', 16, 1, @document_type, @document_number);
        RETURN;
    END;

    -- Insertar pasajero
    INSERT INTO passengers (
        document_type, document_number,
        first_name, last_name,
        birth_date, nationality_code,
        email, phone
    )
    VALUES (
        @document_type, @document_number,
        @first_name, @last_name,
        @birth_date, @nationality_code,
        @email, @phone
    );

    SET @passenger_id = SCOPE_IDENTITY();

    -- Devolver resumen del pasajero creado
    SELECT
        p.id                                AS pasajero_id,
        p.document_type                     AS tipo_documento,
        p.document_number                   AS numero_documento,
        p.first_name + ' ' + p.last_name    AS nombre_completo,
        p.birth_date                        AS fecha_nacimiento,
        p.nationality_code                  AS nacionalidad,
        p.email                             AS email,
        p.phone                             AS telefono
    FROM passengers p
    WHERE p.id = @passenger_id;
END;
GO