USE restaurant_dw;
GO

-- 1) Conteos
SELECT 'dim_product' AS table_name, COUNT(*) AS total_rows FROM stg.dim_product
UNION ALL SELECT 'dim_store', COUNT(*) FROM stg.dim_store
UNION ALL SELECT 'fact_sales', COUNT(*) FROM stg.fact_sales;
GO

-- 2) Nulos (revisa resultados; actúa si ves filas)
SELECT * FROM stg.dim_product WHERE product_id IS NULL OR product_name IS NULL OR sku IS NULL;
SELECT * FROM stg.dim_store   WHERE store_id  IS NULL OR store_name  IS NULL OR city IS NULL;
SELECT * FROM stg.fact_sales  WHERE sale_line_id IS NULL OR product_id IS NULL OR store_id IS NULL
                             OR qty_sold IS NULL OR unit_price_usd IS NULL;
GO

-- 3) Duplicados (elimina dejando 1 por clave)
;WITH cte AS (
  SELECT *, ROW_NUMBER() OVER (PARTITION BY product_id ORDER BY product_name) AS rn
  FROM stg.dim_product
) DELETE FROM cte WHERE rn > 1;
GO

;WITH cte AS (
  SELECT *, ROW_NUMBER() OVER (PARTITION BY store_id ORDER BY store_name) AS rn
  FROM stg.dim_store
) DELETE FROM cte WHERE rn > 1;
GO

-- 4) Valores fuera de rango (revisa primero)
SELECT * FROM stg.fact_sales WHERE qty_sold <= 0 OR unit_price_usd <= 0;
SELECT * FROM stg.fact_sales WHERE order_date < '2000-01-01' OR order_date > GETDATE();
GO

-- 5) Normalización de texto
UPDATE stg.dim_product
SET product_name = LTRIM(RTRIM(product_name)),
    category     = UPPER(LTRIM(RTRIM(category)));

UPDATE stg.dim_store
SET city  = UPPER(LTRIM(RTRIM(city))),
    state = UPPER(LTRIM(RTRIM(state)));
GO

-- 6) Resumen de calidad
SELECT
  'dim_product' AS table_name,
  COUNT(*) AS total_rows,
  SUM(CASE WHEN product_id IS NULL OR product_name IS NULL THEN 1 ELSE 0 END) AS nulls,
  COUNT(DISTINCT product_id) AS unique_products
FROM stg.dim_product
UNION ALL
SELECT
  'fact_sales',
  COUNT(*),
  SUM(CASE WHEN qty_sold <= 0 OR unit_price_usd <= 0 THEN 1 ELSE 0 END),
  COUNT(DISTINCT sale_line_id)
FROM stg.fact_sales;
GO
