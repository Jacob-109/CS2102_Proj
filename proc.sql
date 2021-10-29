-- CREATE OR REPLACE PROCEDURE <procedure name>
-- 	(<param> <type>,
-- 	<param> <type>)
-- AS $$
-- BEGIN
-- 	<code>
-- END;
-- $$
-- LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE add_department 
	(did integer,
	dname VARCHAR(255))
AS $$
BEGIN
	INSERT INTO departments VALUES (did, dname);
END;
$$
LANGUAGE plpgsql;

-- CREATE OR REPLACE PROCEDURE remove_department
-- 	(r_did integer,
-- 	n_did integer)
-- AS $$
-- BEGIN
-- 	I
-- END;
-- $$
-- LANGUAGE plpgsql;


CREATE OR REPLACE PROCEDURE add_room
	(floor integer,
	room integer,
	rname VARCHAR(255),
	cap integer,
	did integer,
	udate DATE,
	eid integer)
AS $$
BEGIN
	IF EXISTS(SELECT 1 FROM manager m department d WHERE m.eid = eid AND d.did = did)
		THEN
			INSERT INTO meetingRooms VALUES (room, floor, did, rname);
			INSERT INTO mr_update VALUES (eid, udate, cap, room, floor);
	END IF;
END;
$$
LANGUAGE plpgsql;

-- CREATE OR REPLACE PROCEDURE <procedure name>
-- 	(eid integer,
-- 	<param> <type>)
-- AS $$
-- BEGIN
-- 	<code>
-- END;
-- $$
-- LANGUAGE plpgsql;

