/*=================================================================
		Retention Heatmap - customer cohorts
===================================================================
Goal :
	- Calculate retention rate per cohort month
	- Track how many customers returns after their first purchase
	- prepare data for Heat map visualization
====================================================================*/

-----Create view for retention heat map ---------------------------
CREATE VIEW retention_heatmap_view AS

WITH cohort_month_metric AS (
---step 1: Identify cohort month for each customer-----------------------
	SELECT 
		c.customer_unique_id,
		DATETRUNC(MONTH,MIN(o.order_purchase_timestamp)) AS cohort_month
	FROM customers c
	JOIN orders o
	ON c.customer_id=o.customer_id
	WHERE o.order_status = 'delivered'
	GROUP BY c.customer_unique_id 
),
order_interval AS (
----step 2: count number of customers active each month since first purchase----------------
	SELECT
		cmm.cohort_month,
		COUNT(DISTINCT cmm.customer_unique_id) AS active_customers,
		DATEDIFF(MONTH,cmm.cohort_month,DATETRUNC(MONTH,o.order_purchase_timestamp)) AS month_number
	FROM customers c
	JOIN orders o
	ON c.customer_id = o.customer_id
	JOIN cohort_month_metric cmm
	ON c.customer_unique_id = cmm.customer_unique_id
	WHERE o.order_status = 'delivered'
	GROUP BY cmm.cohort_month,
		DATEDIFF(MONTH,cmm.cohort_month,DATETRUNC(MONTH,o.order_purchase_timestamp))
),
retention_calculation AS (
-------step 3: calculate retention rate as a percentage of the cohort-----------
	SELECT 
		cohort_month,
		month_number,
		active_customers,
		ROUND(CAST(active_customers AS FLOAT) * 100 /
			FIRST_VALUE(active_customers) OVER(PARTITION BY cohort_month 
			ORDER BY month_number),2) AS retention_rate
	FROM order_interval
)	
-------step 4: retention table in long format(ready for heat map---------------
SELECT 
	FORMAT(cohort_month,'yyyy-MM') AS cohort_month,
	month_number ,
	retention_rate
FROM retention_calculation
	
