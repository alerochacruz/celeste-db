-- Equipaje registrado para los check-ins del seed
-- check_in_id 1=Martín, 2=Sofia, 3=Joao, 4=Pierre, 5=Yuki, 6=Mateo, 7=Anna

INSERT INTO baggage_tags (check_in_id, tag_code, weight_kg, bag_type, status)
VALUES
    (1, 'TAG-MARTIN-01', 22.50, 'HOLD',  'LOADED'),  -- Martín (BOARDED)
    (2, 'TAG-SOFIA--02', 18.00, 'HOLD',  'TAGGED'),  -- Sofia  (NO_SHOW, no se cargo)
    (3, 'TAG-JOAO--03A', 20.00, 'HOLD',  'LOADED'),  -- Joao   (BOARDED)
    (3, 'TAG-JOAO--03B',  8.50, 'CABIN', 'LOADED'),  -- Joao   equipaje de mano
    (4, 'TAG-PIERRE-04', 25.00, 'HOLD',  'LOADED'),  -- Pierre (BOARDED)
    (5, 'TAG-YUKI--05',  15.00, 'HOLD',  'TAGGED'),  -- Yuki   (CHECKED_IN, pendiente)
    (6, 'TAG-MATEO-06',  19.50, 'HOLD',  'LOADED'),  -- Mateo  (BOARDED)
    (7, 'TAG-ANNA--07',  23.00, 'HOLD',  'LOADED');  -- Anna   (BOARDED)
