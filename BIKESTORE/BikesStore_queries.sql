
use BikeStores;


/*For each store, display the store name and the number of pending orders of the store and sort 
the result in descending order of the number of pending orders (you may check order_status in the DDL)*/

SELECT store_name,
       Count(order_status) AS num_pending_orders
FROM   sales.orders
       JOIN sales.stores
         ON orders.store_id = stores.store_id
WHERE  order_status < 4
GROUP  BY store_name
ORDER  BY num_pending_orders DESC; 


/*Find the number of completed orders handled by each staff at the Rocky Bikes store. 
The result should display each staff's first name, last name, and the number of completed orders handled by the staff. 
No need to display the staff who didn't handle any completed orders.
*/

SELECT first_name,
       last_name,
       Count(order_status) AS completed_orders
FROM   sales.staffs
       JOIN sales.stores
         ON staffs.store_id = stores.store_id
       JOIN sales.orders
         ON orders.store_id = staffs.store_id
WHERE  order_status = 4
       AND store_name = 'Rocky Bikes'
GROUP  BY first_name,
          last_name;  

/*Use the GROUP BY CUBE operator to obtain the subtotals and grand total of inventory for store_name and brand_name. 
The stocks table stores the inventory (quantity) of a particular product at a specific store. 
Use the COALESCE() function properly to deal with NULL values.
Include at least the first 20 rows from the result in the screenshot.*/

SELECT COALESCE(store_name, 'All_store_name') AS store_name,
       COALESCE(brand_name, 'All_brand_name') AS brand_name,
       Count(quantity)                        AS Total_Stock
FROM   sales.orders
       JOIN sales.stores
         ON orders.store_id = stores.store_id
       JOIN production.stocks
         ON orders.store_id = stocks.store_id
       JOIN production.products
         ON products.product_id = stocks.product_id
       JOIN production.brands
         ON brands.brand_id = products.brand_id
GROUP  BY cube( store_name, brand_name );  


/*Create a pivot table that displays the total inventory of products from the brands Pure Cycles and Surly at each store, 
which should look like the following (a watermark was added to the picture)*/

WITH t
     AS (SELECT store_name,
                brand_name,
                quantity
         FROM   sales.stores
                JOIN production.stocks
                  ON stores.store_id = stocks.store_id
                JOIN production.products
                  ON products.product_id = stocks.product_id
                JOIN production.brands
                  ON brands.brand_id = products.brand_id
         WHERE  brand_name IN ( 'Pure Cycles', 'Surly' ))
SELECT *
FROM   t
       PIVOT ( Sum(quantity)
             FOR store_name IN ( [Epicenter Bikes],
                                 [Rocky Bikes],
                                 [Rowlett Bikes] ) ) AS pivot_table;  

/*Create a nonclustered index ix_staffs_first_name_phone on the first_name and phone columns of the staffs table.*/

create nonclustered index ix_staffs_first_name_phone on
		sales.staffs (first_name, phone);

execute sp_helpindex staffs;


/********************** Standard Deviation & Variance ********************************************/

/* How spread out the unit sold in each month? */
/* As we can see from the result, variance values quite high. Because variance measures in squared. 
So better way to get a sense of spread out is standard deviation */

SELECT product_name,
       Sum(quantity)           AS total_quantity,
       Round(Avg(quantity), 2) AS average_quantity,
       Varp(quantity)          AS variance_quantity,
       Stdevp(quantity)        AS st_dev_quantity
FROM   sales.order_items AS o
       JOIN production.products AS s
         ON o.product_id = s.product_id
GROUP  BY s.product_name
ORDER BY total_quantity DESC;  

/* Interpretation based on data: 
there were 296 units solds of Electra Cruiser 1 (24-Inch) 2016 model */

/*list of min and max order made per date*/ 
SELECT order_date,
       Min(quantity) AS min_quantity,
       Max(quantity) AS max_quantity
FROM   sales.order_items AS o
       JOIN sales.orders AS s
         ON o.order_id = s.order_id
GROUP  BY s.order_date
ORDER  BY s.order_date ASC;  
