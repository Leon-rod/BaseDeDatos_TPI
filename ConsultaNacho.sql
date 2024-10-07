--Listar clientes con su contacto y barrio, la cantidad de compras del mes 
--y su mayor monto de compra
--que tuvieron la mayor cantidad de medicamentos dispensados cada mes
--que su mayor monto de compra sea mayor al promedio general de montos de compra
--agrupado por mes, ordenado por el total de medicamentos dispensados
SELECT 
    YEAR(F.FECHA) AS anio,  
    DATENAME(MONTH, F.FECHA) AS mes, 
    C.NOMBRE + ' ' + C.APELLIDO AS cliente, 
    SUM(CASE WHEN D.ID_MEDICAMENTO_LOTE IS NOT NULL THEN D.CANTIDAD ELSE 0 END) AS total_medicamentos,
    CO.CONTACTO, 
    B.BARRIO, 
    COUNT(*) AS cantidad_compras, 
    MAX(D.PRECIO_UNITARIO * D.CANTIDAD) AS mayor_monto 
FROM 
    DISPENSACIONES D
JOIN 
    FACTURAS F ON F.ID_FACTURA = D.ID_FACTURA
JOIN 
    CLIENTES C ON F.ID_CLIENTE = C.ID_CLIENTE
JOIN 
    CONTACTOS CO ON CO.ID_CLIENTE = C.ID_CLIENTE
JOIN 
    BARRIOS B ON B.ID_BARRIO = C.ID_BARRIO
JOIN 
    MEDICAMENTOS_LOTES ML ON ML.ID_MEDICAMENTO_LOTE = D.ID_MEDICAMENTO_LOTE
JOIN 
    MEDICAMENTOS M ON M.ID_MEDICAMENTO = ML.ID_MEDICAMENTO
GROUP BY 
    YEAR(F.FECHA), 
    DATENAME(MONTH, F.FECHA), 
    C.NOMBRE + ' ' + C.APELLIDO, 
    CO.CONTACTO, 
    B.BARRIO
HAVING 
    MAX(D.PRECIO_UNITARIO * D.CANTIDAD) > 
    (SELECT AVG(D1.PRECIO_UNITARIO * D1.CANTIDAD) 
     FROM DISPENSACIONES D1) 
ORDER BY 
    total_medicamentos DESC;
