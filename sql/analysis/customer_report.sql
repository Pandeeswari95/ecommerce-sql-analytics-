/*============================================================================
			Customer performance based on RFM 
==============================================================================
Goal:
	Total orders per customer
	Total revenue per customer
	first order date and last order date
	Customer lifetime
	average order value per customer
	average days between order
	customer segmentation based on frequency of orders(loyal customers,repeat customers,new customers)
	customer segmentation based on AOV(High value,Medium value,Low value)
-------------KPI----------------------------------------------------------------
AOV
Customer Frequency
Recency
================================================================================*/
-----Create view for customer performance based on RFM---------------------
CREATE VIEW customer_performance_view AS

WITH customer_base_data AS (
----Step 1:Get all the data needed for customer performance analysis------------------
	SELECT 
		c.customer_unique_id,
		COUNT(DISTINCT o.order_id) AS total_orders,
		MIN(o.order_purchase_timestamp) AS first_order_date,
		MAX(o.order_purchase_timestamp) AS last_order_date,
		SUM(oi.price) AS total_spent
	FROM customers c
	join orders o
	on c.customer_id=o.customer_id
	join order_items oi
	on o.order_id = oi.order_id
	WHERE o.order_status = 'delivered'
	GROUP BY c.customer_unique_id
	),
	order_interval AS (
	------------Average days between orders calculation---------------------------
		SELECT 
			customer_unique_id,
			AVG(DATEDIFF(DAY,order_purchase_timestamp,next_order_date)) AS avg_days_btw_orders
		FROM
			 --------Sub Query and window function to find days between orders----------
			(
			SELECT
				c.customer_unique_id,
				o.order_purchase_timestamp,
				LEAD(order_purchase_timestamp) OVER(PARTITION BY c.customer_unique_id ORDER BY order_purchase_timestamp) next_order_date
			FROM customers c
			join orders o
			on c.customer_id=o.customer_id
			WHERE o.order_status = 'delivered'
			)t
	WHERE next_order_date IS NOT NULL
	GROUP BY customer_unique_id
	),
	customer_order_metric AS (
	 ----------calculate customer life time ,recency,AOV ---------
		SELECT 
			cbd.customer_unique_id,
			CAST(cbd.first_order_date AS DATE) AS first_order_date,
			CAST(cbd.last_order_date AS DATE) AS last_order_date,
		    ------------Customer life time---------------
			DATEDIFF(DAY,cbd.first_order_date,cbd.last_order_date) AS customer_life_time,
			oin.avg_days_btw_orders,
			cbd.total_orders,
			cbd.total_spent,
		  -----Average order value ----------------------
			CAST(cbd.total_spent AS FLOAT)/cbd.total_orders AS average_order_value,
		  --------recency-----------------------------------------------
			DATEDIFF(DAY,cbd.last_order_date,(SELECT MAX(order_purchase_timestamp)
				FROM orders WHERE order_status = 'delivered')) AS recency_days
		FROM customer_base_data cbd
		LEFT JOIN order_interval oin
		ON cbd.customer_unique_id=oin.customer_unique_id
	)
----------final customer report-------------------------	
SELECT 
	customer_unique_id,
	first_order_date,
	last_order_date,
	customer_life_time,
	avg_days_btw_orders,
	recency_days,
	total_orders,
	total_spent,
	average_order_value,
	------Customer segmentation based on AOV--------
	CASE 
		WHEN average_order_value > 100 THEN 'high value'
		WHEN average_order_value BETWEEN 50 AND 100 THEN 'medium value'
		ELSE 'low value'
	END AS aov_customer_segment,
	-------Customer segmentation based on orders-----------
	CASE 
		WHEN total_orders > 5 THEN 'Loyal customer'
		WHEN total_orders BETWEEN 2 AND 5 THEN 'repeat customer'
		ELSE 'New customer'
	END AS frequency_segment
FROM customer_order_metric




