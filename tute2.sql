CREATE TYPE Doctor_t AS OBJECT (
    regNo          CHAR(10),
    name           VARCHAR2(50),
    specialization VARCHAR2(25)
);
/

CREATE TYPE HospitalVisit_t AS OBJECT (
    hosChg  FLOAT,
    vDate   DATE,
    refDoc  REF Doctor_t,
    docChg  FLOAT
);
/

CREATE TYPE HospitalVisit_tlb AS TABLE OF HospitalVisit_t;
/

CREATE TYPE Patient_t AS OBJECT (
    id           CHAR(10),
    name         VARCHAR2(50),
    dateOfBirth  DATE,
    phone        CHAR(10),
    hospVisits   HospitalVisit_tlb
);
/


CREATE TABLE Doctors OF Doctor_t (
    regNo PRIMARY KEY
);

CREATE TABLE Patients OF Patient_t (
    id PRIMARY KEY
)
NESTED TABLE hospVisits STORE AS hospVis_ntb;



INSERT INTO Doctors VALUES
('1223441234', 'Dr. K. Perera', 'Gynecologist');

INSERT INTO Doctors VALUES
('1234421131', 'Dr. P. Weerasinghe', 'Dermatologist');

INSERT INTO Doctors VALUES
('2342111322', 'Prof. S. Fernando', 'Pediatrician');

INSERT INTO Doctors VALUES
('2344114344', 'Dr. K. Sathgunanathan', 'Pediatrician');



INSERT INTO Patients VALUES (
'732821122V',
'Sampath Weerasinghe',
DATE '1973-01-23',
'0332124222',
HospitalVisit_tlb(
    HospitalVisit_t(
        50.00,
        DATE '2006-05-24',
        (SELECT REF(d) FROM Doctors d WHERE d.regNo='1223441234'),
        500.00
    )
)
);


INSERT INTO Patients VALUES (
'491221019V',
'Dulani Perera',
DATE '1949-02-03',
'0112233211',
HospitalVisit_tlb(
    HospitalVisit_t(
        75.00,
        DATE '2006-05-25',
        (SELECT REF(d) FROM Doctors d WHERE d.regNo='2342111322'),
        550.00
    ),
    HospitalVisit_t(
        90.00,
        DATE '2006-05-29',
        (SELECT REF(d) FROM Doctors d WHERE d.regNo='2344114344'),
        300.00
    )
)
);



-- a. Print the total amount spent by patient (id = 732821122V) on hospital
select sum(h.docChg + h.hosChg) as total_amount_spent
from  Patients p,
table(p.hospVisits) h
where p.id = '732821122V';

-- b) Print the number of patients who have channeled “Prof. S. Fernando”
select count(distinct p.id) as no_of_patient
from Patients p,
table (p.hospvisits) h
where deref(h.refDoc).name = 'Prof. S. Fernando';


-- c. How many patients have channeled a pediatrician?
select count(distinct p.id)
from Patients p,
table(p.hospvisits) h
where deref(h.refDoc).specialization = 'Pediatrician';


-- d For each patient, print the total amount spent on doctor charges
select p.name, sum(h.docChg) as doctor_charges
from Patients p,
table(p.hospvisits) h
group by p.name;


-- e. Print the name of the doctor who has earned the more than Rs. 1000/- in total in doctor charges
select deref(h.refDoc).name, sum(h.docChg)
from Patients p,
table (p.hospVisits) h
group by deref(h.refDoc).name
having sum(h.docChg) > 100;
















