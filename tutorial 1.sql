-- STEP 1 — Object Types Create

CREATE TYPE Dept_t;
/

CREATE TYPE Emp_t AS OBJECT (
    eno NUMBER(4),
    ename VARCHAR2(15),
    edept REF Dept_t,
    salary NUMBER(8,2)
);
/

CREATE TYPE Dept_t AS OBJECT (
    dno NUMBER(2),
    dname VARCHAR2(12),
    mgr REF Emp_t
);
/

CREATE TYPE Proj_t AS OBJECT (
    pno NUMBER(4),
    pname VARCHAR2(15),
    pdept REF Dept_t,
    budget NUMBER(10,2)
);
/



--STEP 2 — Tables Create

CREATE TABLE Dept OF Dept_t (
    dno PRIMARY KEY
);
/

CREATE TABLE Emp OF Emp_t (
    eno PRIMARY KEY,
    edept REFERENCES Dept
);
/

CREATE TABLE Proj OF Proj_t (
    pno PRIMARY KEY,
    pdept REFERENCES Dept
);
/


-- STEP 3 — Departments Insert
INSERT INTO Dept VALUES (1, 'IT', NULL);
INSERT INTO Dept VALUES (2, 'HR', NULL);
INSERT INTO Dept VALUES (3, 'FINANCE', NULL);
/


-- STEP 4 — Employees Insert
INSERT INTO Emp VALUES (101, 'John', NULL, 60000);
INSERT INTO Emp VALUES (102, 'Mary', NULL, 75000);
INSERT INTO Emp VALUES (103, 'David', NULL, 50000);
INSERT INTO Emp VALUES (104, 'Sara', NULL, 80000);
/


-- STEP 5 — Update Employee Departments (REF set)
UPDATE Emp e
SET e.edept = (SELECT REF(d) FROM Dept d WHERE d.dno = 1)
WHERE e.eno = 101;

UPDATE Emp e
SET e.edept = (SELECT REF(d) FROM Dept d WHERE d.dno = 1)
WHERE e.eno = 102;

UPDATE Emp e
SET e.edept = (SELECT REF(d) FROM Dept d WHERE d.dno = 2)
WHERE e.eno = 103;

UPDATE Emp e
SET e.edept = (SELECT REF(d) FROM Dept d WHERE d.dno = 3)
WHERE e.eno = 104;
/


-- STEP 6 — Set Department Managers (REF)
UPDATE Dept d
SET d.mgr = (SELECT REF(e) FROM Emp e WHERE e.eno = 102)
WHERE d.dno = 1;

UPDATE Dept d
SET d.mgr = (SELECT REF(e) FROM Emp e WHERE e.eno = 103)
WHERE d.dno = 2;

UPDATE Dept d
SET d.mgr = (SELECT REF(e) FROM Emp e WHERE e.eno = 104)
WHERE d.dno = 3;
/


-- STEP 7 — Insert Projects
INSERT INTO Proj VALUES (
    1001,
    'SystemUpgrade',
    (SELECT REF(d) FROM Dept d WHERE d.dno = 1),
    90000
);

INSERT INTO Proj VALUES (
    1002,
    'Recruitment',
    (SELECT REF(d) FROM Dept d WHERE d.dno = 2),
    40000
);

INSERT INTO Proj VALUES (
    1003,
    'Audit',
    (SELECT REF(d) FROM Dept d WHERE d.dno = 3),
    70000
);
/



-- (a) Find the name and salary of managers of all departments. Display the department number,
--manager name and salary.
select d.dno, d.mgr.ename, d.mgr.salary
from Dept d;

-- (b) For projects that have budgets over $50000, get the project name, and the name of the manager
--of the department in charge of the project.
select p.pname, p.pdept.mgr.ename
from Proj p
where p.budget > 50000;


-- c) For departments that are in charge of projects, find the department number, department name and
--total budget of all its projects together.
select p.pdept.dno, p.pdept.dname, sum(p.budget) as total_budget
from Proj p
group by p.pdept.dno, p.pdept.dname;


-- (d) Find the manager’s name who is controlling the project with the largest budget
select p.pdept.mgr.ename
from Proj p
where p.budget = (select max(budget) from Proj);


-- (e.) Find the managers who control budget above $60,000. (Hint: The total amount a manager
--control is the sum of budgets of all projects belonging to the dept(s) for which the he/she is
--managing). Print the manager’s employee number and the total controlling budget.
SELECT d.mgr.eno,
       SUM(p.budget) AS total_budget
FROM Dept d, Proj p
WHERE p.pdept = REF(d)
GROUP BY d.mgr.eno
HAVING SUM(p.budget) > 60000;


-- (f.) Find the manager who controls the largest amount. Print the manager’s employee number and
--the total controlling budget.
select d.mgr.eno, sum(p.budget) as total_budget
from Dept d, Proj p
where p.pdept = REF(d)
group by d.mgr.eno
HAVING SUM(p.budget) =
       (SELECT MAX(SUM(p2.budget))
        FROM Dept d2, Proj p2
        WHERE p2.pdept = REF(d2)
        GROUP BY d2.mgr.eno);

















