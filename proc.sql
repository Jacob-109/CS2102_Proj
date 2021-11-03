-- CREATE OR REPLACE PROCEDURE <procedure name>
-- 	(<param> <type>,
-- 	<param> <type>)
-- AS $$
-- BEGIN
-- 	<code>
-- END;
-- $$
-- LANGUAGE plpgsql;

-- TRIGGER FOR EMPLOYEE RESIGNING
DROP TRIGGER IF EXISTS resigning_employee ON employees;
CREATE TRIGGER resigning_employee
BEFORE UPDATE ON employees
-- RESIGNED DATE IS NOT NULL IMPLIES RESIGNATION
FOR EACH ROW WHEN (NEW.resigned_date IS NOT NULL)
EXECUTE FUNCTION handle_leave_future();

-- LEAVES FUTURE COMMITMENTS
CREATE OR REPLACE FUNCTION handle_leave_future ()
RETURNS TRIGGER
AS $$
BEGIN
	-- DELETE ALL SESSIONS BOOKED 
	DELETE FROM sessions s WHERE s.book_id = NEW.id AND s.sdate >= NEW.r_date;
	-- DELETE ALL SESSION PART AFTER R_DATE
	UPDATE sessions
	SET cap = OLD.cap - 1
	FROM sessions s, session_part sp 
	WHERE sp.eid = NEW.id
	AND s.stime = sp.stime
	AND s.sdate = sp.sdate
	AND s.room = sp.room
	AND s.floor = sp.floor
	AND s.sdate >= NEW.r_date;
	
	DELETE FROM session_part sp WHERE sp.eid = NEW.id AND sp.sdate >= NEW.r_date; 
	RETURN NULL;
END;
$$
LANGUAGE plpgsql;



-- TRIGGER FOR DELETING DEPARTMENT
DROP TRIGGER IF EXISTS del_dep_trig ON departments;
CREATE TRIGGER del_dep_trig
BEFORE DELETE ON departments
FOR EACH ROW
EXECUTE FUNCTION del_dep();

-- SETS meetingRooms did to null to indicate deleted
CREATE OR REPLACE FUNCTION del_dep()
RETURNS TRIGGER
AS $$
BEGIN
	UPDATE meetingRooms
	SET did = NULL
	WHERE did = OLD.did;

	-- Resign employee
	UPDATE employees e 
	SET e.resigned_date = CURRENT_DATE, 
		e.did = NULL
	WHERE e.did = OLD.did;


	RETURN NULL;
END;
$$
LANGUAGE plpgsql;

-- TRIGGER FOR TEMPERATURE DECLARATION
DROP TRIGGER IF EXISTS temp_declared ON health_declaration;
CREATE TRIGGER temp_declared
BEFORE INSERT ON health_declaration
FOR EACH ROW EXECUTE FUNCTION check_fever();


CREATE OR REPLACE FUNCTION check_fever()
RETURNS TRIGGER 
AS $$
BEGIN
	IF NEW.temp > 37.5
	THEN 
		NEW.fever := TRUE;
		DELETE FROM sessions s WHERE s.book_id = NEW.id AND s.sdate >= NEW.r_date;
		DELETE FROM session_part sp WHERE sp.eid = NEW.id AND sp.sdate >= NEW.r_date;
		EXECUTE contact_tracing(NEW.eid); 
	ELSE
		NEW.fever := FALSE;
	END IF;

	RETURN NEW;
END;
$$
LANGUAGE plpgsql;



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
	(did integer)
AS $$
BEGIN
	DELETE FROM departments d WHERE d.did = did;
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
	IF EXISTS(SELECT 1 FROM manager m, employee e 
		WHERE m.eid = eid AND e.eid = eid AND e.did = did)
		THEN
			INSERT INTO meetingRooms VALUES (room, floor, did, rname);
			INSERT INTO mr_update VALUES (eid, udate, cap, room, floor);
	END IF;
END;
$$
LANGUAGE plpgsql;

-- kind 0,1,2
CREATE OR REPLACE PROCEDURE add_employee
	(ename VARCHAR(255),
	email VARCHAR(255),
	did integer,
	kind integer,
	contact integer)
AS $$
DECLARE
	id integer := 0; 
BEGIN
	INSERT INTO employees (ename, email, did, kind) VALUES (ename, email, did, kind);
	SELECT LASTVAL() INTO id;
	INSERT INTO eContacts VALUES (id, contact);
END;
$$
LANGUAGE plpgsql;
	

-- date YYYY-MM-DD
CREATE OR REPLACE PROCEDURE remove_employee
	(id integer,
	r_date DATE)
AS $$
BEGIN
	-- Set resign_date triggers resigning_employee;
	UPDATE employees
	SET resigned_date = r_date
	WHERE eid = id;
END;
$$
LANGUAGE plpgsql;


CREATE OR REPLACE PROCEDURE declare_health
	(id integer,
	d_date DATE,
	temp float8)
AS $$
BEGIN
	INSERT INTO health_declaration VALUES (id, d_date, temp);
END;
$$
LANGUAGE plpgsql;


-- CREATE OR REPLACE PROCEDURE leave_next_7
-- 	(id integer,
-- 	s_date DATE)
-- AS $$
-- BEGIN
-- 	DELETE FROM sessions s WHERE (s.book_id = id AND s.sdate >= s_date AND s.sdate <= s_date + 7);

-- 	UPDATE sessions
-- 	SET cap = OLD.cap - 1
-- 	FROM sessions s, session_part sp 
-- 	WHERE sp.eid = id
-- 	AND s.stime = sp.stime
-- 	AND s.sdate = sp.sdate
-- 	AND s.room = sp.room
-- 	AND s.floor = sp.floor
-- 	AND s.sdate >= s_date
-- 	AND s.sdate <= s_date + 7;
	
-- 	DELETE FROM session_part sp WHERE (sp.eid = id AND sp.sdate >= s_date AND sp.sdate <= s_date + 7); 
-- END;
-- $$ 
-- LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION contact_tracing 
	(id integer)
RETURNS TABLE (Eid integer)
AS $$
BEGIN
	WITH closeContact AS
		(SELECT DISTINCT sp2.eid AS eid
		FROM session_part sp, session_part sp2
		WHERE sp.eid = id
		AND sp2.eid <> id
		AND sp2.stime = sp.stime
		AND sp2.sdate = sp.sdate
		AND sp2.room = sp.room
		AND sp2.floor = sp.floor
		AND sp.sdate > CURRENT_DATE -3)

	-- Delete meetings which were booked
	DELETE FROM sessions s WHERE (s.book_id = closeContact.id AND s.sdate >= s_date AND s.sdate <= s_date + 7);

	-- Remove meetings participating
	UPDATE sessions
	SET cap = OLD.cap - 1
	FROM sessions s, session_part sp, closeContact cc
	WHERE sp.eid = cc.eid
	AND s.stime = sp.stime
	AND s.sdate = sp.sdate
	AND s.room = sp.room
	AND s.floor = sp.floor
	AND s.sdate >= CURRENT_DATE
	AND s.sdate <= CURRENT_DATE + 7;
	
	DELETE FROM session_part sp WHERE (sp.eid = id AND sp.sdate >= s_date AND sp.sdate <= s_date + 7); 
	
	-- add to quarantine
	UPDATE employees SET qe_date = CURRENT_DATE + 7 FROM closeContact cc, employees e WHERE cc.eid = e.eid;
	UPDATE employees SET qe_date = CURRENT_DATE + 7 FROM employees e WHERE id = e.eid;



	RETURN QUERY SELECT cc.eid FROM closeContact;
	
END;
$$
LANGUAGE plpgsql;
