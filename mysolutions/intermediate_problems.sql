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


