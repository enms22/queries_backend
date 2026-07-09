SELECT 
    SUM((td.subprice - p.pmp) * td.qty) AS ganancia_total,
    SUM(td.subprice * td.qty) AS venta_total_sin_iva,
    (SUM((td.subprice - p.pmp) * td.qty) / SUM(td.subprice * td.qty)) * 100 AS margen_porcentaje_global
FROM llx_product AS p
INNER JOIN llx_pos_ticketdet AS td ON p.rowid = td.fk_product
INNER JOIN llx_pos_ticket AS pt ON td.fk_ticket = pt.rowid
-- Filtro de stock sin duplicados
WHERE DATE(pt.date_creation) = '2025-12-23'
AND pt.ticketnumber LIKE 'VPV%'
-- AQUÍ ES DONDE FILTRAS PARA LLEGAR A LOS 704k
-- Ejemplo: AND caja.name = 'CAJA - AMA' o el filtro que identifique este grupo
AND EXISTS (
    SELECT 1 FROM llx_product_stock AS s 
    WHERE s.fk_product = p.rowid 
    GROUP BY s.fk_product 
    HAVING SUM(s.reel) > 0
);