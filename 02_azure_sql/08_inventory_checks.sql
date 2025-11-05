USE restaurant_dw;
GO

-- 1) Conteo por estado
SELECT stock_status, COUNT(*) AS rows
FROM dw.v_inventory_status
GROUP BY stock_status;

-- 2) UNDER_STOCK detallado
SELECT *
FROM dw.v_inventory_status
WHERE stock_status = 'UNDER_STOCK'
ORDER BY store_name, product_name;

-- 3) BELOW_REORDER_POINT detallado
SELECT *
FROM dw.v_inventory_status
WHERE stock_status = 'BELOW_REORDER_POINT'
ORDER BY store_name, product_name;

-- 4) Vista de email (lo que saldría en la alerta)
SELECT TOP 100 *
FROM dw.v_under_stock_email
ORDER BY store_name, product_name;
