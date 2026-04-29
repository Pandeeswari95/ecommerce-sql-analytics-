/*================================================================
      Populating values in customer dimension table
  ================================================================*/

INSERT INTO star.dim_sellers(seller_id,seller_city,seller_state)
SELECT 
	seller_id,
	seller_city,
	seller_state
FROM olist_sellers_dataset