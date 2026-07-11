-- Datos de los pasajeros a registrar
-- -----------------------------------------------------------------------------
-- Caso 1

-- Titular:        Ana García     - DNI 40111222 - AR
-- Acompañantes:   Bruno García   - DNI 45222333 - AR
--                 Clara Vega     - DNI 42333444 - AR

-- Caso 2 - Cancelacion
-- Individual:     Diego Ruiz     - DNI 38444555 - AR

-- Caso 3 - Overbooking
-- Adicional:      Elena Pérez    - DNI 41555666 - AR

-- 1. Registrar titular de la reserva familiar
EXEC sp_register_passenger
    @document_type    = 'DNI',
    @document_number  = '40111222',
    @first_name       = 'Ana',
    @last_name        = 'García',
    @birth_date       = '1988-04-12',
    @nationality_code = 'AR',
    @email            = 'ana.garcia@mail.com',
    @phone            = '+541199001001';

-- 2. Registrar acompañante menor de edad - Sin telefono ni email
EXEC sp_register_passenger
    @document_type    = 'DNI',
    @document_number  = '45222333',
    @first_name       = 'Bruno',
    @last_name        = 'García',
    @birth_date       = '2015-07-20',
    @nationality_code = 'AR';

-- 3. Registrar acompañante adulto.

EXEC sp_register_passenger
    @document_type    = 'DNI',
    @document_number  = '42333444',
    @first_name       = 'Clara',
    @last_name        = 'Vega',
    @birth_date       = '1990-02-05',
    @nationality_code = 'AR',
    @email            = 'clara.vega@mail.com',
    @phone            = '+541199001003';


-- CASO 2 - Cancelación posterior
-- 4. Registrar pasajero individual.

EXEC sp_register_passenger
    @document_type    = 'DNI',
    @document_number  = '38444555',
    @first_name       = 'Diego',
    @last_name        = 'Ruiz',
    @birth_date       = '1982-11-30',
    @nationality_code = 'AR',
    @email            = 'diego.ruiz@mail.com',
    @phone            = '+541199001004';

-- CASO 3 - Overbooking
-- 5. Registrar pasajero adicional
EXEC sp_register_passenger
    @document_type    = 'DNI',
    @document_number  = '41555666',
    @first_name       = 'Elena',
    @last_name        = 'Pérez',
    @birth_date       = '1993-06-18',
    @nationality_code = 'AR',
    @email            = 'elena.perez@mail.com',
    @phone            = '+541199001005';