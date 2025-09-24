-- Q.1 Coffee Consumers Count
-- How many people in each city are estimated to consume coffee, given that 25% of the population does?
SELECT 
    city_name,
    ROUND((MAX(population) * 0.25) / 1000000, 2) AS coffee_consumers_in_millions,
    MAX(city_rank) AS city_rank
FROM total_informations
GROUP BY city_name
ORDER BY coffee_consumers_in_millions DESC;


-- Q.2
-- Total Revenue from Coffee Sales
-- What is the total revenue generated from coffee sales across all cities in the last quarter of 2023?
SELECT 
	SUM(total) as total_revenue
FROM total_informations
WHERE 
	YEAR(sale_date)  = 2023
	AND
	DATEPART(QUARTER,sale_date) = 4 ;

SELECT 
	city_name,
	SUM(total) as total_revenue
FROM total_informations
WHERE 
	YEAR  (sale_date)  = 2023
	AND
	DATEPART (quarter , sale_date) = 4
GROUP BY city_name
ORDER BY 2 DESC

-- Q.3
-- Sales Count for Each Product
-- How many units of each coffee product have been sold?
SELECT 
     product_name ,
	 COUNT(sale_id) total_orders
FROM total_informations
GROUP BY product_name
ORDER BY 2 DESC


-- Q.4
-- Average Sales Amount per City
-- What is the average sales amount per customer in each city?

SELECT 
	city_name,
	SUM(total) as total_revenue,
	COUNT(DISTINCT customer_id) as total_cx,
	ROUND(
			CAST(SUM(total)AS numeric)/
				CAST(COUNT(DISTINCT customer_id)AS numeric)
			,2) as avg_sale_pr_cx
FROM total_informations
GROUP BY city_name
ORDER BY 2 DESC

-- Q.5
-- City Population and Coffee Consumers (25%)
-- Provide a list of cities along with their populations and estimated coffee consumers.
-- return city_name, total current cx, estimated coffee consumers (25%)

SELECT 
city_name ,
ROUND ((MAX(population) * .25)/1000000 ,2)AS coffee_consumer_in_millions,
COUNT(DISTINCT customer_id) AS unique_cx
FROM total_informations
GROUP BY city_name

-- -- Q6
-- Top Selling Products by City
-- What are the top 3 selling products in each city based on sales volume?

SELECT * 
FROM -- table
(
	SELECT 
		city_name,
		product_name,
		COUNT(sale_id) as total_orders,
		DENSE_RANK() OVER(PARTITION BY city_name ORDER BY COUNT(sale_id) DESC) as rank
	FROM total_informations
	GROUP BY city_name, product_name
	-- ORDER BY 1, 3 DESC
) as t1
WHERE rank <= 3


SELECT * FROM products;


-- Q.7
-- Customer Segmentation by City
-- How many unique customers are there in each city who have purchased coffee products?

SELECT * FROM products;
SELECT 
	city_name,
	COUNT(DISTINCT customer_id) as unique_cx
FROM total_informations
WHERE 
	product_id BETWEEN 1 AND 14
GROUP BY city_name ;

-- -- Q.8
-- Average Sale vs Rent
-- Find each city and their average sale per customer and avg rent per customer

-- Conclusions

WITH city_calc AS (
    SELECT 
        city_name,
        SUM(total) AS total_revenue,
        COUNT(DISTINCT customer_id) AS total_cx,
        ROUND(
            CAST(SUM(total) AS numeric) /
            CAST(COUNT(DISTINCT customer_id) AS numeric),
            2
        ) AS avg_sale_pr_cx,
        estimated_rent
    FROM total_informations
    GROUP BY city_name, estimated_rent
)
SELECT 
    city_name,
    estimated_rent,
    total_cx,
    avg_sale_pr_cx,
    ROUND(
        CAST(estimated_rent AS numeric) / 
        CAST(total_cx AS numeric),
        2
    ) AS avg_rent_per_cx
FROM city_calc
ORDER BY avg_sale_pr_cx DESC;

-- Q.9
-- Monthly Sales Growth
-- Sales growth rate: Calculate the percentage growth (or decline) in sales over different time periods (monthly)
-- by each city

WITH monthly_sales AS (
    SELECT 
        city_name,
        MONTH(sale_date) AS month,
        YEAR(sale_date) AS year,
        SUM(total) AS total_sale
    FROM total_informations
    GROUP BY city_name, MONTH(sale_date), YEAR(sale_date)
),
growth_ratio AS (
    SELECT
        city_name,
        month,
        year,
        total_sale AS cr_month_sale,
        LAG(total_sale, 1) OVER (
            PARTITION BY city_name 
            ORDER BY year, month
        ) AS last_month_sale
    FROM monthly_sales
)
SELECT
    city_name,
    month,
    year,
    cr_month_sale,
    last_month_sale,
    CASE 
        WHEN last_month_sale = 0 THEN NULL
        ELSE ROUND(
            CAST(cr_month_sale - last_month_sale AS numeric) /
            CAST(last_month_sale AS numeric) * 100, 
            2
        )
    END AS growth_ratio
FROM growth_ratio
WHERE last_month_sale IS NOT NULL
ORDER BY city_name, year, month;

-- Q.10
-- Market Potential Analysis
-- Identify top 3 city based on highest sales, return city name, total sale, total rent, total customers, estimated coffee consumer

WITH city_table AS (
    SELECT 
        city_name,
        SUM(total) AS total_revenue,
        COUNT(DISTINCT customer_id) AS total_cx,
        ROUND(
            CAST(SUM(total) AS numeric) /
            CAST(COUNT(DISTINCT customer_id) AS numeric),
            2
        ) AS avg_sale_pr_cx,
        estimated_rent,
        ROUND((population * 0.25) / 1000000, 3) AS estimated_coffee_consumer_in_millions
    FROM total_informations
    GROUP BY city_name, estimated_rent, population   -- ✅ Added here
)
SELECT TOP 3
    city_name,
    total_revenue,
    estimated_rent AS total_rent,
    total_cx,
    estimated_coffee_consumer_in_millions,
    avg_sale_pr_cx,
    ROUND(
        CAST(estimated_rent AS numeric) /
        CAST(total_cx AS numeric),
        2
    ) AS avg_rent_per_cx
FROM city_table
ORDER BY total_revenue DESC;




/*
-- Recomendation
City 1: Pune
	1.Average rent per customer is very low.
	2.Highest total revenue.
	3.Average sales per customer is also high.

City 2: Delhi
	1.Highest estimated coffee consumers at 7.7 million.
	2.Highest total number of customers, which is 68.
	3.Average rent per customer is 330 (still under 500).

City 3: Jaipur
	1.Highest number of customers, which is 69.
	2.Average rent per customer is very low at 156.
	3.Average sales per customer is better at 11.6k.
