USE masai_assignment_1_pt2;

-- Q1: Total sales revenue by product category for each month
SELECT 
    d.year,
    d.month,
    p.category,
    SUM(f.total_sales_amount) AS total_revenue
FROM fact_sales f
JOIN dim_date d ON f.date_id = d.date_id
JOIN dim_product p ON f.product_id = p.product_id
GROUP BY 
    d.year,
    d.month,
    p.category
ORDER BY 
    d.year, 
    d.month, 
    total_revenue DESC;

-- Q2: Top 2 performing stores by total revenue
SELECT 
    s.store_name,
    s.store_city,
    SUM(f.total_sales_amount) AS total_revenue
FROM fact_sales f
JOIN dim_store s ON f.store_id = s.store_id
GROUP BY 
    s.store_id,
    s.store_name,
    s.store_city
ORDER BY 
    total_revenue DESC
LIMIT 2;

-- Q3: Month-over-month sales trend across all stores
WITH MonthlySales AS (
    SELECT 
        d.year,
        d.month,
        SUM(f.total_sales_amount) AS current_month_revenue
    FROM fact_sales f
    JOIN dim_date d ON f.date_id = d.date_id
    GROUP BY 
        d.year,
        d.month
)
SELECT 
    year,
    month,
    current_month_revenue,
    LAG(current_month_revenue) OVER (ORDER BY year, month) AS previous_month_revenue,
    current_month_revenue - LAG(current_month_revenue) OVER (ORDER BY year, month) AS mom_revenue_difference
FROM MonthlySales
ORDER BY 
    year, 
    month;