DROP TABLE IF EXISTS departments, employees, eContacts, health_declaration, junior, booker, senior, manager, sessions, session_part, mr_update;


CREATE TABLE departments (
   did integer PRIMARY KEY,
   dname VARCHAR(255)
);

CREATE TABLE meetingRooms (
	room integer,
	floor integer,
   -- participation constraint
   did integer NOT NULL,
	rname VARCHAR(255),
	PRIMARY KEY (room,floor),
   -- located in department
   FOREIGN KEY (did) REFERENCES departments (did)
);

CREATE TABLE employees (
   eid integer PRIMARY KEY,
   ename VARCHAR(255),
   email VARCHAR(255) UNIQUE,
   resigned_date DATE,
   -- participation constraint
   did integer NOT NULL,
   -- works in department
   FOREIGN KEY (did) REFERENCES departments (did)
);
-- multivalue attribute of employees 
CREATE TABLE eContacts (
   eid integer,
   contact integer,
   PRIMARY KEY (eid, contact),
   FOREIGN KEY (eid) REFERENCES employees (eid) ON DELETE CASCADE
);

CREATE TABLE health_declaration (
   eid integer,
   ddate DATE,
   temp float8,
   fever BOOLEAN NOT NULL,
   PRIMARY KEY(eid, ddate),
   -- Weak entity
   FOREIGN KEY (eid) REFERENCES employees (eid) ON DELETE CASCADE
);

-- ISA employee
CREATE TABLE junior (
   eid integer PRIMARY KEY,
   FOREIGN KEY (eid) REFERENCES employees (eid) ON DELETE CASCADE
);
-- ISA employee
CREATE TABLE booker (
   eid integer PRIMARY KEY,
   FOREIGN KEY (eid) REFERENCES employees(eid) ON DELETE CASCADE
);
-- ISA booker
CREATE TABLE senior (
   eid integer PRIMARY KEY,
   FOREIGN KEY (eid) REFERENCES booker(eid) ON DELETE CASCADE
);
-- ISA booker
CREATE TABLE manager (
   eid integer PRIMARY KEY,
   FOREIGN KEY (eid) REFERENCES booker(eid) ON DELETE CASCADE
);

CREATE TABLE sessions (
   -- participation constraint
   book_id integer NOT NULL,
   stime TIME,
   sdate TIME,
   room integer,
   floor integer,
   approve_id integer,

   PRIMARY KEY (stime, sdate, room, floor),
   FOREIGN KEY (room, floor) REFERENCES meetingRooms (room, floor) ON DELETE CASCADE,
   -- deletes meeting session when booker no longer authorized
   FOREIGN KEY (book_id) REFERENCES booker (eid) ON DELETE CASCADE,
   -- manager approves sessions
   FOREIGN KEY (approve_id) REFERENCES manager (eid) ON DELETE CASCADE

);

-- join relation between employees and sessions
CREATE TABLE session_part (
   stime TIME,
   sdate TIME,
   room integer,
   floor integer,
   -- join participation constraint
   eid integer NOT NULL,

   PRIMARY KEY (stime, sdate, room, floor, eid),
   FOREIGN KEY (stime, sdate, room, floor) REFERENCES sessions (stime, sdate, room, floor) ON DELETE CASCADE,
   FOREIGN KEY (eid) REFERENCES employees (eid)
);

CREATE TABLE mr_update (
   eid integer NOT NULL,
   udate DATE,
   new_cap integer,
   room integer,
   floor integer,
   PRIMARY KEY (udate, room, floor),
   FOREIGN KEY (room, floor) REFERENCES meetingRooms (room, floor) ON DELETE CASCADE,
   FOREIGN KEY (eid) REFERENCES manager (eid)
);
