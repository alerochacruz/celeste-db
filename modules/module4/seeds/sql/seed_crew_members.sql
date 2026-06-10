-- Obtenemos IDs de roles para insertar
DECLARE @CapId INT = (SELECT id FROM crew_roles WHERE role_name = 'Captain');
DECLARE @FOId INT = (SELECT id FROM crew_roles WHERE role_name = 'First Officer');
DECLARE @PurserId INT = (SELECT id FROM crew_roles WHERE role_name = 'Purser');
DECLARE @CabinId INT = (SELECT id FROM crew_roles WHERE role_name = 'Cabin Crew');

INSERT INTO crew_members (first_name, last_name, crew_role_id, hire_date, email, phone, languages) VALUES
('John', 'Smith', @CapId, '2015-05-12', 'john.smith@celeste.com', '+1-555-0199', 'English, Spanish'),
('Maria', 'Gonzalez', @CapId, '2018-03-24', 'maria.gonzalez@celeste.com', '+34-600-123456', 'Spanish, English, Portuguese'),
('David', 'Chen', @FOId, '2020-11-01', 'david.chen@celeste.com', '+86-139-0101-0101', 'English, Mandarin'),
('Sophie', 'Dubois', @FOId, '2021-06-15', 'sophie.dubois@celeste.com', '+33-6-1234-5678', 'French, English'),
('Emily', 'Watson', @PurserId, '2016-08-10', 'emily.watson@celeste.com', '+44-20-7946-0192', 'English, German'),
('Carlos', 'Silva', @PurserId, '2017-09-05', 'carlos.silva@celeste.com', '+55-11-99999-1111', 'Portuguese, Spanish, English'),
('Alice', 'Tan', @CabinId, '2022-02-18', 'alice.tan@celeste.com', '+65-9123-4567', 'English, Malay, Mandarin'),
('Elena', 'Petrova', @CabinId, '2021-04-20', 'elena.petrova@celeste.com', '+7-903-123-4567', 'Russian, English'),
('Hans', 'Müller', @CabinId, '2023-01-15', 'hans.mueller@celeste.com', '+49-170-1234567', 'German, English'),
('Lucia', 'Rossi', @CabinId, '2022-07-01', 'lucia.rossi@celeste.com', '+39-333-1234567', 'Italian, French, English');
