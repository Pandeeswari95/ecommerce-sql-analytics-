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

WITH minmax_month AS (
-------calculate min and max order date to create calandar-------
	SELECT 
		DATEFROMPARTS(YEAR(MIN(purchase_date)),
			MONTH(MIN(purchase_date)),1) AS first_month,
		DATEFROMPARTS(YEAR(MAX(purchase_date)),
			MONTH(MAX(purchase_date)),1) AS last_month
	FROM star.fact_order_items
	WHERE order_status = 'delivered'
),
month_calendar AS (
  -------generating calendar ---------
	SELECT first_month AS month_start
	FROM minmax_month
	UNION ALL
	SELECT DATEADD(MONTH,1,month_start)
	FROM month_calendar,minmax_month
	WHERE month_start < last_month
),
order_over_month AS (
-------total orders and sales for each month----------------------
	SELECT
		DATETRUNC(MONTH,purchase_date) AS order_month,
		COUNT(DISTINCT order_id) AS total_orders,
		SUM(price + freight_value) AS total_sales
	FROM star.fact_order_items 
	WHERE order_status = 'delivered'
	GROUP BY DATETRUNC(MONTH,purchase_date)
),
merged AS (
  --------merging calendar with orders---------
    SELECT 
		YEAR(mc.month_start) AS order_year,
        mc.month_start AS order_month,
        o.total_orders,
        o.total_sales
    FROM month_calendar mc
    LEFT JOIN order_over_month o
        ON mc.month_start = o.order_month
),
sales_mom_metric AS (
---------calculate yearly cumulative sales and previous month values -----------
	SELECT 
		order_year,
		order_month,
		total_orders,
		total_sales,
		SUM(COALESCE(total_sales,0)) OVER(PARTITION BY order_year 
			ORDER BY order_month) AS yearly_cumulative_sales,
		LAG(total_orders) OVER(PARTITION BY order_year 
			ORDER BY order_month) AS previous_month_order,
		LAG(total_sales) OVER(PARTITION BY order_year 
			ORDER BY order_month) AS previous_month_sales
	FROM merged
)
------final table with mom growth rates---------------
SELECT 
	order_year,
	order_month,
	total_orders,
	-------MoM order growth-----------
	CASE 
		WHEN previous_month_order IS NULL THEN NULL
		WHEN previous_month_order < 50 THEN NULL
		ELSE ROUND(CAST((total_orders - previous_month_order) 
		     AS FLOAT)/ NULLIF(previous_month_order,0),2) 
    END AS mom_order_rate,
	total_sales,
	yearly_cumulative_sales,
	------------MoM sales growth---------------
	CASE 
		WHEN previous_month_sales IS NULL THEN NULL
		WHEN previous_month_sales < 5000 THEN NULL
	    ELSE ROUND(CAST((total_sales - previous_month_sales)
			 AS FLOAT) / NULLIF(previous_month_sales,0),2)
	END AS mom_sales_rate
FROM sales_mom_metric
