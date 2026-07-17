SELECT 
    c.rowid AS id_documento,
    DATE_FORMAT(c.date_creation, '%Y-%m-%d') AS fecha,
    DATE_FORMAT(c.date_creation, '%H:%i:%s') AS hora,
    e.lieu AS almacen,
    c.ref AS orden_venta,
    
    c.ref_client AS ref_client_orden,
    f.ref AS factura,
    
    cd.qty AS cantidad_vendida,
    p.ref AS sku,
    p.label AS producto,
    pe.catproveedor AS proveedor,
    pe.marcaproducto AS marca,
    cd.total_ttc AS precio_con_iva,
    cd.subprice AS precio_sin_iva,
    (cd.subprice * cd.qty) AS venta_total_sin_iva,
    p.pmp AS pmp_sin_iva,
    (cd.subprice - p.pmp) AS ganancia_produto_unitario,
    ((cd.subprice - p.pmp) * cd.qty) AS ganancia_total,
    IF((cd.subprice * cd.qty) > 0, (((cd.subprice - p.pmp) * cd.qty) / (cd.subprice * cd.qty)) * 100, 0) AS margen_porcentaje
    
FROM llx_commande AS c
INNER JOIN llx_commandedet AS cd ON cd.fk_commande = c.rowid
INNER JOIN llx_product AS p ON cd.fk_product = p.rowid
INNER JOIN llx_product_extrafields AS pe ON p.rowid = pe.fk_object

-- Filtramos el stock directamente sobre la tabla de estado actual, NO sobre el historial
INNER JOIN llx_product_stock AS s ON p.rowid = s.fk_product AND s.fk_entrepot = 1
INNER JOIN llx_entrepot AS e ON s.fk_entrepot = e.rowid

-- Encontrar factura y el numero de compra 
INNER JOIN llx_element_element AS ee ON c.rowid = ee.fk_source
INNER JOIN llx_facture AS f ON ee.fk_target = f.rowid

WHERE c.ref LIKE 'OV%'
AND s.reel > 0
-- AND ee.sourcetype = 'commande' 
ORDER BY c.rowid ASC;