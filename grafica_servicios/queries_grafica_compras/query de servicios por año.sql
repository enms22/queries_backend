SELECT 
    'TOTALES 2022' AS rowid,
    '' AS fecha_facturacion,
    '2022' AS anio_facturacion,
    '' AS hora_facturacion,
    '---' AS ref,
    'SUMA TOTAL RM 2022' AS nombre_proveedor,
    SUM(ff.total_ht) AS total_sin_iva,
    SUM(ff.total_tva) AS iva,
    SUM(ff.total_ttc) AS total_con_iva
FROM dolibarr.llx_facture_fourn AS ff 
INNER JOIN dolibarr.llx_societe AS s ON ff.fk_soc = s.rowid
-- WHERE s.nom = 'YAMAHA DE MEXICO S.A DE C.V'

WHERE s.nom IS NOT NULL           -- Excluye nombres nulos
  AND s.nom NOT LIKE '%SAT%'      -- Excluye registros que contengan "SAT"
  AND s.fk_typent IS NULL     -- Excluye registros con tipo de tercero que sean compras
  AND ff.ref LIKE 'RM%'      -- Excluye Notas de credito
-- AND DATE_FORMAT(ff.datef, '%Y') = '2022'