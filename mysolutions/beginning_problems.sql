-- Problem 1

SELECT * FROM shippers;

-- Problem 2
SELECT
  categoryname,
  description
FROM 
  categories;

-- Problem 3
SELECT
  firstname,
  lastname,
  hiredate
FROM 
  employees
WHERE
  title = 'Sales Representative';
  
-- Problem 4
SELECT
  firstname,
  lastname,
  hiredate
FROM 
  employees
WHERE
  title = 'Sales Representative'
  AND
    country = 'USA';
    
-- Problem 5
SELECT
  orderid,
  orderdate
FROM
  orders
WHERE
  employeeid = 5;
  
-- Problem 6
SELECT
  supplierid, 
  contactname,
  contacttitle
FROM
  suppliers
WHERE
  contacttitle <> 'Marketing Manager';
  
-- Problem 7
SELECT
  productid,
  productname
FROM
  products
WHERE
  lower(productname) LIKE '%queso%';

-- Problem 8
SELECT
  orderid,
  customerid,
  shipcountry
FROM
  orders
WHERE 
  shipcountry IN('France', 'Belgium');

-- Problem 9
SELECT
  orderid,
  customerid,
  shipcountry
FROM
  orders
WHERE 
  shipcountry IN('Brazil', 'Mexico', 'Argentina', 'Venezuela');
  
-- Problem 10
SELECT
  firstname, 
  lastname, 
  title,
  birthdate
FROM
  employees
ORDER BY
  birthdate;

-- Problem 11
SELECT
  firstname, 
  lastname, 
  title,
  CAST(birthdate AS DATE) dateonlybirthdate
FROM
  employees
ORDER BY
  birthdate;
  
-- Problem 12
SELECT
  firstname,
  lastname,
  firstname || ' ' || lastname fullname
FROM
  employees;
  
-- Problem 13
SELECT
  OrderID, 
  ProductID, 
  UnitPrice, 
  Quantity,
  UnitPrice * Quantity totalprice
FROM
  orderdetails;
  
-- Problem 14
SELECT
  COUNT(*) totalcustomers
FROM
  customers;
  
-- Problem 15
SELECT
  min(orderdate)
FROM
  orders;
  
-- Problem 16
SELECT DISTINCT
  country
FROM
  customers
ORDER BY 1;

-- Problem 17
SELECT
  contacttitle,
  count(customerid) totalcontacttitle
FROM
  customers
GROUP BY
  contacttitle;
  
-- Problem 18
SELECT
  p.productid,
  p.productname,
  s.companyname
FROM
  products p
  NATURAL JOIN suppliers s;
  
-- Problem 19
SELECT
  o.orderid,
  o.orderdate::DATE,
  s.companyname
FROM
  orders o
  NATURAL JOIN shippers s
WHERE
  orderid < 10270;

