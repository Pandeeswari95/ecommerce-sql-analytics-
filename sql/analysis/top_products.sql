----Top selling products------------

SELECT 
	product_id,
	total_sales,
	products_rank 
	FROM
	(
	SELECT 
		product_id,
		SUM(price) AS total_sales,
		DENSE_RANK() OVER(ORDER BY SUM(price) DESC) AS products_rank
	FROM order_items
	GROUP BY product_id
	)t
WHERE products_rank <=10