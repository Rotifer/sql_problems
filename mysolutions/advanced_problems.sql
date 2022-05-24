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