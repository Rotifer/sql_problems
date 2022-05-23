-- Problem 20
-- Categories, and the total products in each category

SELECT
  c.categoryname,
  COUNT(p.productname) "TotalProducts"
FROM
  products p
  NATURAL JOIN categories c
GROUP BY
  c.categoryname;

-- Problem 21
-- Total customers per country/city

SELECT
  c.country,
  c.city,
  count(customerid)
FROM
  customers c
GROUP BY
  c.country,
  c.city;
  
-- Problem 22
-- Products that need reordering

SELECT
  ProductID,
  ProductName,
  UnitsInStock,
  ReorderLevel
FROM
  products
WHERE
  unitsinstock <= reorderlevel
ORDER BY
  productid;
  
-- Problem 23. Products that need reordering, continued

SELECT
  productid,
  productname,
  unitsinstock,
  reorderlevel
FROM
  products
WHERE
  unitsinstock + unitsonorder <= reorderlevel
  AND
    discontinued = 0;
    
-- Problem 24. Customer list by region

SELECT
  c.customerid,
  c.companyname,
  c.region
FROM
  customers c
ORDER BY 
  region NULLS LAST, -- default
  customerid;
  
-- Problem 25. High freight charges

SELECT
  o.shipcountry,
  ROUND(AVG(o.freight::NUMERIC), 4) "AverageFreight"
FROM
  orders o
GROUP BY
  o.shipcountry
ORDER BY
  "AverageFreight" DESC
LIMIT 3;

-- Problem 26. High freight charges—2015

SELECT
  o.shipcountry,
  avg(freight::NUMERIC) "AverageFreight"
FROM
  orders o
WHERE
  extract(year from orderdate) = 2015
GROUP BY
  o.shipcountry
ORDER BY
  "AverageFreight" DESC
LIMIT 3;

-- Problem 27. High freight charges with between

SELECT
  orderid,
  orderdate,
  shipcountry,
  freight
FROM
  orders 
WHERE
  extract(year from orderdate) = 2015  
  and 
    extract(month from orderdate) = 12 
EXCEPT
SELECT
  orderid,
  orderdate,
  shipcountry,
  freight
FROM
  orders
WHERE
  orderdate BETWEEN '20150101' AND '20151231' -- The order ID is 10806

-- Problem 28. High freight charges—last year
SELECT
  o.shipcountry,
  round(avg(o.freight::NUMERIC), 4) "AverageFreight"
FROM
  orders o
WHERE
  orderdate BETWEEN (SELECT max(orderdate) - INTERVAL '1 year' FROM orders) AND (SELECT max(orderdate) FROM orders)
GROUP BY
  o.shipcountry
ORDER BY
  avg(o.freight::NUMERIC) DESC
LIMIT 3;

-- Problem 29. Employee/Order Detail report
SELECT
  e.employeeid,
  e.lastname,
  o.orderid,
  p.productname,
  od.quantity
FROM
  employees e
  NATURAL JOIN orders o
  NATURAL JOIN products p
  NATURAL JOIN orderdetails od
ORDER BY
  o.orderid,
  p.productid

/*
Not getting the same row count as in the answer!
*/

-- Problem 30. Customers with no orders
SELECT
  c.customerid customers_customerid,
  o.customerid orders_customerid
FROM
  customers c
  LEFT OUTER JOIN orders o
  ON c.customerid = o.customerid
WHERE
  o.customerid IS NULL;
  
-- Problem 31. Customers with no orders for EmployeeID 4

SELECT
  c.customerid customer_customerid,
  mpo.customerid mp_customerid
FROM
  customers c
  LEFT JOIN
    (SELECT
       o.customerid
     FROM
       orders o
     WHERE
       o.employeeid = 4) mpo
  ON c.customerid = mpo.customerid
WHERE
  mpo.customerid IS NULL;

/*
Building on the previous problem, you might (incorrectly) think you need to do something like this:
                       Select
 Customers.CustomerID
 ,Orders.CustomerID
 From Customers
 left join Orders
 on Orders.CustomerID = Customers.CustomerID
 Where
 Orders.CustomerID is null
 and Orders.EmployeeID = 4
Notice that this filter was added in the where clause:
and Orders.EmployeeID = 4
However, this returns no records.
With outer joins, the filters on the where clause are applied after the join.
*/