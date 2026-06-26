SELECT * from olist_customers_dataset
SELECT * from olist_geolocation_dataset
SELECT * from olist_order_items_dataset
SELECT * from olist_order_reviews_dataset
SELECT * from olist_products_dataset
SELECT * from olist_order_payments_dataset
SELECT * from olist_sellers_dataset
SELECT * from product_category_name_translation
SELECT * from ecommerce_brazil
SELECT SUM (payment_value) AS total_revenue
FROM olist_order_payments_dataset
SELECT SUM(op.payment_value) / COUNT (DISTINCT o.order_id) AS avg_order_value
FROM ecommerce_brazil  o
JOIN olist_order_payments_dataset op
ON o.order_id = op.order_id
WHERE o.order_status = 'delivered';
SELECT pct.column2,
SUM(oi.price) AS revenue
FROM olist_order_items_dataset AS oi
JOIN olist_products_dataset AS p
ON oi.product_id = p.product_id
JOIN product_category_name_translation AS pct
ON p.product_category_name = pct.column1
GROUP BY pct.column2
ORDER BY revenue DESC;
SELECT pct.column2 AS category,
SUM(oi.price) AS revenue
FROM olist_order_items_dataset AS oi
JOIN olist_products_dataset AS p
 ON oi.product_id = p.product_id
JOIN product_category_name_translation AS pct
ON p.product_category_name = pct.column1
GROUP BY pct.column2
ORDER BY revenue DESC;
-- Monthly Revnue Trend
SELECT YEAR (o.order_purchase_timestamp) AS year,
MONTH (o.order_purchase_timestamp) AS month,
SUM (oi.price) AS revenue
FROM olist_order_items_dataset oi
JOIN ecommerce_brazil o ON oi.order_id = o.order_id
GROUP BY YEAR (o.order_purchase_timestamp), Month (o.order_purchase_timestamp)
ORDER BY year, Month
-- Product Category Revenue
SELECT p.product_category_name,
SUM (oi.price) AS revenue,
COUNT (DISTINCT oi.order_id) AS order_count
FROM olist_order_items_dataset oi
JOIN olist_products_dataset p ON oi.product_id = p.product_id
GROUP BY p.product_category_name
ORDER BY revenue DESC
-- Customer Insights
SELECT Count (DISTINCT customer_id) AS total_unique_customers
FROM ecommerce_brazil
-- Fulfillment Rate
SELECT ROUND (100.0 * SUM(CASE WHEN order_status = 'delivered' THEN 1 ELSE 0 END) / COUNT(*), 2) AS fulfillment_rate_pct
FROM ecommerce_brazil
-- Average Review Rating
SELECT ROUND(AVG(CAST(review_score AS FLOAT)), 2) AS avg_rating,
  COUNT(*) AS total_reviews
FROM olist_order_reviews_dataset
-- Rating by Category
SELECT p.product_category_name,
ROUND (AVG (CAST (r.review_score AS FLOAT)),2) AS avg_rating,
COUNT (*) AS review_count
FROM olist_order_reviews_dataset r
JOIN olist_order_items_dataset oi ON r.order_id = oi.order_id
JOIN olist_products_dataset p ON oi.product_id = p.product_id
GROUP BY p.product_category_name
ORDER BY avg_rating DESC
-- Top Sellers
SELECT TOP 10 
s.seller_id,
s.seller_city,
s.seller_state,
COUNT (DISTINCT oi.order_id) AS order_count,
SUM(oi.price) AS total_revenue
FROM olist_sellers_dataset s
JOIN olist_order_items_dataset oi ON s.seller_id = oi.seller_id
GROUP BY s.seller_id, s.seller_city, s.seller_state
ORDER BY total_revenue DESC
-- Top 10 products
SELECT TOP 10
  p.product_id,
  p.product_category_name,
  SUM(oi.price) AS revenue,
  COUNT(DISTINCT oi.order_id) AS order_count
FROM olist_order_items_dataset oi
JOIN olist_products_dataset p ON oi.product_id = p.product_id
GROUP BY p.product_id, p.product_category_name
ORDER BY revenue DESC
-- Sales by State
SELECT 
  c.customer_state,
  COUNT(DISTINCT o.order_id) AS order_count,
  SUM(oi.price) AS revenue
FROM ecommerce_brazil o
JOIN olist_customers_dataset c ON o.customer_id = c.customer_id
JOIN olist_order_items_dataset oi ON o.order_id = oi.order_id
GROUP BY c.customer_state
ORDER BY revenue DESC
-- Order Status Distribuition
SELECT 
  order_status,
  COUNT(*) AS order_count,
  ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER(), 2) AS percentage
FROM ecommerce_brazil
GROUP BY order_status
ORDER BY order_count DESC
-- Repeat Customers %
WITH customer_orders AS (
  SELECT customer_id, COUNT(*) AS order_count
  FROM ecommerce_brazil
  GROUP BY customer_id
)
SELECT 
  COUNT(*) AS total_customers,
  SUM(CASE WHEN order_count > 1 THEN 1 ELSE 0 END) AS repeat_customers,
  ROUND(100.0 * SUM(CASE WHEN order_count > 1 THEN 1 ELSE 0 END) / COUNT(*), 2) AS repeat_customer_rate_pct

FROM customer_orders
-- Review Rating Distribution
SELECT 
  review_score,
  COUNT(*) AS review_count,
  ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER(), 2) AS percentage
FROM olist_order_reviews_dataset
GROUP BY review_score
ORDER BY review_score DESC
-- Top 5 Product Categories by Quantity Sold
SELECT TOP 5
    pct.column2 AS product_category,
    COUNT(*) AS total_quantity_sold
FROM olist_order_items_dataset oi
JOIN olist_products_dataset p 
    ON oi.product_id = p.product_id
JOIN product_category_name_translation pct
    ON p.product_category_name = pct.column1
GROUP BY pct.column2
ORDER BY total_quantity_sold DESC;
-- Bottom 5 Product Categories by Revenue
SELECT TOP 5
    pct.column2 AS product_category,
    SUM(oi.price) AS revenue
FROM olist_order_items_dataset oi
JOIN olist_products_dataset p 
    ON oi.product_id = p.product_id
JOIN product_category_name_translation pct
    ON p.product_category_name = pct.column1
GROUP BY pct.column2
ORDER BY revenue ASC;
-- Top 5 Product Categories by Product Orders
SELECT TOP 5
    pct.column2 AS product_category,
    COUNT(DISTINCT oi.order_id) AS product_orders
FROM olist_order_items_dataset oi
JOIN olist_products_dataset p 
    ON oi.product_id = p.product_id
JOIN product_category_name_translation pct
    ON p.product_category_name = pct.column1
GROUP BY pct.column2
ORDER BY product_orders DESC;