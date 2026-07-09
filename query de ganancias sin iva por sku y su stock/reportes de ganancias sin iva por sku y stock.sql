SELECT 
    p.rowid,
    p.ref AS sku,
    p.label AS producto,
    pe.catproveedor AS proveedor,
    pe.marcaproducto AS marca,
    p.price AS precio_sin_iva,
    p.pmp AS pmp_sin_iva,
    p.price - p.pmp AS ganancia_moneda_nacional,
    IF(p.price > 0, ((p.price - p.pmp) / p.price) * 100, 0) AS margen_porcentaje,
    SUM(s.reel) AS stock_total
FROM llx_product AS p

INNER JOIN llx_product_extrafields AS pe
    ON p.rowid = pe.fk_object

INNER JOIN llx_product_stock AS s
    ON p.rowid = s.fk_product

WHERE s.reel > 0 

GROUP BY
    p.rowid,
    p.ref,
    p.label,
    pe.catproveedor,
    pe.marcaproducto,
    p.price,
    p.pmp
    
HAVING SUM(s.reel) > 0
ORDER BY ganancia_moneda_nacional ASC;