USE restaurant_dw;
GO

/* Vista de estado de inventario para modelo y PBI */
CREATE OR ALTER VIEW dw.v_inventory_status AS
SELECT
    i.store_id,
    ds.store_name,
    ds.city,
    ds.state,
    i.product_id,
    dp.product_name,
    dp.category,
    dp.unit,
    dp.avg_unit_cost_usd,
    i.current_stock,
    r.min_stock,
    r.reorder_point,
    r.preferred_vendor,
    r.last_reviewed,
    i.last_update,
    CASE
        WHEN i.current_stock < r.min_stock THEN 'UNDER_STOCK'
        WHEN i.current_stock < r.reorder_point THEN 'BELOW_REORDER_POINT'
        ELSE 'OK'
    END AS stock_status
FROM stg.fact_inventory_current AS i
JOIN stg.inventory_rules    AS r  ON r.store_id = i.store_id  AND r.product_id = i.product_id
JOIN stg.dim_store          AS ds ON ds.store_id = i.store_id
JOIN stg.dim_product        AS dp ON dp.product_id = i.product_id;
GO

/* Vista para correo: solo UNDER_STOCK */
CREATE OR ALTER VIEW dw.v_under_stock_email AS
SELECT
    ds.store_name,
    ds.city,
    ds.state,
    dp.product_name,
    dp.category,
    dp.unit,
    i.current_stock,
    r.min_stock,
    r.reorder_point,
    r.preferred_vendor,
    FORMAT(i.last_update, 'yyyy-MM-dd HH:mm') AS last_update
FROM stg.fact_inventory_current AS i
JOIN stg.inventory_rules    AS r  ON r.store_id = i.store_id  AND r.product_id = i.product_id
JOIN stg.dim_store          AS ds ON ds.store_id = i.store_id
JOIN stg.dim_product        AS dp ON dp.product_id = i.product_id
WHERE i.current_stock < r.min_stock;
GO
