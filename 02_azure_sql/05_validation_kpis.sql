USE restaurant_dw;
GO

-- Revenue total
SELECT SUM(line_revenue_usd) AS total_revenue FROM dw.v_fact_sales_star;

-- Revenue por tienda
SELECT s.store_name, SUM(fs.line_revenue_usd) AS revenue
FROM dw.v_fact_sales_star fs
JOIN dw.dim_store s ON s.store_id = fs.store_id
GROUP BY s.store_name
ORDER BY revenue DESC;

-- Revenue por categoría
SELECT p.category, SUM(fs.line_revenue_usd) AS revenue
FROM dw.v_fact_sales_star fs
JOIN dw.dim_product p ON p.product_id = fs.product_id
GROUP BY p.category
ORDER BY revenue DESC;

-- Ventas mensuales
SELECT FORMAT(order_date,'yyyy-MM') AS yyyymm, SUM(line_revenue_usd) AS revenue
FROM dw.fact_sales
GROUP BY FORMAT(order_date,'yyyy-MM')
ORDER BY yyyymm;
GO
