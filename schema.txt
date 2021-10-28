CREATE TABLE departments (
   did INTEGER PRIMARY KEY,
   dname VARCHAR(255)
);

CREATE TABLE meetingRooms (
	room INTEGER,
	floor INTEGER,
   -- participation constraint
   did INTEGER NOT NULL,
	rname VARCHAR(255),
	PRIMARY KEY (room,floor),
   -- located in department
   FOREIGN KEY (did) REFERENCES departments (did)
);

CREATE TABLE employees (
   eid INTEGER PRIMARY KEY,
   ename VARCHAR(255),
   email VARCHAR(255) UNIQUE,
   resigned_date DATE,
   -- participation constraint
   did INTEGER NOT NULL,
   -- works in department
   FOREIGN KEY (did) REFERENCES departments (did)
)
-- multivalue attribute of employees 
CREATE TABLE eContacts (
   eid INTEGER,
   contact INTEGER,
   PRIMARY KEY (eid, contact),
   FOREIGN KEY (eid) REFERENCES employees (eid)
)

CREATE TABLE health_declaration (
   eid INTEGER,
   ddate DATE,
   temp float8,
   fever BOOLEAN NOT NULL,
   PRIMARY KEY(eid, ddate),
   -- Weak entity
   FOREIGN KEY (eid) REFERENCES employees (eid) ON DELETE CASCADE
)

-- ISA employee
CREATE TABLE junior (
   eid INTEGER PRIMARY KEY,
   FOREIGN KEY (eid) REFERENCES employees (eid) ON DELETE CASCADE
)
-- ISA employee
CREATE TABLE booker (
   eid INTEGER PRIMARY KEY,
   FOREIGN KEY (eid) REFERENCES employees(eid) ON DELETE CASCADE
)
-- ISA booker
CREATE TABLE senior (
   eid INTEGER PRIMARY KEY,
   FOREIGN KEY (eid) REFERENCES booker(eid) ON DELETE CASCADE
)
-- ISA booker
CREATE TABLE manager (
   eid INTEGER PRIMARY KEY,
   FOREIGN KEY (eid) REFERENCES booker(eid) ON DELETE CASCADE
)

CREATE TABLE sessions (
   -- participation constraint
   book_id INTEGER NOT NULL
   stime TIME,
   sdate TIME,
   room INTEGER,
   floor INTEGER,
   approve_id INTEGER.

   PRIMARY KEY (stime, sdate, room, floor),
   FOREIGN KEY (room, floor) REFERENCES meetingRooms (room, floor) ON DELETE CASCADE,
   -- deletes meeting session when booker no longer authorized
   FOREIGN KEY (book_id) REFERENCES booker (eid) ON DELETE CASCADE,
   -- manager approves sessions
   FOREIGN KEY (approve_id) REFERENCES manager (eid)

)

-- join relation between employees and sessions
CREATE TABLE session_part (
   stime TIME,
   sdate TIME,
   room INTEGER,
   floor INTEGER,
   -- join participation constraint
   eid INTEGER NOT NULL,

   PRIMARY KEY (stime, sdate, room, floor, eid),
   FOREIGN KEY (stime, sdate, room, floor) REFERENCES sessions (stime, sdate, room, floor) ON DELETE CASCADE,
   FOREIGN KEY (eid) REFERENCES employees (eid)
)

CREATE TABLE update (
   eid INTEGER NOT NULL,
   udate DATE,
   new_cap INTEGER,
   room INTEGER,
   floor INTEGER,
   PRIMARY KEY (udate, room, floor),
   FOREIGN KEY (room, floor) REFERENCES meetingRooms (room, floor) ON DELETE CASCADE,
   FOREIGN KEY (eid) REFERENCES manager (eid)
)

