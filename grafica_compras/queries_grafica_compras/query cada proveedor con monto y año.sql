SELECT 
    s.nom AS nombre_proveedor,
    DATE_FORMAT(ff.datef, '%Y') AS anio,
    SUM(ff.total_ttc) AS monto
FROM dolibarr.llx_facture_fourn AS ff 
INNER JOIN dolibarr.llx_societe AS s ON ff.fk_soc = s.rowid
WHERE ff.ref LIKE 'RM%'
GROUP BY s.nom, DATE_FORMAT(ff.datef, '%Y');