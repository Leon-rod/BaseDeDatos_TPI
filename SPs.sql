CREATE PROCEDURE SP_TOTALES_FACTURADOS_VENDEDORES
@a�o int

AS
BEGIN
	SELECT YEAR(F.FECHA) 'A�O', 
		   MONTH(F.FECHA) 'MES',
		   F.ID_PERSONAL_CARGOS_ESTABLECIMIENTOS 'ID_PERSONAL',
		   P.APELLIDO + ', ' + P.NOMBRE 'PERSONAL',
		   SUM(D.CANTIDAD * D.PRECIO_UNITARIO) 'TOTAL_FACTURADO',
		   MAX(D.CANTIDAD*D.PRECIO_UNITARIO) 'VENTA_MAS_CARA'
	FROM FACTURAS F
		JOIN PERSONAL_CARGOS_ESTABLECIMIENTOS PCE ON PCE.ID_PERSONAL_CARGOS_ESTABLECIMIENTOS =  F.ID_PERSONAL_CARGOS_ESTABLECIMIENTOS
		JOIN DISPENSACIONES D ON D.ID_FACTURA = F.ID_FACTURA
		JOIN PERSONAL P ON P.ID_PERSONAL = PCE.ID_PERSONAL
	WHERE YEAR(F.FECHA) = @a�o
	GROUP BY YEAR(F.FECHA), MONTH(F.FECHA), P.APELLIDO + ', ' + P.NOMBRE, F.ID_PERSONAL_CARGOS_ESTABLECIMIENTOS
	HAVING SUM(D.CANTIDAD * D.PRECIO_UNITARIO) > (SELECT SBC.PROMEDIO
														FROM (SELECT F1.ID_PERSONAL_CARGOS_ESTABLECIMIENTOS 'ID_PERSONAL_1', AVG(D1.CANTIDAD*(D1.PRECIO_UNITARIO-(D1.DESCUENTO*D1.PRECIO_UNITARIO))) 'PROMEDIO'
															  FROM FACTURAS F1
															  JOIN DISPENSACIONES D1 ON D1.ID_FACTURA = F1.ID_FACTURA
															  WHERE YEAR(F1.FECHA) = YEAR(GETDATE())
															  GROUP BY F1.ID_PERSONAL_CARGOS_ESTABLECIMIENTOS
															  ) AS SBC
														WHERE SBC.ID_PERSONAL_1 = F.ID_PERSONAL_CARGOS_ESTABLECIMIENTOS)
END



CREATE PROCEDURE SP_TOTALES_FACTURADOS_FARMACIAS
@a�o INT = NULL
AS
BEGIN
	IF(@a�o IS NULL)
		BEGIN
			select E.ID_ESTABLECIMIENTO,e.NOMBRE 'Establecimiento', FORMAT(SUM(d.CANTIDAD * (d.PRECIO_UNITARIO - (d.PRECIO_UNITARIO * d.DESCUENTO))), 'N2') 'Total facturado'
				,(select '$' + FORMAT(SCMA.Facturado, 'N2') + ', a�o ' + CAST(SCMA.A�o AS VARCHAR(5)) from

						(select top 1 year(f.FECHA) 'A�o' , e1.NOMBRE, SUM(d.CANTIDAD * (d.PRECIO_UNITARIO - (d.PRECIO_UNITARIO * d.DESCUENTO))) 'Facturado'  from FACTURAS f 	
							join DISPENSACIONES d on f.ID_FACTURA = d.ID_FACTURA
							join PERSONAL_CARGOS_ESTABLECIMIENTOS pce on f.ID_PERSONAL_CARGOS_ESTABLECIMIENTOS = pce.ID_PERSONAL_CARGOS_ESTABLECIMIENTOS
							join ESTABLECIMIENTOS e1 on pce.ID_ESTABLECIMIENTO = e.ID_ESTABLECIMIENTO
							where e1.ID_ESTABLECIMIENTO = e.ID_ESTABLECIMIENTO
								and d.ID_MEDICAMENTO_LOTE is not null
							group by year(f.FECHA), e1.NOMBRE		
							order by 3 desc) as SCMA) 'Mejor a�o facturado' from FACTURAS f

				join DISPENSACIONES d on f.ID_FACTURA = d.ID_FACTURA
				join PERSONAL_CARGOS_ESTABLECIMIENTOS pce on f.ID_PERSONAL_CARGOS_ESTABLECIMIENTOS = pce.ID_PERSONAL_CARGOS_ESTABLECIMIENTOS
				join ESTABLECIMIENTOS e on pce.ID_ESTABLECIMIENTO = e.ID_ESTABLECIMIENTO
				where d.ID_MEDICAMENTO_LOTE is not null
				group by  E.ID_ESTABLECIMIENTO, e.NOMBRE
		END			
	ELSE
		BEGIN
			select E.ID_ESTABLECIMIENTO,e.NOMBRE 'Establecimiento', FORMAT(SUM(d.CANTIDAD * (d.PRECIO_UNITARIO - (d.PRECIO_UNITARIO * d.DESCUENTO))), 'N2') 'Total facturado'
				,(select '$' + FORMAT(SCMA.Facturado, 'N2') + ', a�o ' + CAST(SCMA.A�o AS VARCHAR(5)) from

						(select top 1 year(f.FECHA) 'A�o' , e1.NOMBRE, SUM(d.CANTIDAD * (d.PRECIO_UNITARIO - (d.PRECIO_UNITARIO * d.DESCUENTO))) 'Facturado'  from FACTURAS f 	
							join DISPENSACIONES d on f.ID_FACTURA = d.ID_FACTURA
							join PERSONAL_CARGOS_ESTABLECIMIENTOS pce on f.ID_PERSONAL_CARGOS_ESTABLECIMIENTOS = pce.ID_PERSONAL_CARGOS_ESTABLECIMIENTOS
							join ESTABLECIMIENTOS e1 on pce.ID_ESTABLECIMIENTO = e.ID_ESTABLECIMIENTO
							where e1.ID_ESTABLECIMIENTO = e.ID_ESTABLECIMIENTO
								and d.ID_MEDICAMENTO_LOTE is not null
							group by year(f.FECHA), e1.NOMBRE		
							order by 3 desc) as SCMA) 'Mejor a�o facturado' from FACTURAS f

				join DISPENSACIONES d on f.ID_FACTURA = d.ID_FACTURA
				join PERSONAL_CARGOS_ESTABLECIMIENTOS pce on f.ID_PERSONAL_CARGOS_ESTABLECIMIENTOS = pce.ID_PERSONAL_CARGOS_ESTABLECIMIENTOS
				join ESTABLECIMIENTOS e on pce.ID_ESTABLECIMIENTO = e.ID_ESTABLECIMIENTO
				where d.ID_MEDICAMENTO_LOTE is not null and YEAR(f.FECHA) = @a�o
				group by  E.ID_ESTABLECIMIENTO, e.NOMBRE
		END
END



