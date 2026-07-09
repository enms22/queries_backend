SELECT 
    pt.rowid AS id_documento, -- id ticket6
    DATE_FORMAT(pt.date_creation, '%Y-%m-%d') AS fecha,
    DATE_FORMAT(pt.date_creation,'%H:%i:%s') AS hora, -- hora de creacion
    caja.name AS terminal,
    pt.ticketnumber AS num_ticket,
    td.qty AS cantidad_vendida,
    p.ref AS sku, -- sku interno de nosotros y descripcion margebn de 
    p.label AS producto, -- producto
    pe.catproveedor AS proveedor, -- proveedor
    pe.marcaproducto AS marca, -- marca
	td.total_ttc AS precio_con_iva,
    td.subprice AS precio_sin_iva, -- ficha del producto
    (td.subprice * td.qty ) AS venta_total_sin_iva,
	p.pmp AS pmp_sin_iva,
    (td.subprice - p.pmp) AS ganancia_produto_unitario,
    -- Resta: Ganancia unitaria multiplicada por la cantidad vendida
    ((td.subprice - p.pmp) * td.qty) AS ganancia_total,  -- (p.price - (p.pmp * td.qty)) AS ganancia_total_moneda,
    -- Porcentaje de margen: (Venta - Costo) / Venta
    IF((td.subprice * td.qty) > 0, (((td.subprice- p.pmp) * td.qty) / (td.subprice * td.qty)) * 100, 0) AS margen_porcentaje -- IF(p.price > 0, ((p.price - (p.pmp * td.qty)) / p.price) * 100, 0) AS margen_porcentaje,
   
    
FROM llx_product AS p

INNER JOIN llx_product_extrafields AS pe ON p.rowid = pe.fk_object
-- Usar tabla llx_pos_ticketdet para saber que producto se vendio en cada ticket
INNER JOIN llx_pos_ticketdet AS td ON p.rowid = td.fk_product
-- Usar tabla llx_pos_ticket para saber el numero del ticket e informacion en general
INNER JOIN llx_pos_ticket AS pt ON td.fk_ticket = pt.rowid
-- Usar tabla llx_product_stock para saber el stock
INNER JOIN llx_product_stock AS s ON p.rowid = s.fk_product
-- Usar tabla llx_entrepot para saber el stock
INNER JOIN llx_entrepot AS e ON s.fk_entrepot = e.rowid

LEFT JOIN llx_pos_cash AS caja ON pt.fk_cash = caja.rowid

WHERE DATE(pt.date_creation) = '2025-12-23'
AND pt.ticketnumber LIKE 'VPV%'

AND s.reel > 0

GROUP BY 
    p.rowid, 
    p.ref, 
    p.label, 
    pe.catproveedor, 
    pe.marcaproducto, 
    p.price, 
    p.pmp, 
    pt.rowid,
    pt.ticketnumber,
    td.total_ttc,
    td.subprice,
    td.qty,
    pt.date_creation

HAVING SUM(s.reel) > 0
ORDER BY pt.rowid ASC;