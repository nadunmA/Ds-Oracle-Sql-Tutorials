-- IT23192850
-- Nadun M.A
-- WE 4.2
-- Practical 3

create type address_t as object (
    
    streetno VARCHAR2(10),
    streetname VARCHAR2(50),
    suburb VARCHAR2(50),
    state VARCHAR2(10),
    pin VARCHAR2(10)
    
);
/

CREATE TYPE exchanges_varray_t AS VARRAY(5) OF VARCHAR2(30);
/


CREATE TYPE investment_t AS OBJECT (
    company VARCHAR2(20),
    purchaseprice NUMBER(8,2),
    purchasedate DATE,
    qty NUMBER(10)
);
/

CREATE TYPE investments_nt_t AS TABLE OF investment_t;
/

CREATE TABLE clients_or (
    clientno NUMBER PRIMARY KEY,
    firstname VARCHAR2(20),
    lastname VARCHAR2(20),
    address address_t,
    investments investments_nt_t
)
NESTED TABLE investments STORE AS investments_store;


CREATE TABLE stocks_or (
    company VARCHAR2(20) PRIMARY KEY,
    currentprice NUMBER(8,2),
    exchanges exchanges_varray_t,
    lastdividend NUMBER(8,2),
    eps NUMBER(8,2)
);



INSERT INTO stocks_or VALUES ('BHP', 10.50, exchanges_varray_t('Sydney','New York'), 1.50, 3.20);

INSERT INTO stocks_or VALUES ('IBM', 70.00, exchanges_varray_t('New York','London','Tokyo'), 4.25, 10.00);

INSERT INTO stocks_or VALUES ('INTEL', 76.50, exchanges_varray_t('New York','London'), 5.00, 12.40);

INSERT INTO stocks_or VALUES ('FORD', 40.00, exchanges_varray_t('New York'), 2.00, 8.50);

INSERT INTO stocks_or VALUES ('GM', 60.00, exchanges_varray_t('New York'), 2.50, 9.20);

INSERT INTO stocks_or VALUES ('INFOSYS', 45.00, exchanges_varray_t('New York'), 3.00, 7.80);


INSERT INTO clients_or VALUES (
  1, 'John', 'Smith', address_t('3', 'East Av', 'Bentley', 'WA', '6102'),
  investments_nt_t(
    investment_t('BHP', 12.00, TO_DATE('02/10/2001','DD/MM/YYYY'), 1000),
    investment_t('BHP', 10.50, TO_DATE('08/06/2002','DD/MM/YYYY'), 2000),
    investment_t('IBM', 58.00, TO_DATE('12/02/2000','DD/MM/YYYY'), 500),
    investment_t('IBM', 65.00, TO_DATE('10/04/2001','DD/MM/YYYY'), 1200),
    investment_t('INFOSYS', 64.00, TO_DATE('11/08/2001','DD/MM/YYYY'), 1000)
  )
);


INSERT INTO clients_or VALUES (
  2, 'Jill', 'Brody', address_t('42', 'Bent St', 'Perth', 'WA', '6001'),
  investments_nt_t(
    investment_t('INTEL', 35.00, TO_DATE('30/01/2000','DD/MM/YYYY'), 300),
    investment_t('INTEL', 54.00, TO_DATE('30/01/2001','DD/MM/YYYY'), 400),
    investment_t('INTEL', 60.00, TO_DATE('02/10/2001','DD/MM/YYYY'), 200),
    investment_t('FORD', 40.00, TO_DATE('05/10/1999','DD/MM/YYYY'), 300),
    investment_t('GM', 55.50, TO_DATE('12/12/2000','DD/MM/YYYY'), 500)
  )
);


-- a)
SELECT c.firstname || ' ' || c.lastname AS client_name ,
i.company, s.currentprice, s.lastdividend, s.eps
FROM clients_or c, 
TABLE(c.investments) i, stocks_or s
WHERE i.company = s.company
ORDER BY client_name, i.company;



-- b)
SELECT c.firstname || ' ' || c.lastname AS client_name,
       i.company,
       SUM(i.qty) AS total_shares,
       ROUND(SUM(i.qty * i.purchaseprice) / SUM(i.qty), 2) AS avg_purchase_price
FROM clients_or c,
     TABLE(c.investments) i
GROUP BY c.firstname, c.lastname, i.company
ORDER BY client_name, i.company;



-- c)
SELECT s.company,
       c.firstname || ' ' || c.lastname AS client_name,
       SUM(i.qty) AS shares_held,
       SUM(i.qty) * s.currentprice AS current_value
FROM clients_or c,
     TABLE(c.investments) i,
     stocks_or s
WHERE i.company = s.company
  AND EXISTS (
      SELECT 1
      FROM TABLE(s.exchanges) e
      WHERE e.COLUMN_VALUE = 'New York'
  )
GROUP BY s.company, c.firstname, c.lastname, s.currentprice
ORDER BY s.company, client_name;



-- d)
SELECT c.firstname || ' ' || c.lastname AS client_name,
       SUM(i.qty * i.purchaseprice) AS total_purchase_value
FROM clients_or c,
     TABLE(c.investments) i
GROUP BY c.firstname, c.lastname
ORDER BY client_name;



-- e)
SELECT c.firstname || ' ' || c.lastname AS client_name,
       (SUM(i.qty * s.currentprice) - SUM(i.qty * i.purchaseprice)) AS book_profit
FROM clients_or c,
     TABLE(c.investments) i,
     stocks_or s
WHERE i.company = s.company
GROUP BY c.firstname, c.lastname
ORDER BY client_name;



