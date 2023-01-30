
/* 
Climbing Shop - Vancouver 2022
*/

use Climbing;
-- https://www.sqlservertutorial.net/sql-server-sample-database/

-- Check the rows in the sales.sales_summary table
select	*
from	sales.sales_summary;

-- Obtain the total sales of each (brand, category) brand for the last winter session.

select	brand, category, sum(sales) as total_sales
from	sales.sales_summary
group by brand, category
order by brand, category;

-- Obtain the total sales of each brand across all categories

select	brand, sum(sales) as total_sales
from	sales.sales_summary
group by brand
order by brand;

-- Obtain the total sales of each category across all brands
-- 7 rows in the result
select	category, sum(sales) as total_sales
from	sales.sales_summary
group by category
order by category;

-- The grand total of all brands all categories
-- 1 rows in the result
select	sum(sales) as total_sales
from	sales.sales_summary

-- CUBE FUNCTION
-- to get all the subtotals and the grand total

select	brand, category, sum(sales) as total_sales
from	sales.sales_summary
group by cube(brand, category);


-- COALESCE FUNCTION
-- Some improvement to deal with the NULL value. 

select	coalesce(brand, 'All brands') as brand, 
		coalesce(category, 'All categories') as category,  
		sum(sales) as total_sales
from	sales.sales_summary
group by cube(brand, category);

-- A slice on brand = 'Powell Peralta'.
select	coalesce(brand, 'All brands') as brand, 
		coalesce(category, 'All categories') as category,  
		sum(sales) as total_sales
from	sales.sales_summary
group by cube(brand, category)
having	brand = 'Petzl';

-- Can you use a WHERE clause instead of the HAVING clause?
select	coalesce(brand, 'All brands') as brand, 
		coalesce(category, 'All categories') as category,  
		sum(sales) as total_sales
from	sales.sales_summary
where	brand = 'Patagonia'
group by cube(brand, category);

-- A dice on brand and category
-- Similarly, can you use a WHERE clause instead?
select	coalesce(brand, 'All brands') as brand, 
		coalesce(category, 'All categories') as category,  
		sum(sales) as total_sales
from	sales.sales_summary
group by cube(brand, category)
having	brand in ('Patagonia', 'BlackDiamond')
and		category in ('RainJacket', 'BackPack');

-- NOTE: you should using HAVING clause after GROUP BY CUBE !!!

-- A rollup example with city rollup to state

select	state, city, count(customer_id) as num_customers
from	sales.customers
group by rollup (state, city);

-- It does not make sense to roll up from state to city
select	city, state, count(customer_id) as num_customers
from	sales.customers
group by rollup (city, state);

-- Partial rollup

select	state, city, count(customer_id) as num_customers
from	sales.customers
group by state, rollup (city);

-- Show the number of Snow Pants for categories Women's Pants and Men's Pantas of brands Patagonia and North Face
-- Use WHERE clause since it is GROUP BY, not GROUP BY CUBE, and aggregation functions are not used in the filter
select	brand_name, category_name, count(product_id) as num_bikes
from	production.products as p
				join	production.categories as c
					on p.category_id = c.category_id
				join	production.brands as b
					on b.brand_id = p.brand_id
where	brand_name in ('Patagonia', 'NorthFace')
and		category_name in ('Women Pants', 'Men Pantas')
group by brand_name, category_name;	

-- Convert it into cross-tab using the pivot operator

select	*
from	(
			select	brand_name as Brand,
					category_name,
					product_id
			from	production.products as p
				join	production.categories as c
					on p.category_id = c.category_id
				join	production.brands as b
					on b.brand_id = p.brand_id
			where brand_name in ('Patagonia', 'NorthFace')
		) as t
pivot	(
			count(product_id)
			for	category_name in (
				[Children Bicycles],
				[Electric Bikes])
		) as pivot_table;

-- Or use a WITH clause
with t as 
(
	select	brand_name as Brand,
			category_name,
			product_id
	from	production.products as p
			join	production.categories as c
				on p.category_id = c.category_id
			join	production.brands as b
				on b.brand_id = p.brand_id
	where brand_name in ('Electra', 'Trek')		
)
select	*
from	t
pivot	(
			count(product_id)		
			for	category_name in (	
				[Children Bicycles],
				[Electric Bikes])
		) as pivot_table;	

-- rename the pivot values in the SELECT clause 
select	Brand, 
		[Children Bicycles] as Children,
		[Electric Bikes] as Electric
from	(
			select	brand_name as Brand,
					category_name,
					product_id
			from	production.products as p
				join	production.categories as c
					on p.category_id = c.category_id
				join	production.brands as b
					on b.brand_id = p.brand_id
			where brand_name in ('Patagonia', 'NorthFace')	
		) as t
pivot	(
			count(product_id)		
			for	category_name in (	
				[Children Bicycles],
				[Electric Bikes])
		) as pivot_table;

-- Add model_year as a non-pivoted column and order by brand
select	*	
from	(
			select	brand_name as Brand,
					model_year as Year,
					category_name,
					product_id
			from	production.products as p
				join	production.categories as c
					on p.category_id = c.category_id
				join	production.brands as b
					on b.brand_id = p.brand_id
			where brand_name in ('Electra', 'Trek')
		) as t
pivot	(
			count(product_id)
			for	category_name in (
				[Children Bicycles],
				[Electric Bikes])
		) as pivot_table
order by Brand;
