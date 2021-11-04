
--1
insert into departments (did, dname) values (1, 'Sales');
insert into departments (did, dname) values (2, 'IT');
insert into departments (did, dname) values (3, 'Compliance');
insert into departments (did, dname) values (4, 'Research');
insert into departments (did, dname) values (5, 'HR');
insert into departments (did, dname) values (6, 'Supply Chain');
insert into departments (did, dname) values (7, 'Support');
insert into departments (did, dname) values (8, 'Transport');
insert into departments (did, dname) values (9, 'Cleanliness');

SELECT * from departments;
--5
insert into meetingRooms (room, floor, did, rname) values (1, 1, 1, 'Meeting Room 1');
insert into meetingRooms (room, floor, did, rname) values (2, 1, 1, 'Meeting Room 2');
insert into meetingRooms (room, floor, did, rname) values (3, 2, 2, 'Meeting Room 3');
insert into meetingRooms (room, floor, did, rname) values (4, 2, 2, 'Meeting Room 4');
insert into meetingRooms (room, floor, did, rname) values (5, 3, 3, 'Meeting Room 5');
insert into meetingRooms (room, floor, did, rname) values (6, 4, 3, 'Meeting Room 6');
insert into meetingRooms (room, floor, did, rname) values (7, 5, 4, 'Meeting Room 7');
insert into meetingRooms (room, floor, did, rname) values (8, 6, 4, 'Meeting Room 8');
insert into meetingRooms (room, floor, did, rname) values (9, 6, 4, 'Meeting Room 9');
insert into meetingRooms (room, floor, did, rname) values (10, 6, 5, 'Meeting Room 10');
insert into meetingRooms (room, floor, did, rname) values (11, 6, 6, 'Meeting Room 11');
insert into meetingRooms (room, floor, did, rname) values (12, 6, 7, 'Meeting Room 12');
insert into meetingRooms (room, floor, did, rname) values (13, 6, 7, 'Meeting Room 13');
insert into meetingRooms (room, floor, did, rname) values (14, 7, 8, 'Meeting Room 14');
insert into meetingRooms (room, floor, did, rname) values (15, 8, 8, 'Meeting Room 15');
insert into meetingRooms (room, floor, did, rname) values (16, 9, 8,'Meeting Room 16');
insert into meetingRooms (room, floor, did, rname) values (17, 10, 9, 'Meeting Room 17');
SELECT * FROM meetingRooms;

--3
insert into booker(eid) values (1);
insert into booker(eid) values (2);
insert into booker(eid) values (3);
insert into booker(eid) values (4);
insert into booker(eid) values (5);
insert into booker(eid) values (6);
insert into booker(eid) values (7);
insert into booker(eid) values (8);
insert into booker(eid) values (9);
SELECT * FROM booker

--4
insert into manager(eid) values (1);
insert into manager(eid) values (2);
insert into manager(eid) values (3);
insert into manager(eid) values (4);
insert into manager(eid) values (5);
insert into manager(eid) values (6);
insert into manager(eid) values (7);
insert into manager(eid) values (8);
insert into manager(eid) values (9);

SELECT * FROM manager
--6
insert into mr_update(eid, udate, new_cap,room,floor) values (1,'2021-10-01',50,1,1);
insert into mr_update(eid, udate, new_cap,room,floor) values (2, '2021-10-01',50,2,1);
insert into mr_update(eid, udate, new_cap,room,floor) values (3,'2021-10-01',50,3,2);
insert into mr_update(eid, udate, new_cap,room,floor) values (4,'2021-10-01',50,4,2);
insert into mr_update(eid, udate, new_cap,room,floor) values (5,'2021-10-01',50,5,3);
insert into mr_update(eid, udate, new_cap,room,floor) values (6,'2021-10-01',50,6,4);
insert into mr_update(eid, udate, new_cap,room,floor) values (7,'2021-10-01',50,7,5);
insert into mr_update(eid, udate, new_cap,room,floor) values (8,'2021-10-01',50,8,6);
insert into mr_update(eid, udate, new_cap,room,floor) values (9,'2021-10-01',30,9,6);
insert into mr_update(eid, udate, new_cap,room,floor) values (1,'2021-10-01',5,10,6);
insert into mr_update(eid, udate, new_cap,room,floor) values (2,'2021-10-01',50,11,6);
insert into mr_update(eid, udate, new_cap,room,floor) values (3,'2021-10-01',50,12,6);
insert into mr_update(eid, udate, new_cap,room,floor) values (4,'2021-10-01',50,13,6);
insert into mr_update(eid, udate, new_cap,room,floor) values (5,'2021-10-01',50,14,7);
insert into mr_update(eid, udate, new_cap,room,floor) values (6,'2021-10-01',50,15,8);
insert into mr_update(eid, udate, new_cap,room,floor) values (7,'2021-10-01',50,16,9);
insert into mr_update(eid, udate, new_cap,room,floor) values (8,'2021-10-01',50,17,10);
--insert into mr_update(eid, udate, new_cap,room,floor) values (7,'2021-10-20',50,16,9);
DELETE from mr_update
WHERE room = 16;

TRUNCATE mr_update;
TRUNCATE departments;
TRUNCATE employees;
TRUNCATE manager;
TRUNCATE booker;
TRUNCATE meetingRooms;

ALTER TABLE employees, manager,booker, meetingRooms,departments DISABLE TRIGGER ALL;

BEGIN;
ALTER TABLE employees, manager,booker, meetingRooms,departments DISABLE TRIGGER ALL;
TRUNCATE employees, manager,booker, meetingRooms,departments;
ALTER TABLE employees, manager,booker, meetingRooms,departments ENABLE TRIGGER ALL;
COMMIT;

SET FOREIGN_KEY_CHECKS = 1;

SELECT * from mr_update;

--2
--employees
insert into employees (eid, ename, email, did ,kind) values (1, 'Jack', 'jackma@gmail.com',1, 2);
insert into employees (eid, ename, email, did ,kind) values (2, 'Jill', 'jillka@gmail.com', 2, 2);
insert into employees (eid, ename, email, did ,kind) values (3, 'Dill', 'dillthough@gmail.com',3,2);
insert into employees (eid, ename, email, did ,kind) values (4, 'Shelly', 'shelly@gmail.com',4, 2);
insert into employees (eid, ename, email, did ,kind) values (5, 'Spongebob', 'squarepants@gmail.com',5,2);
insert into employees (eid, ename, email, did ,kind) values (6, 'Patrick', 'patrickstar@gmail.com',6,2);
insert into employees (eid, ename, email, did ,kind) values (7, 'Krabs', 'krabs$@gmail.com',7, 2);
insert into employees (eid, ename, email, did ,kind) values (8, 'Bill', 'billd@gmail.com',8, 2);
insert into employees (eid, ename, email, did ,kind) values (9, 'Sun', 'sunho@gmail.com',9, 2);
insert into employees (eid, ename, email, did ,kind) values (10, 'Kong', 'kongking@gmail.com', 1, 0);
insert into employees (eid, ename, email, did ,kind) values (11, 'King', 'kinghee@gmail.com', 2, 0);
insert into employees (eid, ename, email, did ,kind) values (12, 'Chua', 'chuatio@gmail.com',3, 0);

SELECT * FROM employees;
--7
--sessions
insert into sessions (book_id , stime, sdate, room, floor, curr_cap, approve_id) values (1,'08:00:00','2021-11-01',1,1,15,1);
insert into sessions (book_id , stime, sdate, room, floor, curr_cap, approve_id) values (1,'09:00:00','2021-11-01',1,1,15,1);
insert into sessions (book_id , stime, sdate, room, floor, curr_cap, approve_id) values (1,'10:00:00','2021-11-01',1,1,15,1);

insert into sessions (book_id , stime, sdate, room, floor,curr_cap, approve_id) values (1,'11:00:00','2021-11-01',2,1,15,1);
insert into sessions (book_id , stime, sdate, room, floor, curr_cap,approve_id) values (1,'12:00:00','2021-11-01',2,1,15,1);
insert into sessions (book_id , stime, sdate, room, floor, curr_cap,approve_id) values (1,'13:00:00','2021-11-01',2,1,15,1);
insert into sessions (book_id , stime, sdate, room, floor, curr_cap,approve_id) values (1,'16:00:00','2021-11-01',2,1,15,1);
insert into sessions (book_id , stime, sdate, room, floor, curr_cap,approve_id) values (1,'17:00:00','2021-11-01',2,1,15,1);

insert into sessions (book_id , stime, sdate, room, floor, curr_cap,approve_id) values (2,'08:00:00','2021-11-01',3,2,15,2);
insert into sessions (book_id , stime, sdate, room, floor, curr_cap,approve_id) values (2,'09:00:00','2021-11-01',3,2,15,2);
insert into sessions (book_id , stime, sdate, room, floor, curr_cap,approve_id) values (2,'10:00:00','2021-11-01',3,2,15,2);
insert into sessions (book_id , stime, sdate, room, floor, curr_cap,approve_id) values (2,'11:00:00','2021-11-01',3,2,15,2);
insert into sessions (book_id , stime, sdate, room, floor, curr_cap,approve_id) values (2,'12:00:00','2021-11-01',4,2,15,2);
insert into sessions (book_id , stime, sdate, room, floor, curr_cap,approve_id) values (2,'13:00:00','2021-11-01',4,2,15,2);
insert into sessions (book_id , stime, sdate, room, floor, curr_cap,approve_id) values (2,'16:00:00','2021-11-01',4,2,15,2);
insert into sessions (book_id , stime, sdate, room, floor, curr_cap,approve_id) values (2,'17:00:00','2021-11-01',4,2,15,2);
insert into sessions (book_id , stime, sdate, room, floor, curr_cap,approve_id) values (2,'18:00:00','2021-11-01',4,2,15,NULL);
SELECT * FROM sessions;


insert into health_declaration (eid,ddate,temp,fever) values (1,'2021-11-01',38.1, TRUE);
insert into health_declaration (eid,ddate,temp,fever) values (2,'2021-11-01',37.1, FALSE);
insert into health_declaration (eid,ddate,temp,fever) values (3,'2021-11-01',37.1, FALSE);
insert into health_declaration (eid,ddate,temp,fever) values (4,'2021-11-01',37.1, FALSE);
insert into health_declaration (eid,ddate,temp,fever) values (5,'2021-11-01',37.1, FALSE);
insert into health_declaration (eid,ddate,temp,fever) values (6,'2021-11-01',37.1, FALSE);
insert into health_declaration (eid,ddate,temp,fever) values (7,'2021-11-01',37.1, FALSE);
insert into health_declaration (eid,ddate,temp,fever) values (8,'2021-11-01',37.1, FALSE);
insert into health_declaration (eid,ddate,temp,fever) values (9,'2021-11-01',37.1, FALSE);
insert into health_declaration (eid,ddate,temp,fever) values (10,'2021-11-01',37.1, FALSE);
insert into health_declaration (eid,ddate,temp,fever) values (11,'2021-11-01',37.1, FALSE);
insert into health_declaration (eid,ddate,temp,fever) values (12,'2021-11-01',37.1, FALSE);
insert into health_declaration (eid,ddate,temp,fever) values (2,'2021-11-02',37.1, FALSE);
insert into health_declaration (eid,ddate,temp,fever) values (1,'2021-11-03',37.2, FALSE);

SELECT * from health_declaration
DELETE from health_declaration
WHERE ddate = '2021-11-03'

SELECT * from employees;

select exists(select 1 from employees where eid=1);


SELECT * from meetingRooms;

SELECT * from meetingRooms JOIN meetingRooms;

with cte AS (
    SELECT u.floor,u.room
    FROM mr_update u INNER JOIN meetingRooms mr
        ON u.floor = mr.floor
        AND u.room = mr.room
    WHERE new_cap > 40
    EXCEPT
    SELECT s.floor, s.room  
    FROM sessions s
    WHERE sdate = '2021-11-01'
    AND stime > '12:30:00'
    AND stime < '13:30:00'
    ORDER BY floor, room
)
Select * from cte ctc 
INNER JOIN meetingRooms mr ON ctc.floor = mr.floor AND ctc.room = mr.room
INNER JOIN mr_update mru ON mru.floor = mr.floor AND mru.room = mr.room;

SELECT * from health_declaration

SELECT EXISTS(
SELECT fever from health_declaration hd
WHERE eid = 1
AND ddate > CURRENT_DATE - integer '6'
AND ddate <= CURRENT_DATE
AND fever = TRUE)
;


SELECT *
FROM mr_update u INNER JOIN meetingRooms mr
    ON u.floor = mr.floor
    AND u.room = mr.room;

SELECT * 
FROM manager m INNER JOIN booker b
    ON m.eid = b.eid

SELECT * from 

select exists(select 1 from employees c where c.eid=1)

SELECT * from health_declaration; 

SELECT fever from health_declaration hd
WHERE hd.eid = 2
AND hd.ddate = '2021-11-02';


SELECT EXISTS(SELECT 1 from health_declaration c WHERE c.eid = 2 AND c.ddate = CURRENT_DATE);



SELECT * FROM sessions;


