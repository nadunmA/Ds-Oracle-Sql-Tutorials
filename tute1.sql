CREATE TYPE dept_t;
/
CREATE TYPE emp_t;
/

CREATE TYPE emp_t AS OBJECT (
    eno     NUMBER(4),
    ename   VARCHAR2(15),
    edept   REF dept_t,
    salary  NUMBER(8,2)
);
/

-- 3) Create Dept type (mgr is REF emp_t)
CREATE TYPE dept_t AS OBJECT (
    dno     NUMBER(2),
    dname   VARCHAR2(12),
    mgr     REF emp_t
);
/

-- 4) Create Project type
CREATE TYPE proj_t AS OBJECT (
    pno     NUMBER(4),
    pname   VARCHAR2(15),
    pdept   REF dept_t,
    budget  NUMBER(10,2)
);
/


-- Create object tables

CREATE TABLE dept OF dept_t (
    dno PRIMARY KEY
);

CREATE TABLE emp OF emp_t (
    eno PRIMARY KEY,
    edept SCOPE IS dept   -- edept must refer to dept table only
);

CREATE TABLE proj OF proj_t (
    pno PRIMARY KEY,
    pdept SCOPE IS dept   -- pdept must refer to dept table only
);


INSERT INTO dept VALUES (dept_t(10, 'IT', NULL));
INSERT INTO dept VALUES (dept_t(20, 'HR', NULL));
INSERT INTO dept VALUES (dept_t(30, 'FINANCE', NULL));


-- 3.2 Employees Insert

INSERT INTO emp VALUES (
    emp_t(1001, 'Kamal',
        (SELECT REF(d) FROM dept d WHERE d.dno = 10),
        120000
    )
);

INSERT INTO emp VALUES (
    emp_t(1002, 'Nimal',
        (SELECT REF(d) FROM dept d WHERE d.dno = 10),
        80000
    )
);

INSERT INTO emp VALUES (
    emp_t(2001, 'Saman',
        (SELECT REF(d) FROM dept d WHERE d.dno = 20),
        95000
    )
);

INSERT INTO emp VALUES (
    emp_t(3001, 'Ruwan',
        (SELECT REF(d) FROM dept d WHERE d.dno = 30),
        110000
    )
);


-- 3.3

UPDATE dept d
SET d.mgr = (SELECT REF(e) FROM emp e WHERE e.eno = 1001)
WHERE d.dno = 10;

UPDATE dept d
SET d.mgr = (SELECT REF(e) FROM emp e WHERE e.eno = 2001)
WHERE d.dno = 20;

UPDATE dept d
SET d.mgr = (SELECT REF(e) FROM emp e WHERE e.eno = 3001)
WHERE d.dno = 30;


-- 3.4 Projects Insert

INSERT INTO proj VALUES (
    proj_t(1, 'BusSystem',
        (SELECT REF(d) FROM dept d WHERE d.dno = 10),
        75000
    )
);

INSERT INTO proj VALUES (
    proj_t(2, 'FoodApp',
        (SELECT REF(d) FROM dept d WHERE d.dno = 10),
        45000
    )
);

INSERT INTO proj VALUES (
    proj_t(3, 'HRPortal',
        (SELECT REF(d) FROM dept d WHERE d.dno = 20),
        25000
    )
);

INSERT INTO proj VALUES (
    proj_t(4, 'ERPUpgrade',
        (SELECT REF(d) FROM dept d WHERE d.dno = 30),
        120000
    )
);

COMMIT;



-- (a) Find the name and salary of managers of all departments. Display the department number, 
--manager name and salary.
select d.dno as dept_no,
deref(d.mgr).ename as manager_name,
deref(d.mgr).salary as manager_salary
from dept d;

--(b) For projects that have budgets over $50000, get the project name, and the name of the manager 
--of the department in charge of the project.
select p.pname as project_name, 
deref(deref(p.pdept).mgr).ename as manager_name
from proj p where p.budget > 50000; 

-- (c) For departments that are in charge of projects, find the department number, department name and 
--total budget of all its projects together
select d.dno as dept_no, d.dname as dept_name, sum(p.budget) as total_budget
from proj p, dept d
where p.pdept = ref(d)
group by d.dno, d.dname;

-- (d) Find the manager’s name who is controlling the project with the largest budget
select deref(deref (p.pdept).ename as manger_name
from proj p
where p.budget = (select max(budget) from proj);

-- (e.) Find the managers who control budget above $60,000. (Hint: The total amount a manager 
--control is the sum of budgets of all projects belonging to the dept(s) for which the he/she is 
--managing). Print the manager’s employee number and the total controlling budget.
select deref(d.mgr).eno AS manager_eno,
sum(p.budget) AS total_controlling_budget
from dept d, proj p
where p.pdept = ref(d)
group by deref(d.mgr).eno
having sum(p.budget) > 60000;

-- (f.) Find the manager who controls the largest amount. Print the manager’s employee number and 
--the total controlling budget.
select
    manager_eno,
    total_budget
from (
    select
        deref(d.mgr).eno as manager_eno,
        sum(p.budget) as total_budget
    from dept d, proj p
    where p.pdept = ref(d)
    group by deref(d.mgr).eno
)
where total_budget = (
    select max(total_budget)
    from (
        select sum(p.budget) as total_budget
        from dept d, proj p
        where p.pdept = REF(d)
        group by deref(d.mgr).eno
    )
);














