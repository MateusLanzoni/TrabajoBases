
CREATE TABLE environments (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL
);


CREATE TABLE fighters (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    birth_date DATE NOT NULL,
    nickname VARCHAR(100),
    is_robot BOOLEAN NOT NULL,
    wins INT DEFAULT 0
);


CREATE TABLE fights (
    id SERIAL PRIMARY KEY,
    enviroment_id INT NOT NULL,
    date DATE NOT NULL,
    id_winner INT,
    FOREIGN KEY (enviroment_id) REFERENCES environments(id) ON DELETE CASCADE,
    FOREIGN KEY (id_winner) REFERENCES fighters(id)
);




CREATE TABLE fights_participants (
    fight_id INT NOT NULL,
    fighter_id INT NOT NULL,
    PRIMARY KEY (fight_id, fighter_id),
    FOREIGN KEY (fight_id) REFERENCES fights(id) ON DELETE CASCADE,
    FOREIGN KEY (fighter_id) REFERENCES fighters(id) ON DELETE CASCADE
);


CREATE TABLE weapons (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL
);


CREATE TABLE fight_weapons (
    fight_id INT NOT NULL,
    weapon_id INT NOT NULL,
    PRIMARY KEY (fight_id, weapon_id),
    FOREIGN KEY (fight_id) REFERENCES fights(id) ON DELETE CASCADE,
    FOREIGN KEY (weapon_id) REFERENCES weapons(id) ON DELETE CASCADE
);



INSERT INTO environments (name)
VALUES
('The Steel Cage Warehouse'),
('The Skyline Roof Arena'),
('The Tech Lab'),
('The Concrete Jungle');



INSERT INTO fighters (name, birth_date, nickname, is_robot, wins)
VALUES
('John Doe', '1985-05-10', 'The Destroyer', false, 10),
('Robot X', '2020-01-01', 'X-Terminator', true, 5),
('Sarah Connor', '1990-03-12', 'The Survivor', false, 20),
('T-800', '2025-05-10', 'Terminator', true, 15);


INSERT INTO weapons (name)
VALUES
('Sword'),
('Laser Gun'),
('Flamethrower'),
('Grenade');



CREATE OR REPLACE FUNCTION recalculate_wins_for_winner()
RETURNS TRIGGER AS $$
BEGIN

    UPDATE fighters
    SET wins = (SELECT COUNT(*) FROM fights WHERE id_winner = NEW.id_winner)
    WHERE id = NEW.id_winner;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;


CREATE TRIGGER recalculate_wins_after_fight
AFTER INSERT ON fights
FOR EACH ROW
EXECUTE FUNCTION recalculate_wins_for_winner();



INSERT INTO fights (enviroment_id, date, id_winner)
VALUES
(1, '2024-10-01', 1),
(2, '2024-10-02', 2),
(3, '2024-10-03', 3),
(4, '2024-10-04', 4);



INSERT INTO fights_participants (fight_id, fighter_id)
VALUES
(1, 1),
(1, 2),
(2, 2),
(2, 3),
(3, 3),
(3, 4),
(4, 1),
(4, 4);


INSERT INTO fight_weapons (fight_id, weapon_id)
VALUES
(1, 1),
(1, 2),
(2, 3),
(2, 4),
(3, 2),
(4, 1),
(4, 4);



INSERT INTO fights (enviroment_id, date, id_winner)
VALUES
(1, '2024-10-14', 1);


INSERT INTO fights_participants (fight_id, fighter_id)
VALUES
(5, 1),
(5, 2);


INSERT INTO fight_weapons (fight_id, weapon_id)
VALUES
(5, 1),
(5, 2);



CREATE TYPE organization_enum AS ENUM ('NBA', 'ACB', 'Underground Martial Arts');


ALTER TABLE fighters ADD COLUMN organization organization_enum;


UPDATE fighters SET organization = 'NBA' WHERE id = 1;
UPDATE fighters SET organization = 'ACB' WHERE id = 2;
UPDATE fighters SET organization = 'Underground Martial Arts' WHERE id = 3;
UPDATE fighters SET organization = 'NBA' WHERE id = 4;



INSERT INTO weapons (name)
VALUES ('Robot X');


INSERT INTO fights (enviroment_id, date, id_winner)
VALUES
(1, '2024-10-14', 2);


INSERT INTO fights_participants (fight_id, fighter_id)
VALUES
(6, 2),
(6, 3);


INSERT INTO fight_weapons (fight_id, weapon_id)
VALUES
(6, (SELECT id FROM weapons WHERE name = 'Robot X'));

--Querie 1
SELECT *
FROM fighters
WHERE organization = 'NBA';

--Querie 2
SELECT *
FROM fighters
ORDER BY wins DESC
LIMIT 1;

--Querie 3
SELECT w.name, COUNT(fw.weapon_id) AS usage_count
FROM fight_weapons fw
JOIN weapons w ON fw.weapon_id = w.id
GROUP BY w.name
ORDER BY usage_count DESC
LIMIT 1;

--Querie 4
SELECT e.name, COUNT(f.enviroment_id) AS fight_count
FROM fights f
JOIN environments e ON f.enviroment_id = e.id
GROUP BY e.name
ORDER BY fight_count DESC
LIMIT 1;

--Querie 5
SELECT f.*
FROM fights f
JOIN fight_weapons fw ON f.id = fw.fight_id
JOIN weapons w ON fw.weapon_id = w.id
JOIN fighters fi ON w.name = fi.name
WHERE fi.is_robot = true;
