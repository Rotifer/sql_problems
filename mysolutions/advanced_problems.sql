-- Problem 32. High-value customers

SELECT Customers.CustomerID,
       Customers.CompanyName,
       Orders.OrderID,
       sum(Quantity * UnitPrice::NUMERIC) TotalOrderAmount
FROM Customers
JOIN Orders ON Orders.CustomerID = Customers.CustomerID
JOIN OrderDetails ON Orders.OrderID = OrderDetails.OrderID 
WHERE
  OrderDate >= '20160101'
  AND OrderDate < '20170101'
GROUP BY Customers.CustomerID,
         Customers.CompanyName,
         Orders.Orderid
HAVING sum(Quantity * UnitPrice::NUMERIC) > 10000
ORDER BY TotalOrderAmount  DESC

-- Problem 33. High-value customers—total orders

SELECT Customers.CustomerID,
       Customers.CompanyName,
       sum(Quantity * UnitPrice::NUMERIC) TotalOrderAmount
FROM Customers
JOIN Orders ON Orders.CustomerID = Customers.CustomerID
JOIN OrderDetails ON Orders.OrderID = OrderDetails.OrderID 
WHERE
  OrderDate >= '20160101'
  AND OrderDate < '20170101'
GROUP BY Customers.CustomerID,
         Customers.CompanyName
HAVING sum(Quantity * UnitPrice::NUMERIC) > 15000
ORDER BY TotalOrderAmount  DESC

-- Problem 34. High-value customers—with discount 

WITH cte AS(
SELECT od.orderid,
       c.customerid,
       c.companyname,
       od.quantity * od.unitprice::NUMERIC orderamount,
       od.unitprice::NUMERIC * od.quantity * (1 - od.discount) orderamountdiscount
FROM customers c
JOIN orders o ON o.customerid = c.customerid
JOIN orderdetails od ON o.orderid = od.orderid 
WHERE
  o.orderdate >= '20160101'
  AND o.orderdate < '20170101')
SELECT
  customerid,
  companyname,
  sum(orderamount) total_without_discount,
  sum(orderamountdiscount) total_with_discount
FROM
  cte
GROUP BY
  customerid,
  companyname
HAVING
  sum(orderamountdiscount) > 15000
ORDER BY
  total_with_discount DESC;

-- Problem 35. Month-end orders

SELECT
  employeeid,
  orderid,
  orderdate
FROM
  orders
WHERE
  orderdate = date_trunc('month', orderdate) +   interval '1 month - 1 day'
ORDER BY
  employeeid,
  orderid;

/*
Check out date_trunc and interval
*/

-- Problem 36. Orders with many line items

SELECT
  orderid,
  COUNT(productid) total_order_details
FROM
  orderdetails
GROUP BY
  orderid
ORDER BY
  COUNT(productid) DESC
LIMIT 10;

-- Problem 37. Orders—random assortment

SELECT
  orderid
FROM
  orders
ORDER BY
  random()
LIMIT 17;

-- Problem 38. Orders—accidental double-entry

SELECT DISTINCT orderid
FROM
  (SELECT orderid,
          quantity,
          COUNT(productid)
   FROM orderdetails
   WHERE quantity >= 60
   GROUP BY orderid,
            quantity
   HAVING COUNT(productid) > 1) sq
   
-- Problem 39. Orders—accidental double-entry details

SELECT *
FROM orderdetails
WHERE orderid IN
    (SELECT DISTINCT orderid
     FROM
       (SELECT orderid,
               quantity,
               COUNT(productid)
        FROM orderdetails
        WHERE quantity >= 60
        GROUP BY orderid,
                 quantity
        HAVING COUNT(productid) > 1) sqi)
  AND quantity >= 60;
  
  
-- Problem 40 Orders—accidental double-entry details, derived table

SELECT OrderDetails.OrderID,
       ProductID,
       UnitPrice,
       Quantity,
       Discount
FROM OrderDetails
JOIN
  (SELECT DISTINCT OrderID
   FROM OrderDetails
   WHERE Quantity >= 60
   GROUP BY OrderID,
            Quantity
   HAVING Count(*) > 1) PotentialProblemOrders ON PotentialProblemOrders.OrderID = OrderDetails.OrderID
ORDER BY OrderID,
         ProductID
         
/*
Copied the above directly from the book and just added DISTINCT and it works.
But I do not understand the ON sub-clause in the HAVING clause.
Check this out.! It works in both SQL Server and PostgreSQL.
*/

-- Problem 41. Late orders

SELECT
  orderid,
  orderdate::DATE,
  requireddate::DATE,
  shippeddate::DATE
FROM
  orders
WHERE
  shippeddate >= requireddate;
  
-- Problem 42. Late orders—which employees?

SELECT
  e.employeeid,
  e.lastname,
  count(o.orderid) total_late_orders
FROM
  orders o
  NATURAL JOIN employees e
WHERE
  o.shippeddate >= o.requireddate
GROUP BY
  e.employeeid,
  e.lastname
ORDER BY
  total_late_orders DESC;
  
-- Problem 43. Late orders vs. total orders

WITH late_orders AS (
SELECT 
    employeeid,
    count(*) late_orders
FROM
    orders
WHERE
 requiredDate <= shippeddate
GROUP BY
   employeeid),
total_orders AS (
SELECT 
    employeeid,
    count(*) all_orders
FROM 
    orders
GROUP BY 
   employeeid    
)
SELECT
  e.employeeid,
  e.lastname,
  total_orders.all_orders,
  late_orders.late_orders
FROM
  late_orders
  NATURAL JOIN total_orders
  NATURAL JOIN employees e
ORDER BY 1;

-- Problem 44. Late orders vs. total orders—missing employee

WITH late_orders AS (
SELECT 
    employeeid,
    count(*) total_orders
FROM
    orders
WHERE
 requiredDate <= shippeddate
GROUP BY
   employeeid),
all_orders AS (
SELECT 
    employeeid,
    count(*) total_orders
FROM 
    orders
GROUP BY 
   employeeid    
)
SELECT
  e.employeeid,
  e.lastname,
  all_orders.total_orders all_orders,
  late_orders.total_orders late_orders
FROM employees e
JOIN all_orders ON all_orders.employeeid = e.employeeid
LEFT JOIN late_orders ON late_orders.employeeid= e.employeeid
ORDER BY e.employeeid;

/*
Revisit this one
Not got the multiple joins correct when mixing LEFT with INNER.
I need to review this!

See outerjoins_workout.md in repo sqlite/sqlite/general_sql_notes
*/

-- Problem 45. Late orders vs. total orders—fix null

--Used COALESCE

WITH late_orders AS (
SELECT 
    employeeid,
    count(*) total_orders
FROM
    orders
WHERE
 requiredDate <= shippeddate
GROUP BY
   employeeid),
all_orders AS (
SELECT 
    employeeid,
    count(*) total_orders
FROM 
    orders
GROUP BY 
   employeeid    
)
SELECT
  e.employeeid,
  e.lastname,
  all_orders.total_orders all_orders,
  coalesce(late_orders.total_orders, 0) late_orders
FROM employees e
JOIN all_orders ON all_orders.employeeid = e.employeeid
LEFT JOIN late_orders ON late_orders.employeeid= e.employeeid
ORDER BY e.employeeid;

-- 46. Late orders vs. total orders—percentage

WITH late_orders AS (
SELECT 
    employeeid,
    count(*) total_orders
FROM
    orders
WHERE
 requiredDate <= shippeddate
GROUP BY
   employeeid),
all_orders AS (
SELECT 
    employeeid,
    count(*) total_orders
FROM 
    orders
GROUP BY 
   employeeid    
)
SELECT
  e.employeeid,
  e.lastname,
  all_orders.total_orders all_orders,
  coalesce(late_orders.total_orders, 0) late_orders,
  coalesce(late_orders.total_orders, 0)::NUMERIC/all_orders.total_orders percent_late_orders
FROM employees e
JOIN all_orders ON all_orders.employeeid = e.employeeid
LEFT JOIN late_orders ON late_orders.employeeid= e.employeeid
ORDER BY e.employeeid;

/*
An integer divided by an integer returns an integer. Casting one or other of the numerator or denominator to NUMERIC
gets around this problem and returns a type NUMERIC rather than INTEGER.
*/

-- 47. Late orders vs. total orders—fix decimal

WITH late_orders AS (
SELECT 
    employeeid,
    count(*) total_orders
FROM
    orders
WHERE
 requiredDate <= shippeddate
GROUP BY
   employeeid),
all_orders AS (
SELECT 
    employeeid,
    count(*) total_orders
FROM 
    orders
GROUP BY 
   employeeid    
)
SELECT
  e.employeeid,
  e.lastname,
  all_orders.total_orders all_orders,
  coalesce(late_orders.total_orders, 0) late_orders,
  round(coalesce(late_orders.total_orders, 0)::NUMERIC/all_orders.total_orders, 2) percent_late_orders
FROM employees e
JOIN all_orders ON all_orders.employeeid = e.employeeid
LEFT JOIN late_orders ON late_orders.employeeid= e.employeeid
ORDER BY e.employeeid;

-- Added the round function to do this.

-- 48. Customer grouping

SELECT
  c.customerid,
  c.contactname,
  SUM(od.unitprice * od.quantity) total_order_amount,
  CASE
    WHEN SUM(od.unitprice::NUMERIC * od.quantity) BETWEEN 0 AND 1000 THEN 'Low'
    WHEN SUM(od.unitprice::NUMERIC * od.quantity) BETWEEN 1000 AND 5000 THEN 'Medium'
    WHEN SUM(od.unitprice::NUMERIC * od.quantity) BETWEEN 5000 AND 10000 THEN 'High'
    WHEN SUM(od.unitprice::NUMERIC * od.quantity) >= 10000 THEN 'Very High'
  END customer_group
FROM
  customers c
  JOIN
    orders o ON c.customerid = o.customerid
  JOIN
    orderdetails od ON o.orderid = od.orderid
WHERE
  EXTRACT(YEAR FROM o.orderdate) = 2016
GROUP BY
  c.customerid,
  c.contactname  
ORDER BY
  c.customerid;
  
-- Note:Need to cast money type to numeric in the CASE statement to get this to work.

-- 49. Customer grouping—fix null

/*
There's a problem with the answer to the previous question. The CustomerGroup value for one of the rows is null.
Fix the SQL so that there are no nulls in the CustomerGroup field.
*/

/*
This is not true for PostgreSQL, no NULL for the MAISD entry. In PostgreSQL, all 81 values are non-null using the SQL
for the previous problem.
*/

-- 50. Customer grouping with percentage

WITH cte AS(SELECT
  c.customerid,
  c.contactname,
  SUM(od.unitprice * od.quantity) total_order_amount,
  CASE
    WHEN SUM(od.unitprice::NUMERIC * od.quantity) BETWEEN 0 AND 1000 THEN 'Low'
    WHEN SUM(od.unitprice::NUMERIC * od.quantity) BETWEEN 1000 AND 5000 THEN 'Medium'
    WHEN SUM(od.unitprice::NUMERIC * od.quantity) BETWEEN 5000 AND 10000 THEN 'High'
    WHEN SUM(od.unitprice::NUMERIC * od.quantity) >= 10000 THEN 'Very High'
  END customer_group
FROM
  customers c
  JOIN
    orders o ON c.customerid = o.customerid
  JOIN
    orderdetails od ON o.orderid = od.orderid
WHERE
  EXTRACT(YEAR FROM o.orderdate) = 2016
GROUP BY
  c.customerid,
  c.contactname  
ORDER BY
  c.customerid),
totals AS (SELECT
  customer_group,
  count(customerid) total_in_group,
  SUM(count(customerid)) OVER() total
FROM 
  cte
GROUP BY
  customer_group
)
SELECT
  customer_group,
  total_in_group,
  total_in_group::NUMERIC/total percentage_in_group
FROM
  totals
ORDER BY
  total_in_group DESC;

-- Note the use of SUM as a window function.

-- 51. Customer grouping—flexible

WITH orders_totals_2016 AS (SELECT
  c.customerid,
  c.companyname,
  sum(od.quantity * od.unitprice) total_order_amount                      
FROM 
  customers c
  JOIN orders o ON o.customerid = c.customerid
  JOIN orderdetails od ON o.orderid = od.orderid
WHERE
  o.orderdate >= '20160101'
  AND
    o.orderdate  < '20170101'
GROUP BY
  c.customerid,
  c.companyname)
SELECT
  ot.customerid,
  ot.companyname,
  ot.total_order_amount,
  cgt.customergroupname 
FROM
  orders_totals_2016 ot
  JOIN customergroupthresholds cgt 
    ON (ot.total_order_amount > cgt.rangebottom AND ot.total_order_amount <= cgt.rangetop)
ORDER BY
  ot.customerid;
  
-- 52. Countries with suppliers or customers

SELECT
  country
FROM
  customers
UNION
SELECT
  country
FROM
  suppliers
ORDER BY 1;

-- 53. Countries with suppliers or customers, version 2

SELECT DISTINCT
  s.country supplier_country,
  c.country customer_country
FROM
  customers c
  FULL OUTER JOIN suppliers s ON c.country = s.country
ORDER BY 1, 2 NULLS FIRST;

-- 54. Countries with suppliers or customers, version 3

WITH supplier_country_totals AS (
SELECT
  s.country supplier_country,
  count(supplierid) total_suppliers
FROM
  suppliers s
GROUP BY
  s.country),
customer_country_totals AS (
SELECT
  c.country customer_country,
  count(customerid) total_customers
FROM
  customers c
GROUP BY
  c.country)
SELECT
  coalesce(cct.customer_country, sct.supplier_country) country,
  coalesce(sct.total_suppliers, 0) total_suppliers,
  coalesce(cct.total_customers, 0) total_customers
FROM 
  supplier_country_totals sct
  FULL OUTER JOIN  customer_country_totals cct ON sct.supplier_country = cct.customer_country
ORDER BY 1;

-- 55. First order in each country

WITH orders_ordered AS (
SELECT
  shipcountry,
  customerid,
  orderid,
  orderdate,
  row_number() OVER (PARTITION BY shipcountry ORDER BY shipcountry, orderid) ordered
FROM
  orders)
SELECT
  shipcountry,
  customerid,
  orderid,
  date(orderdate) orderdate
FROM
 orders_ordered
WHERE
  ordered = 1;
  
  
-- 56. Customers with multiple orders in 5 day period

WITH orders_days AS (
SELECT 
    initialorder.customerid,
    initialorder.orderid initialorderid,
    date(initialorder.orderdate) initialorderdate,
    nextorder.orderid nextorderid,
    date(nextorder.orderdate) nextorderdate,
    date(nextorder.orderdate) - date(initialorder.orderdate) days_between_orders
FROM 
    orders initialorder
JOIN orders nextorder ON initialorder.customerid = nextorder.customerid
WHERE
  nextOrder.orderdate > initialorder.orderdate
ORDER BY 
    initialorder.customerid,
    initialorder.orderid)
SELECT
  *
FROM
  orders_days
WHERE
  days_between_orders BETWEEN 0 AND 5;
  
/*
I only get 69 rows here, expected row count is 71

NEED TO RE-CHECK
*/

-- 57. Customers with multiple orders in 5 day period, version 2

WITH orders_lead_dates AS (
SELECT
  customerid,
  date(orderdate) orderdate,
  date(LEAD(orderdate,1) OVER (PARTITION BY customerid ORDER BY customerid, orderdate)) next_order_date
FROM
  orders
ORDER BY
  customerid,
  orderid)
SELECT
  customerid,
  orderdate,
  next_order_date,
  next_order_date - orderdate days_between_orders
FROM
  orders_lead_dates
WHERE
  (next_order_date - orderdate) <= 5

