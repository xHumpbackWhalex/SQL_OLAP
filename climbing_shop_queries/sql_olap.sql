
/* 
Climbing Shop - Vancouver 2022
*/
USE climbing;

-- https://www.sqlservertutorial.net/sql-server-sample-database/
-- Check the rows in the sales.sales_summary table
SELECT *
FROM   sales.sales_summary;


-- Obtain the total sales of each (brand, category) brand for the last winter session.
SELECT brand,
       category,
       Sum(sales) AS total_sales
FROM   sales.sales_summary
GROUP  BY brand,
          category
ORDER  BY brand,
          category;


-- Obtain the total sales of each brand across all categories
SELECT brand,
       Sum(sales) AS total_sales
FROM   sales.sales_summary
GROUP  BY brand
ORDER  BY brand;

-- Obtain the total sales of each category across all brands
-- 7 rows in the result
SELECT category,
       Sum(sales) AS total_sales
FROM   sales.sales_summary
GROUP  BY category
ORDER  BY category;


-- The grand total of all brands all categories
-- 1 rows in the result
SELECT Sum(sales) AS total_sales
FROM   sales.sales_summary


-- CUBE FUNCTION
-- to get all the subtotals and the grand total
SELECT brand,
       category,
       Sum(sales) AS total_sales
FROM   sales.sales_summary
GROUP  BY cube( brand, category );


-- COALESCE FUNCTION
-- Some improvement to deal with the NULL value. 
SELECT COALESCE(brand, 'All brands')        AS brand,
       COALESCE(category, 'All categories') AS category,
       Sum(sales)                           AS total_sales
FROM   sales.sales_summary
GROUP  BY cube( brand, category );


-- A slice on brand = 'Powell Peralta'.
SELECT COALESCE(brand, 'All brands')        AS brand,
       COALESCE(category, 'All categories') AS category,
       Sum(sales)                           AS total_sales
FROM   sales.sales_summary
GROUP  BY cube( brand, category )
HAVING brand = 'Petzl';


-- Can you use a WHERE clause instead of the HAVING clause?
SELECT COALESCE(brand, 'All brands')        AS brand,
       COALESCE(category, 'All categories') AS category,
       Sum(sales)                           AS total_sales
FROM   sales.sales_summary
WHERE  brand = 'Patagonia'
GROUP  BY cube( brand, category );


-- A dice on brand and category
-- Similarly, can you use a WHERE clause instead?
SELECT COALESCE(brand, 'All brands')        AS brand,
       COALESCE(category, 'All categories') AS category,
       Sum(sales)                           AS total_sales
FROM   sales.sales_summary
GROUP  BY cube( brand, category )
HAVING brand IN ( 'Patagonia', 'BlackDiamond' )
       AND category IN ( 'RainJacket', 'BackPack' );

-- NOTE: you should using HAVING clause after GROUP BY CUBE !!!
-- A rollup example with city rollup to state
SELECT state,
       city,
       Count(customer_id) AS num_customers
FROM   sales.customers
GROUP  BY rollup ( state, city );


-- It does not make sense to roll up from state to city
SELECT city,
       state,
       Count(customer_id) AS num_customers
FROM   sales.customers
GROUP  BY rollup ( city, state );


-- Partial rollup
SELECT state,
       city,
       Count(customer_id) AS num_customers
FROM   sales.customers
GROUP  BY state,
          rollup ( city );

-- Show the number of Snow Pants for categories Women's Pants and Men's Pantas of brands Patagonia and North Face
-- Use WHERE clause since it is GROUP BY, not GROUP BY CUBE, and aggregation functions are not used in the filter
SELECT brand_name,
       category_name,
       Count(product_id) AS num_bikes
FROM   production.products AS p
       JOIN production.categories AS c
         ON p.category_id = c.category_id
       JOIN production.brands AS b
         ON b.brand_id = p.brand_id
WHERE  brand_name IN ( 'Patagonia', 'NorthFace' )
       AND category_name IN ( 'Women Pants', 'Men Pantas' )
GROUP  BY brand_name,
          category_name;


-- Convert it into cross-tab using the pivot operator
SELECT *
FROM   (SELECT brand_name AS Brand,
               category_name,
               product_id
        FROM   production.products AS p
               JOIN production.categories AS c
                 ON p.category_id = c.category_id
               JOIN production.brands AS b
                 ON b.brand_id = p.brand_id
        WHERE  brand_name IN ( 'Patagonia', 'NorthFace' )) AS t
       PIVOT ( Count(product_id)
             FOR category_name IN ( [Children Bicycles],
                                    [Electric Bikes]) ) AS pivot_table;


-- Or use a WITH clause
WITH t
     AS (SELECT brand_name AS Brand,
                category_name,
                product_id
         FROM   production.products AS p
                JOIN production.categories AS c
                  ON p.category_id = c.category_id
                JOIN production.brands AS b
                  ON b.brand_id = p.brand_id
         WHERE  brand_name IN ( 'Electra', 'Trek' ))
SELECT *
FROM   t
       PIVOT ( Count(product_id)
             FOR category_name IN ( [Children Bicycles],
                                    [Electric Bikes]) ) AS pivot_table;


-- rename the pivot values in the SELECT clause 
SELECT brand,
       [children bicycles] AS Children,
       [electric bikes]    AS Electric
FROM   (SELECT brand_name AS Brand,
               category_name,
               product_id
        FROM   production.products AS p
               JOIN production.categories AS c
                 ON p.category_id = c.category_id
               JOIN production.brands AS b
                 ON b.brand_id = p.brand_id
        WHERE  brand_name IN ( 'Patagonia', 'NorthFace' )) AS t
       PIVOT ( Count(product_id)
             FOR category_name IN ( [Children Bicycles],
                                    [Electric Bikes]) ) AS pivot_table;


-- Add model_year as a non-pivoted column and order by brand
SELECT *
FROM   (SELECT brand_name AS Brand,
               model_year AS Year,
               category_name,
               product_id
        FROM   production.products AS p
               JOIN production.categories AS c
                 ON p.category_id = c.category_id
               JOIN production.brands AS b
                 ON b.brand_id = p.brand_id
        WHERE  brand_name IN ( 'Electra', 'Trek' )) AS t
       PIVOT ( Count(product_id)
             FOR category_name IN ( [Children Bicycles],
                                    [Electric Bikes]) ) AS pivot_table
ORDER  BY brand; 
