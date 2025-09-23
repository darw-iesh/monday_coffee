/*
This SQL query joins sales, products, customers, and city tables to gather detailed sales information, 
then uses a CTE to organize the data and creates a new table (total_informations) containing all combined results.
*/
IF OBJECT_ID('total_informations') IS NOT NULL
    DROP TABLE total_informations;

WITH total_information AS 
(
SELECT 
	 cus.customer_id,
	 s.sale_id,
	 c.city_id,
	 pro.product_id,
	 cus.customer_name,
	 pro.product_name,
	 c.city_name,
	 s.total,
	 pro.price,
	 c.estimated_rent,
	 c.population,
	 c.city_rank,
	 s.sale_date
FROM sales  s
LEFT JOIN products pro
ON s.product_id=pro.product_id
LEFT JOIN customers cus
ON s.customer_id=cus.customer_id
LEFT JOIN city c
ON cus.city_id=c.city_id
)
SELECT *
INTO  total_informations  
FROM total_information
