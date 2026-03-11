/*=======================================================================
       sales monthly performance report
==========================================================================
  Metrics Included:
			- Monthly orders
			- Monthly sales
			- Yearly cumulative sales
			- MOM order growth
		    - MOM sales growth
============================================================================*/
------create view for sales monthly performance----------------------------
CREATE VIEW sales_monthly_performance_view AS

WITH order_over_month AS (
-------total orders and sales for each month----------------------
	SELECT
		YEAR(o.order_purchase_timestamp) AS order_year,
		DATETRUNC(MONTH,o.order_purchase_timestamp) AS order_month,
		COUNT(DISTINCT o.order_id) AS total_orders,
		SUM(oi.price) AS total_sales
	FROM orders o
	JOIN order_items oi
	ON o.order_id=oi.order_id
	WHERE o.order_status = 'delivered'
	GROUP BY YEAR(o.order_purchase_timestamp),
			 DATETRUNC(MONTH,o.order_purchase_timestamp)

),
sales_mom_metric AS (
---------calculate yearly cumulative sales and previous month values -----------
	SELECT 
		order_year,
		order_month,
		total_orders,
		total_sales,
		SUM(total_sales) OVER(PARTITION BY order_year ORDER BY order_month) AS yearly_cumulative_sales,
		LAG(total_orders) OVER(PARTITION BY order_year ORDER BY order_month) AS previous_month_order,
		LAG(total_sales) OVER(PARTITION BY order_year ORDER BY order_month) AS previous_month_sales
	FROM order_over_month
)
------final table with mom growth rates---------------
SELECT 
	order_year,
	order_month,
	total_orders,
	ROUND(CAST((total_orders - previous_month_order) AS FLOAT) * 100 /
		NULLIF(previous_month_order,0) ,2) AS mom_order_rate,
	total_sales,
	yearly_cumulative_sales,
	ROUND(CAST((total_sales - previous_month_sales) AS FLOAT) * 100 /
		NULLIF(previous_month_sales,0) ,2) AS mom_sales_rate
FROM sales_mom_metric

