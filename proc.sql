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

-- requires existing department to replace
CREATE OR REPLACE PROCEDURE remove_department
	(r_did integer,
	n_did integer)
AS $$
BEGIN
	UPDATE employees
	SET did = n_did
	WHERE did = r_did;

	UPDATE meetingRooms
	SET did = n_did
	WHERE did = r_did;

	DELETE FROM departments
	WHERE did = r_did;

END;
$$
LANGUAGE plpgsql;


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
	IF EXISTS(SELECT 1 FROM manager m, departments d WHERE m.eid = eid AND d.did = did)
		THEN
			INSERT INTO meetingRooms VALUES (room, floor, did, rname);
			INSERT INTO mr_update VALUES (eid, udate, cap, room, floor);
	END IF;
END;
$$
LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE add_employee
	(eid integer,
	ename VARCHAR(255),
	email VARCHAR(255),
	did integer,
	kind integer,
	contact integer)
AS $$
BEGIN
	-- IF kind >= 0 AND kind <= 3
	-- 	THEN
			INSERT INTO employees VALUES (eid, ename, email, NULL, did, kind);
			INSERT INTO eContacts VALUES (eid, contact);
			-- IF kind = 0 
			-- THEN	
			-- 	INSERT INTO junior VALUES (eid);
			-- ELSEIF kind = 1 
			-- THEN	
			-- 	INSERT INTO booker VALUES (eid);
			-- 	INSERT INTO senior VALUES (eid);
			-- ELSEIF kind = 2
			-- THEN	
			-- 	INSERT INTO booker VALUES (eid);
			-- 	INSERT INTO manager VALUES (eid);
			-- END IF;
	-- END IF;
END;
$$
LANGUAGE plpgsql;

-- date YYYY-MM-DD
CREATE OR REPLACE PROCEDURE remove_employee
	(id integer,
	r_date DATE)
AS $$
BEGIN
	UPDATE employees
	SET resigned_date = r_date
	WHERE eid = id;

	-- DELETE FROM sessions
	-- WHERE book_id = id AND sdate >= r_date;
	
	-- DELETE FROM session_part
	-- WHERE book_id = id AND sdate >= r_date;
END;
$$
LANGUAGE plpgsql;