SELECT 
     CASE 
        WHEN ff.ref_supplier LIKE 'IN%' THEN 'INOVAUDIO'
        WHEN ff.ref_supplier LIKE 'AS%' THEN 'AUDYSON'
        WHEN ff.ref_supplier LIKE 'MI%' THEN 'GONHER S.A. DE C.V.'
        ELSE s.nom 
    END AS Proveedor, 
    DATE_FORMAT(ff.datef, '%Y') AS anio,
    SUM(ff.total_ttc) AS monto
FROM dolibarr.llx_facture_fourn AS ff 
INNER JOIN dolibarr.llx_societe AS s ON ff.fk_soc = s.rowid
WHERE s.nom IS NOT NULL           -- Excluye nombres nulos
  AND s.nom NOT LIKE '%SAT%'      -- Excluye registros que contengan "SAT"
  AND s.fk_typent IS NULL     -- Excluye registros con tipo de tercero que sean compras
  AND ff.ref LIKE 'RM%'      -- Excluye Notas de credito
GROUP BY s.nom, DATE_FORMAT(ff.datef, '%Y');