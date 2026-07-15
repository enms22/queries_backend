SELECT 
    CASE 
        WHEN ff.ref_supplier LIKE 'IN%' THEN 'INOVAUDIO'
        WHEN ff.ref_supplier LIKE 'AS%' THEN 'AUDYSON'
        WHEN ff.ref_supplier LIKE 'MI%' THEN 'GONHER S.A. DE C.V.'
        ELSE s.nom 
    END AS Proveedor,
    SUM(CASE WHEN DATE_FORMAT(ff.datec, '%Y') = '2015' THEN ff.total_ttc ELSE 0 END) AS '2015',
    SUM(CASE WHEN DATE_FORMAT(ff.datec, '%Y') = '2016' THEN ff.total_ttc ELSE 0 END) AS '2016',
    SUM(CASE WHEN DATE_FORMAT(ff.datec, '%Y') = '2017' THEN ff.total_ttc ELSE 0 END) AS '2017',
    SUM(CASE WHEN DATE_FORMAT(ff.datec, '%Y') = '2018' THEN ff.total_ttc ELSE 0 END) AS '2018',
    SUM(CASE WHEN DATE_FORMAT(ff.datec, '%Y') = '2019' THEN ff.total_ttc ELSE 0 END) AS '2019',
    SUM(CASE WHEN DATE_FORMAT(ff.datec, '%Y') = '2020' THEN ff.total_ttc ELSE 0 END) AS '2020',
    SUM(CASE WHEN DATE_FORMAT(ff.datec, '%Y') = '2021' THEN ff.total_ttc ELSE 0 END) AS '2021',
    SUM(CASE WHEN DATE_FORMAT(ff.datec, '%Y') = '2022' THEN ff.total_ttc ELSE 0 END) AS '2022',
    SUM(CASE WHEN DATE_FORMAT(ff.datec, '%Y') = '2023' THEN ff.total_ttc ELSE 0 END) AS '2023',
    SUM(CASE WHEN DATE_FORMAT(ff.datec, '%Y') = '2024' THEN ff.total_ttc ELSE 0 END) AS '2024',
    SUM(CASE WHEN DATE_FORMAT(ff.datec, '%Y') = '2025' THEN ff.total_ttc ELSE 0 END) AS '2025',
    SUM(CASE WHEN DATE_FORMAT(ff.datec, '%Y') = '2026' THEN ff.total_ttc ELSE 0 END) AS '2026',
    SUM(CASE WHEN DATE_FORMAT(ff.datec, '%Y') = '2027' THEN ff.total_ttc ELSE 0 END) AS '2027'
FROM dolibarr.llx_facture_fourn AS ff
INNER JOIN dolibarr.llx_societe AS s ON ff.fk_soc = s.rowid
WHERE s.nom IS NOT NULL           -- Excluye nombres nulos
  AND s.nom NOT LIKE '%SAT%'      -- Excluye registros que contengan "SAT"
  AND s.fk_typent IS NOT NULL     -- Excluye registros con tipo de tercero que sean servicios u otros pagos
  AND ff.ref LIKE 'RM%'      -- Excluye Notas de credito

GROUP BY 
    CASE 
        WHEN ff.ref_supplier LIKE 'IN%' THEN 'INOVAUDIO'
        WHEN ff.ref_supplier LIKE 'AS%' THEN 'AUDYSON'
        WHEN ff.ref_supplier LIKE 'MI%' THEN 'GONHER S.A. DE C.V.'
        ELSE s.nom 
    END
    ORDER BY Proveedor;