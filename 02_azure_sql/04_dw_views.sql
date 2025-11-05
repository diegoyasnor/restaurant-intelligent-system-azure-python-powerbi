USE restaurant_dw;
GO

-- Vistas base
CREATE OR ALTER VIEW dw.dim_product AS
SELECT product_id, sku, product_name, category, unit, avg_unit_cost_usd
FROM stg.dim_product;
GO

CREATE OR ALTER VIEW dw.dim_store AS
SELECT store_id, store_name, city, state, open_date
FROM stg.dim_store;
GO

CREATE OR ALTER VIEW dw.fact_sales AS
SELECT sale_line_id, store_id, product_id, qty_sold, unit_price_usd, line_revenue_usd, order_date
FROM stg.fact_sales;
GO

-- Vista estrella recomendada
CREATE OR ALTER VIEW dw.v_fact_sales_star AS
SELECT
  fs.sale_line_id,
  fs.order_date,
  fs.store_id, s.store_name, s.city, s.state,
  fs.product_id, p.product_name, p.category, p.unit, p.avg_unit_cost_usd,
  fs.qty_sold, fs.unit_price_usd, fs.line_revenue_usd
FROM stg.fact_sales fs
LEFT JOIN stg.dim_store   s ON s.store_id   = fs.store_id
LEFT JOIN stg.dim_product p ON p.product_id = fs.product_id;
GO

-- Índices (crea solo si no existen)
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_sales_store_date' AND object_id = OBJECT_ID('stg.fact_sales'))
    CREATE INDEX IX_sales_store_date   ON stg.fact_sales(store_id, order_date);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_sales_product_date' AND object_id = OBJECT_ID('stg.fact_sales'))
    CREATE INDEX IX_sales_product_date ON stg.fact_sales(product_id, order_date);
GO
