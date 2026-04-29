/*========================================================
           populating values in products dimension table
  =========================================================*/

INSERT INTO star.dim_products(product_id,product_category)
SELECT 
	product_id,
	product_category_name
FROM products