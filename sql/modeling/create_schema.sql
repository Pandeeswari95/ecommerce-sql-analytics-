/*=======================================================
      Create star Schema for data model
=======================================================*/
CREATE SCHEMA star;
GO

/*=======================================================
      Dimension: Customers
=======================================================*/

CREATE TABLE star.dim_customers(
	customer_unique_id VARCHAR(50) PRIMARY KEY,
	customer_city VARCHAR(50),
	customer_state CHAR(2)
	);
GO

/*=======================================================
      Dimension: Products
=======================================================*/

CREATE TABLE star.dim_products(
	product_id	VARCHAR(50) PRIMARY KEY,
	product_category VARCHAR(50)
	);
GO

/*=======================================================
      Dimension: Sellers
=======================================================*/

CREATE TABLE star.dim_sellers(
	seller_id VARCHAR(50) PRIMARY KEY,
	seller_city VARCHAR(50),
	seller_state CHAR(2)
	);
GO

/*=======================================================
      Fact: order_items
=======================================================*/

CREATE TABLE star.fact_order_items(
	order_id VARCHAR(50),
	order_item_id INT,
	customer_unique_id VARCHAR(50),
	product_id VARCHAR(50),
	seller_id VARCHAR(50),
	purchase_date DATE,
	order_status CHAR(20),
	approved_date DATE,
	delivered_date DATE,
	price DECIMAL(10,2),
	freight_value DECIMAL(10,2)

	PRIMARY KEY(order_id,order_item_id),

	----foreign key ---------

	CONSTRAINT fk_fact_customers FOREIGN KEY(customer_unique_id) 
		REFERENCES star.dim_customers(customer_unique_id),

	CONSTRAINT fk_fact_products FOREIGN KEY(product_id) 
		REFERENCES star.dim_products(product_id),
	
	CONSTRAINT fk_fact_sellers FOREIGN KEY(seller_id) 
		REFERENCES star.dim_sellers(seller_id)
)