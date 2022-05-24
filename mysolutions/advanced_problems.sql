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



