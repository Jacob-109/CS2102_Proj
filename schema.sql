CREATE TABLE Departments (
 id INTEGER,
    name VARCHAR(255) NOT NULL,
 PRIMARY KEY(id)
);

CREATE TABLE Employees (
    id INTEGER,
    name VARCHAR(255) NOT NULL,
 email VARCHAR(255) NOT NULL UNIQUE,
 contact INTEGER,
 resigned_date DATE,
 role VARCHAR(10) NOT NULL,
 PRIMARY KEY(id)
);

CREATE TABLE MeetingRooms (
    room INTEGER,
 floor INTEGER,
    name VARCHAR(255) NOT NULL,
 PRIMARY KEY (room,floor)
);

CREATE TABLE HealthDeclarations (
 id INTEGER,
 date DATE,
 temp INTEGER,
    fever VARCHAR(255),
 PRIMARY KEY(id,date)
);

CREATE TABLE Sessions (
 time DATE,
 date DATE,
 room INTEGER,
 floor INTEGER,
 booker_id INTEGER,
 participants_id,
);