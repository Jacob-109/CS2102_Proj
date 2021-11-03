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

DROP TRIGGER IF EXISTS employee_added ON employees;
CREATE TRIGGER employee_added
AFTER INSERT ON employees
FOR EACH ROW EXECUTE FUNCTION assign_employee_role();

CREATE OR REPLACE FUNCTION assign_employee_role()
RETURNS TRIGGER
AS $$
BEGIN
	IF NEW.kind = 0 
	THEN	
		INSERT INTO junior VALUES (NEW.eid);
	ELSEIF NEW.kind = 1 
	THEN	
		INSERT INTO booker VALUES (NEW.eid);
		INSERT INTO senior VALUES (NEW.eid);
	ELSEIF NEW.kind = 2
	THEN	
		INSERT INTO booker VALUES (NEW.eid);
		INSERT INTO manager VALUES (NEW.eid);
	END IF;
	RETURN NULL;
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
		-- CALL fever_management();
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

-- Join meeting 
CREATE OR REPLACE PROCEDURE join_meeting
	(j_floor integer,
	j_room integer,
	j_sdate DATE,
	j_stime time,
	j_etime time,
	j_eid integer
	)
AS $$
BEGIN
	WHILE j_stime < j_etime LOOP
		IF EXISTS (SELECT 1 FROM sessions s
			WHERE s.floor = j_floor 
			AND s.room = j_room 
			AND s.sdate = j_sdate
			AND s.stime = j_stime 
			AND s.approve_id IS NULL
			AND s.curr_cap < (SELECT new_cap FROM mr_update m WHERE m.floor = j_floor AND m.room = j_room))
		THEN
			INSERT INTO session_part VALUES (j_stime, j_sdate, j_room, j_floor, j_eid);
			/*UPDATE sessions s SET curr_cap = curr_cap + 1
				WHERE s.floor = j_floor AND s.room = j_room AND s.sdate = j_sdate
					AND s.stime = j_stime AND s.approve_id IS NULL;*/
			j_stime := j_stime + interval '1 hour';
		ELSE
			j_stime := j_stime + interval '1 hour';
		END IF;
	END LOOP;
END
$$
LANGUAGE plpgsql;

CALL join_meeting(1,1,'2021-11-01','08:00:00','09:00:00',1);

--Leave meeting
CREATE OR REPLACE PROCEDURE leave_meeting
	(l_floor integer,
	l_room integer,
	l_sdate DATE,
	l_stime time,
	l_etime time,
	l_eid integer
	)
AS $$
BEGIN
	IF EXISTS(SELECT * FROM session_part sp INNER JOIN sessions s 
		ON sp.floor = s.floor 
		AND sp.room = s.room 
		AND sp.sdate = s.sdate 
		AND sp.stime = s.stime
			WHERE s.floor = l_floor 
			AND s.room = l_room 
			AND s.sdate = l_sdate
			AND (s.stime >= l_stime AND s.stime < l_etime) 
			AND sp.eid = l_eid
			AND s.approve_id IS NULL)
		THEN
			DELETE FROM session_part sp 
				WHERE sp.floor = l_floor 
				AND sp.room = l_room 
				AND sp.sdate = l_sdate
				AND (sp.stime >= l_stime AND sp.stime < l_etime) 
				AND sp.eid = l_eid;
				/*UPDATE sessions s SET curr_cap = curr_cap - 1
					WHERE s.floor = l_floor AND s.room = l_room AND s.sdate = l_sdate
						AND (s.stime >= l_stime AND s.stime < l_etime);*/
	END IF;
END
$$
LANGUAGE plpgsql;

--Approve meeting
CREATE OR REPLACE PROCEDURE approve_meeting
	(a_floor integer,
	a_room integer,
	a_sdate DATE,
	a_stime time,
	a_etime time,
	a_eid integer
	)
AS $$
BEGIN
	IF EXISTS (SELECT 1 FROM sessions s
		WHERE s.floor = a_floor 
		AND s.room = a_room 
		AND s.sdate = a_sdate
		AND (s.stime >= a_stime AND s.stime < a_etime) 
		AND s.approve_id IS NULL)
		AND EXISTS (SELECT * from employees e INNER JOIN meetingRooms m ON e.did = m.did
			WHERE e.eid = eid AND e.kind = 2 AND m.floor = floor AND m.room = room AND m.did = e.did)
		THEN
			UPDATE sessions s SET approve_id = a_eid
				WHERE s.floor = a_floor 
				AND s.room = a_room 
				AND s.sdate = a_sdate
				AND (s.stime >= a_stime AND s.stime < a_etime) 
				AND s.approve_id IS NULL;
	END IF;
END
$$
LANGUAGE plpgsql;

CALL approve_meeting(1,1,'2021-11-01','08:00:00','09:00:00',1);

-- View Future Meeting
CREATE OR REPLACE FUNCTION view_future_meeting (f_sdate date, f_eid integer)
RETURNS TABLE(Floor_Number INT,Room_Number INT, Date DATE, Start_hour time) AS $$
SELECT floor ,room, sdate, stime
FROM session_part sp
WHERE sp.eid = f_eid
AND sp.sdate >= f_sdate;
$$ LANGUAGE sql;

-- View Booking report (WIP for approve_id)
CREATE OR REPLACE FUNCTION view_booking_report (b_sdate date, b_eid integer)
RETURNS TABLE(Floor_Number INT,Room_Number INT, Date DATE, Start_hour time, isApproved VARCHAR(5)) AS $$
SELECT floor ,room, sdate, stime,
case COALESCE(approve_id, -1) 
when -1 then 'False'
else 'True'
END
FROM sessions s
WHERE s.book_id = b_eid
AND s.sdate >= b_sdate;

$$ LANGUAGE sql;

select * from view_booking_report('2020-10-10',1);

-- Trigger to update capacity of sessions 
DROP TRIGGER IF EXISTS capacity_changed ON session_part;
CREATE OR REPLACE FUNCTION update_capacity()
RETURNS TRIGGER
AS $$
BEGIN
	IF (TG_OP = 'INSERT') THEN 
		UPDATE sessions 
		SET curr_cap = curr_cap + 1
		WHERE stime = NEW.stime 
		AND sdate = NEW.sdate
		AND room = NEW.room
		AND floor = NEW.floor;
		RETURN NULL;
	ELSIF (TG_OP = 'DELETE') THEN 
		UPDATE sessions 
		SET curr_cap = curr_cap - 1
		WHERE stime = OLD.stime 
		AND sdate = OLD.sdate
		AND room = OLD.room
		AND floor = OLD.floor;
		RETURN NULL;
	END IF;
END;
$$
LANGUAGE plpgsql;

CREATE TRIGGER capacity_changed
AFTER INSERT OR DELETE ON session_part
FOR EACH ROW EXECUTE function update_capacity();

