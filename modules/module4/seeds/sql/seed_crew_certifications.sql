DECLARE @JohnId INT = (SELECT id FROM crew_members WHERE email = 'john.smith@celeste.com');
DECLARE @MariaId INT = (SELECT id FROM crew_members WHERE email = 'maria.gonzalez@celeste.com');
DECLARE @DavidId INT = (SELECT id FROM crew_members WHERE email = 'david.chen@celeste.com');
DECLARE @SophieId INT = (SELECT id FROM crew_members WHERE email = 'sophie.dubois@celeste.com');

DECLARE @A320Id INT = (SELECT id FROM aircraft_types WHERE model = 'A320-214');
DECLARE @ATR500Id INT = (SELECT id FROM aircraft_types WHERE model = '72-500');
DECLARE @ATR600Id INT = (SELECT id FROM aircraft_types WHERE model = '72-600');
DECLARE @ARJId INT = (SELECT id FROM aircraft_types WHERE model = 'ARJ-21-700');

-- John Smith: Certificado para A320 y ATR-600
INSERT INTO crew_certifications (crew_member_id, aircraft_type_id, issue_date, expiration_date, certification_number) VALUES
(@JohnId, @A320Id, '2025-01-01', '2027-01-01', 'CERT-JS-A320'),
(@JohnId, @ATR600Id, '2025-06-01', '2027-06-01', 'CERT-JS-ATR6');

-- Maria Gonzalez: Certificada para ATR-500 y ATR-600
INSERT INTO crew_certifications (crew_member_id, aircraft_type_id, issue_date, expiration_date, certification_number) VALUES
(@MariaId, @ATR500Id, '2024-03-01', '2026-03-01', 'CERT-MG-ATR5'), -- Vence en marzo 2026
(@MariaId, @ATR600Id, '2025-03-01', '2027-03-01', 'CERT-MG-ATR6');

-- David Chen: Certificado para A320 y ARJ-21-700
INSERT INTO crew_certifications (crew_member_id, aircraft_type_id, issue_date, expiration_date, certification_number) VALUES
(@DavidId, @A320Id, '2025-02-15', '2027-02-15', 'CERT-DC-A320'),
(@DavidId, @ARJId, '2025-08-15', '2027-08-15', 'CERT-DC-ARJ');

-- Sophie Dubois: Certificada para ATR-600
INSERT INTO crew_certifications (crew_member_id, aircraft_type_id, issue_date, expiration_date, certification_number) VALUES
(@SophieId, @ATR600Id, '2025-05-01', '2027-05-01', 'CERT-SD-ATR6');
