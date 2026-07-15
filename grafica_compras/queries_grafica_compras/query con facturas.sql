SELECT 
    ff.rowid, 
    DATE_FORMAT(ff.datef, '%Y-%m-%d') AS fecha_facturacion,
    DATE_FORMAT(ff.datef, '%Y') AS anio_facturacion,
    DATE_FORMAT(ff.datec, '%H:%i:%s') AS hora_facturacion,
    ff.ref, 
    ff.ref_supplier AS factura,
    -- Aquí aplicamos la lógica de corrección del nombre
    CASE 
        WHEN ff.ref_supplier LIKE 'IN%' THEN 'INOVAUDIO'
        WHEN ff.ref_supplier LIKE 'AS%' THEN 'AUDYSON'
        WHEN ff.ref_supplier LIKE 'MI%' THEN 'GONHER S.A. DE C.V.'
        ELSE s.nom 
    END AS Proveedor,  
    ff.total_ht AS total_sin_iva, 
    ff.total_tva AS iva, 
    ff.total_ttc AS total_con_iva
FROM dolibarr.llx_facture_fourn AS ff 
INNER JOIN dolibarr.llx_societe AS s ON ff.fk_soc = s.rowid
WHERE s.nom IS NOT NULL           -- Excluye nombres nulos
  AND s.nom NOT LIKE '%SAT%'      -- Excluye registros que contengan "SAT"
  AND s.fk_typent IS NOT NULL     -- Excluye registros con tipo de tercero que sean servicios u otros pagos
  AND ff.ref LIKE 'RM%'      -- Excluye Notas de credito
ORDER BY Proveedor DESC;