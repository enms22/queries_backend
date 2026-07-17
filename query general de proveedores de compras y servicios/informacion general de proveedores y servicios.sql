SELECT 
    CASE 
        WHEN ff.ref_supplier LIKE 'IN%' THEN 'INOVAUDIO'
        WHEN ff.ref_supplier LIKE 'AS%' THEN 'AUDYSON'
        WHEN ff.ref_supplier LIKE 'MI%' THEN 'GONHER S.A. DE C.V.'
        ELSE s.nom 
    END AS Proveedor,
    s.fk_typent AS id_tipo_proveedor,
    ct.libelle AS tipo_proveedor_frances,
    CASE 
        WHEN s.fk_typent IS NULL THEN 'Servicio'
        WHEN ct.code = 'TE_STARTUP' THEN 'Start-up'
        WHEN ct.code = 'TE_GROUP'   THEN 'Gran grupo'
        WHEN ct.code = 'TE_MEDIUM'  THEN 'PME/PMI'
        WHEN ct.code = 'TE_SMALL'   THEN 'TPE'
        WHEN ct.code = 'TE_ADMIN'   THEN 'Administración'
        WHEN ct.code = 'TE_WHOLE'   THEN 'Mayorista'
        WHEN ct.code = 'TE_RETAIL'  THEN 'Revendedor'
        WHEN ct.code = 'TE_PRIVATE' THEN 'Particular'
        WHEN ct.code = 'TE_OTHER'   THEN 'Otros'
        ELSE ct.libelle 
    END AS tipo_proveedor,
    SUM(ff.total_ttc) AS Total_General
FROM dolibarr.llx_facture_fourn AS ff
INNER JOIN dolibarr.llx_societe AS s ON ff.fk_soc = s.rowid
LEFT JOIN dolibarr_aux.llx_c_typent AS ct ON s.fk_typent = ct.id
WHERE s.nom IS NOT NULL
-- AND s.nom NOT LIKE '%SAT%' en este caso se incluira SAT por eso se comento esta linea
  AND ff.ref LIKE 'RM%'
GROUP BY 
    CASE 
        WHEN ff.ref_supplier LIKE 'IN%' THEN 'INOVAUDIO'
        WHEN ff.ref_supplier LIKE 'AS%' THEN 'AUDYSON'
        WHEN ff.ref_supplier LIKE 'MI%' THEN 'GONHER S.A. DE C.V.'
        ELSE s.nom 
    END,
    s.fk_typent,
    ct.code,
    ct.libelle
ORDER BY Proveedor;