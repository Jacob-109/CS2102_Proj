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
CALL leave_future (NEW.resigned_date, NEW.eid);

CREATE OR REPLACE PROCEDURE leave_future
	(r_date DATE,
	id integer)
AS $$
BEGIN
	-- DELETES ALL SESSIONS BOOKED BY R EMPLOYEE AFTER R DATE
	DELETE * FROM sessions WHERE book_id = id AND sdate > r_date;
	RETURN NULL;
END;
$$
LANGUAGE plpgsql;

-- TRIGGER FOR DELETING DEPARTMENT
DROP TRIGGER IF EXISTS del_dep ON departments;
CREATE TRIGGER del_dep
BEFORE DELETE ON employees
FOR EACH ROW
EXECUTE FUNTION del_dep(OLD.did)
-- SETS meetingRooms did to null to indicate deleted
CREATE OR REPLACE FUNCTION del_dep
	(id integer)
RETURNS TRIGGER
AS $$
BEGIN
	UPDATE meetingRooms
	SET did = null
	WHERE did = id;
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

		CALL fever_management(NEW.eid, NEW.ddate);
	ELSE
		NEW.fever := FALSE;
	END IF;

	RETURN NEW;
END;
$$
LANGUAGE plpgsql;

-- Remove from future meetings, delete hosted meetings
CREATE OR REPLACE PROCEDURE fever_management
	(id integer,
	d_date integer)
AS $$
BEGIN
	
END
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
	-- Resign employee
	UPDATE employees e 
	SET e.resigned_date = CURRENT_DATE, 
		e.did = NULL
	WHERE e.did = did;

	DELETE * FROM departments d WHERE d.did = did;
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

-- DROP TRIGGER IF EXISTS employee_added ON employees;
-- CREATE TRIGGER employee_added
-- AFTER INSERT ON employees
-- FOR EACH ROW EXECUTE FUNCTION assign_employee_role();

-- CREATE OR REPLACE FUNCTION assign_employee_role()
-- RETURNS TRIGGER
-- AS $$
-- BEGIN
-- 	IF NEW.kind = 0 
-- 	THEN	
-- 		INSERT INTO junior VALUES (NEW.eid);
-- 	ELSEIF NEW.kind = 1 
-- 	THEN	
-- 		INSERT INTO booker VALUES (NEW.eid);
-- 		INSERT INTO senior VALUES (NEW.eid);
-- 	ELSEIF NEW.kind = 2
-- 	THEN	
-- 		INSERT INTO booker VALUES (NEW.eid);
-- 		INSERT INTO manager VALUES (NEW.eid);
-- 	END IF;
-- 	RETURN NULL;
-- END;
-- $$
-- LANGUAGE plpgsql;
	


-- date YYYY-MM-DD
CREATE OR REPLACE PROCEDURE remove_employee
	(id integer,
	r_date DATE)
AS $$
BEGIN
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

