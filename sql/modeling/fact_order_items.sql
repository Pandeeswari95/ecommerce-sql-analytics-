/*===================================================
          populate values in fact order items table
  ===================================================*/
INSERT INTO star.fact_order_items
SELECT 
	oi.order_id,
	oi.order_item_id,
	c.customer_unique_id,
	oi.product_id,
	oi.seller_id,
	CAST(o.order_purchase_timestamp AS DATE),
	o.order_status,
	CAST(o.order_approved_at AS DATE),
	CAST(o.order_delivered_customer_date AS DATE),
	price,
	freight_value 
FROM order_items oi
JOIN orders o
ON oi.order_id = o.order_id
JOIN customers c
ON o.customer_id = c.customer_id
