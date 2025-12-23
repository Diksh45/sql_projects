-- SQL RETAIL SALES ANALYSIS
CREATE DATABASE sales;

--drop table
DROP TABLE IF EXISTS retailSales;

--create table
create table retailSales(
	transactions_id INT PRIMARY KEY,
	sale_date DATE,
	sale_time TIME,
	customer_id INT,
	gender VARCHAR(10),
	age INT,
	category VARCHAR(30),
	quantiy INT,
	price_per_unit FLOAT,
	cogs FLOAT,
	total_sale FLOAT
);

--add data from csv file
COPY retailSales
FROM 'D:\analyst\sql\projets\sales\SQL - Retail Sales Analysis_utf .csv'
CSV HEADER;

SELECT * FROM retailSales;

--total sales
SELECT COUNT(*) FROM retailSales;

--total customers
SELECT COUNT(customer_id) as tot_customers FROM retailSales;

--total unique customers nd category
SELECT COUNT(DISTINCT customer_id) as tot_customers FROM retailSales;
SELECT COUNT(DISTINCT category) as tot_customers FROM retailSales;

--change column name
ALTER TABLE retailSales
RENAME COLUMN quantiy TO quantity;

--find null value
SELECT * FROM retailSales
WHERE 
	transactions_id IS NULL
	OR
	category IS NULL
	OR
	sale_time IS NULL
	OR
	gender IS NULL
	OR
	age IS NULL
	OR
	quantity IS NULL
	OR
	price_per_unit IS NULL
	OR
	cogs IS NULL
	OR
	total_sale IS NULL;

--delete null rows
DELETE FROM retailSales
WHERE 
	transactions_id IS NULL
	OR
	category IS NULL
	OR
	sale_time IS NULL
	OR
	gender IS NULL
	OR
	age IS NULL
	OR
	quantity IS NULL
	OR
	price_per_unit IS NULL
	OR
	cogs IS NULL
	OR
	total_sale IS NULL;

--Data analysis nd business key problems

--Q1.Retrive all columns for sales made on '2022-11-05'
SELECT * FROM retailSales
WHERE sale_date = '2022-11-05';

--Q2.Retrive all transactions where category is 'clothing' and the quantity sold is more than/ equal to 4 in the month of nov-2022
SELECT * 
FROM retailSales
WHERE category = 'Clothing'
	AND 
	TO_CHAR(sale_date, 'YYYY-MM') = '2022-11'
	AND 
	quantity >=4

--Q3.calculate total sale for each category
SELECT category, SUM(total_sale) as tot_sale 
FROM retailSales
GROUP BY category;

--Q4.find avg age of customers who purchased items from beauty category
SELECT category, AVG(age) as avg_age
FROM retailSales
WHERE category = 'Beauty'
GROUP BY category;

--Q5.find transactions where total_sale is more than 1000
SELECT * 
FROM retailSales
WHERE total_sale > 1000;

--Q6.find total num of transactions (transactions_id) made by each gender in each category
SELECT category, gender, COUNT(transactions_id)
FROM retailSales
GROUP BY category, gender;

--Q7.calculate avg sale for each month find best selling month in each year[MOST IMP]
SELECT year, month, avg_sale
FROM (
	SELECT EXTRACT(YEAR FROM sale_date) AS year,
		   EXTRACT(MONTH FROM sale_date) AS month,
		   AVG(total_sale) AS avg_sale,
		   RANK() OVER(PARTITION BY EXTRACT(YEAR FROM sale_date) ORDER BY AVG(total_sale) DESC) AS rank
FROM retailSales
GROUP BY 1, 2 
) AS t1
WHERE rank = 1;

-- Q8.find top 5 customers based on the highest total sales
SELECT customer_id, sum(total_sale) as sale
FROM retailSales
GROUP BY 1
ORDER BY 2 DESC LIMIT 5;

-- Q9.find no of unique customers who purchased item from each category
SELECT category, 
	   COUNT(DISTINCT customer_id) AS unique_customer_id
FROM retailSales
GROUP BY 2
	  
-- Q10.create each shift & no of orders (Example: morning <12 afternoon btw 12 & 17 evening >17)
SELECT *,
	CASE
		WHEN EXTRACT(HOUR FROM sale_time) < 12 THEN 'Morning'
		WHEN EXTRACT(HOUR FROM sale_time) BETWEEN 12 AND 17 THEN 'Afternoon'
		ELSE 'Evening'
	END AS shift
FROM retailSales;

-- Q11.find orders we have got from no of shifts [CTE is used here]
WITH hourly_sales
AS
(
SELECT *,
	CASE
		WHEN EXTRACT(HOUR FROM sale_time) < 12 THEN 'Morning'
		WHEN EXTRACT(HOUR FROM sale_time) BETWEEN 12 AND 17 THEN 'Afternoon'
		ELSE 'Evening'
	END AS shift
FROM retailSales
)
SELECT shift, COUNT(*) AS total_orders FROM hourly_sales
GROUP BY shift


