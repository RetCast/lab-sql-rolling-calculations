USE sakila;

#In this lab, you will be using the Sakila database of movie rentals.

#Instructions
# 1. Get number of monthly active customers.
SELECT * FROM rental;

CREATE OR REPLACE VIEW active_customers AS
SELECT customer_id, CONVERT(rental_date, date) AS activity_date,
date_format(convert(rental_date,date), '%Y') as activity_year,
date_format(convert(rental_date,date), '%M') as activity_month,
date_format(convert(rental_date,date), '%m') as activity_month_number
FROM rental;

SELECT * FROM active_customers;

CREATE OR REPLACE VIEW monthly_active_customers AS
SELECT COUNT(customer_id) AS active_customers, activity_year, activity_month_number 
FROM active_customers
GROUP BY activity_year, activity_month_number
ORDER BY 2,3;

SELECT * FROM monthly_active_customers;

# 2. Active users in the previous month.
SELECT activity_year, activity_month_number, active_customers,
LAG(active_customers,1) OVER (ORDER BY activity_year, activity_month_number) AS active_customers_last_month
FROM monthly_active_customers;

# 3. Percentage change in the number of active customers.

WITH cte_view_percentage AS (
	SELECT activity_year, activity_month_number, active_customers,
	LAG(active_customers,1) OVER (ORDER BY activity_year, activity_month_number) AS active_customers_last_month
	FROM monthly_active_customers
)
SELECT activity_year, activity_month_number, active_customers, active_customers_last_month,
   (active_customers - active_customers_last_month) AS difference,
   (active_customers - active_customers_last_month) / active_customers_last_month*100 AS percentage_change
FROM cte_view_percentage;

# 4. Retained customers every month.
SELECT DISTINCT customer_id AS active_id, activity_year, activity_month_number AS activity_month
FROM active_customers;

CREATE OR REPLACE VIEW distinct_users AS
SELECT DISTINCT customer_id AS active_id, activity_year, activity_month_number AS activity_month
FROM active_customers;

SELECT * FROM distinct_users;

CREATE OR REPLACE VIEW retained_customers AS
SELECT d1.activity_year, d1.activity_month,
COUNT(DISTINCT d1.active_id) AS retained_customers
FROM distinct_users d1
JOIN distinct_users d2
ON d1.active_id = d2.active_id
AND d2.activity_month = d1.activity_month+1
GROUP BY d1.activity_year, d1.activity_month;

SELECT * FROM retained_customers;