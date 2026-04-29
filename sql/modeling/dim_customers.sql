/*================================================================
      Populating values in customer dimension table
  ================================================================*/

---CTE to group the customers to avoid duplication---------

WITH ranked AS (
    SELECT 
        customer_unique_id,
        customer_city,
        customer_state,
        ROW_NUMBER() OVER (
            PARTITION BY customer_unique_id 
            ORDER BY customer_zip_code_prefix DESC
        ) AS rn
    FROM customers
)

------Dimentional table creation-----------

INSERT INTO star.dim_customers(customer_unique_id, customer_city, customer_state)
SELECT 
    customer_unique_id,
    customer_city,
    customer_state
FROM ranked
WHERE rn = 1