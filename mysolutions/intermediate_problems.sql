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




