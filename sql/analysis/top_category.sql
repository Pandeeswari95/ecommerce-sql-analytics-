-------Top selling product category -----------------

SELECT 
	   product_category_name,
	   total_sales,
	   category_rank
FROM
	(
	SELECT
		p.product_category_name,
		SUM(oi.price) AS total_sales,
		DENSE_RANK() OVER(ORDER BY SUM(oi.price) DESC) AS category_rank
	FROM order_items oi
	JOIN products p
	ON oi.product_id = p.product_id
	GROUP BY p.product_category_name
	)t
WHERE category_rank <=10
