USE restaurant_dw;
GO

IF OBJECT_ID('stg.dim_product','U') IS NULL
BEGIN
    CREATE TABLE stg.dim_product (
        product_id INT PRIMARY KEY,
        sku NVARCHAR(50),
        product_name NVARCHAR(255),
        category NVARCHAR(100),
        unit NVARCHAR(20),
        avg_unit_cost_usd DECIMAL(18,4)
    );
END
GO

IF OBJECT_ID('stg.dim_store','U') IS NULL
BEGIN
    CREATE TABLE stg.dim_store (
        store_id INT PRIMARY KEY,
        store_name NVARCHAR(100),
        city NVARCHAR(100),
        state NVARCHAR(50),
        open_date DATE
    );
END
GO

IF OBJECT_ID('stg.fact_sales','U') IS NULL
BEGIN
    CREATE TABLE stg.fact_sales (
        sale_line_id INT PRIMARY KEY,
        store_id INT,
        product_id INT,
        qty_sold DECIMAL(18,4),
        unit_price_usd DECIMAL(18,4),
        line_revenue_usd DECIMAL(18,4),
        order_date DATE
    );
END
GO

IF OBJECT_ID('stg.fact_inventory_current','U') IS NULL
BEGIN

    CREATE TABLE stg.fact_inventory_current (
        store_id        INT        NOT NULL,
        product_id      INT        NOT NULL,
        on_hand_qty     DECIMAL(18,4) NOT NULL,
        last_counted_at DATETIME2  NULL,
        PRIMARY KEY (store_id, product_id)
    );
END
GO

IF OBJECT_ID('stg.inventory_rules','U') IS NULL

BEGIN

    CREATE TABLE stg.inventory_rules (
        store_id       INT        NOT NULL,
        product_id     INT        NOT NULL,
        min_stock_qty  DECIMAL(18,4) NOT NULL,
        reorder_point  DECIMAL(18,4) NOT NULL,
        lead_time_days INT NULL,
        PRIMARY KEY (store_id, product_id)
    );
END
GO

USE restaurant_dw;
GO

-- Si existen, elimínalas
IF OBJECT_ID('stg.fact_inventory_current', 'U') IS NOT NULL
    DROP TABLE stg.fact_inventory_current;
GO

IF OBJECT_ID('stg.inventory_rules', 'U') IS NOT NULL
    DROP TABLE stg.inventory_rules;
GO


USE restaurant_dw;
GO

-- Tabla de inventario actual
CREATE TABLE stg.fact_inventory_current (
    store_id       INT          NOT NULL,
    product_id     INT          NOT NULL,
    current_stock  DECIMAL(18,4) NOT NULL,
    last_update    DATETIME2    NULL,
    PRIMARY KEY (store_id, product_id)
);
GO

-- Tabla de reglas de inventario
CREATE TABLE stg.inventory_rules (
    store_id       INT          NOT NULL,
    product_id     INT          NOT NULL,
    min_stock      DECIMAL(18,4) NOT NULL,
    reorder_point  DECIMAL(18,4) NOT NULL,
    preferred_vendor    NVARCHAR(100) NULL,      
    last_reviewed  DATETIME2    NULL,
    PRIMARY KEY (store_id, product_id)
);
GO

IF OBJECT_ID('stg.stg,inventory_rules_load', 'U') IS NULL
    DROP TABLE stg.stg,inventory_rules_load;
GO

USE restaurant_dw;
GO

SELECT TABLE_SCHEMA, TABLE_NAME
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_SCHEMA = 'stg';

EXEC sp_rename '[stg].[stg,inventory_rules_load]', 'inventory_rules_load';
GO

select *
from stg.inventory_rules

EXEC sp_columns 'stg.inventory_rules_load';
EXEC sp_columns 'stg.inventory_rules';

USE restaurant_dw;
GO

-- Inserta los datos de la tabla temporal en la tabla definitiva
INSERT INTO stg.inventory_rules (
    store_id,
    product_id,
    min_stock,
    reorder_point,
    preferred_vendor,
    last_reviewed
)
SELECT
    store_id,
    product_id,
    min_stock,
    reorder_point,
    preferred_vendor,
    last_reviewed
FROM stg.inventory_rules_load;
GO

SELECT COUNT(*) AS total_rows FROM stg.inventory_rules;
GO

SELECT TOP 10 * FROM stg.inventory_rules;
GO

DROP TABLE stg.inventory_rules_load;
GO

SELECT *
from inventory_rules

USE restaurant_dw;
GO

SELECT t.name AS table_name, SUM(p.rows) AS row_count
FROM sys.tables t
JOIN sys.partitions p ON t.object_id = p.object_id
WHERE t.name LIKE '%inventory_rules%'
GROUP BY t.name
ORDER BY row_count DESC;

SELECT name 
FROM sys.tables 
WHERE name = 'stg.inventory_rules';
GO

DROP TABLE [stg].[stg.inventory_rules];
GO

select *
from stg.fact_inventory_current_load

INSERT INTO stg.fact_inventory_current (
    store_id,
    product_id,
    current_stock,
    last_update
    
    
    
)
SELECT
    store_id,
    product_id,
    current_stock,
    last_update
FROM stg.fact_inventory_current_load;
GO

USE restaurant_dw;
GO

-- 1) Reemplazar todo el contenido
TRUNCATE TABLE stg.fact_inventory_current;
GO

-- 2) Insertar desde la tabla load (deduplicando por si acaso)
;WITH src AS (
  SELECT
    store_id, product_id, current_stock, last_update,
    ROW_NUMBER() OVER (
      PARTITION BY store_id, product_id
      ORDER BY last_update DESC, current_stock DESC
    ) AS rn
  FROM stg.fact_inventory_current_load
)
INSERT INTO stg.fact_inventory_current (store_id, product_id, current_stock, last_update)
SELECT store_id, product_id, current_stock, last_update
FROM src
WHERE rn = 1;
GO

-- 2️⃣ Elimina las tablas de carga que ya no necesitas
IF OBJECT_ID('stg.fact_inventory_current_load', 'U') IS NOT NULL
    DROP TABLE stg.fact_inventory_current_load;
GO

IF OBJECT_ID('stg.fact_sales_load', 'U') IS NOT NULL
    DROP TABLE stg.fact_sales_load;

IF OBJECT_ID('stg.dim_store_load', 'U') IS NOT NULL
    DROP TABLE stg.dim_store_load;