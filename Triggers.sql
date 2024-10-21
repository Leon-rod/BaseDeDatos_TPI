CREATE TRIGGER DIS_ACTUALIZAR_INVENTARIO_VENTA
ON DISPENSACIONES
FOR INSERT
AS
BEGIN

	INSERT INTO INVENTARIOS(ID_FACTURA, ID_DISPENSACION, ID_TIPO_MOV, ID_STOCK)
	SELECT i.ID_FACTURA, i.ID_DISPENSACION, 2, s.ID_STOCK
	FROM inserted i join STOCKS s on i.ID_MEDICAMENTO_LOTE = s.ID_MEDICAMENTO_LOTE
	join FACTURAS f on f.ID_FACTURA = i.ID_FACTURA
	join PERSONAL_CARGOS_ESTABLECIMIENTOS p on p.ID_PERSONAL_CARGOS_ESTABLECIMIENTOS = f.ID_PERSONAL_CARGOS_ESTABLECIMIENTOS
	join ESTABLECIMIENTOS e on p.ID_ESTABLECIMIENTO = e.ID_ESTABLECIMIENTO
	where p.ID_ESTABLECIMIENTO = s.ID_ESTABLECIMIENTO
END

CREATE TRIGGER DIS_VERIFICAR_STOCK_VENTA
ON DISPENSACIONES
INSTEAD OF INSERT
AS
	DECLARE @PRODUCTO INT
	

	SELECT @PRODUCTO = i.ID_PRODUCTO FROM inserted i
		IF(@PRODUCTO IS NULL)
			BEGIN
						DECLARE @STOCK_MEDICAMENTO INT
						SELECT @STOCK_MEDICAMENTO = s.CANTIDAD FROM inserted i join STOCKS s on i.ID_MEDICAMENTO_LOTE = s.ID_MEDICAMENTO_LOTE
							join FACTURAS f on f.ID_FACTURA = i.ID_FACTURA
							join PERSONAL_CARGOS_ESTABLECIMIENTOS p on p.ID_PERSONAL_CARGOS_ESTABLECIMIENTOS = f.ID_PERSONAL_CARGOS_ESTABLECIMIENTOS
							join ESTABLECIMIENTOS e on p.ID_ESTABLECIMIENTO = e.ID_ESTABLECIMIENTO
							where p.ID_ESTABLECIMIENTO = s.ID_ESTABLECIMIENTO

							IF(@STOCK_MEDICAMENTO = 0 OR @STOCK_MEDICAMENTO is null)
							begin
								raiserror('No hay stock del medicamento para vender', 10, 1)
								rollback transaction
								RETURN
							end
							ELSE
								BEGIN
									INSERT INTO DISPENSACIONES(ID_FACTURA, ID_DISPENSACION, ID_MEDICAMENTO_LOTE, ID_COBERTURA
											, DESCUENTO, PRECIO_UNITARIO, CANTIDAD, MATRICULA, CODIGO_VALIDACION)
									SELECT ID_FACTURA, ID_DISPENSACION, ID_MEDICAMENTO_LOTE, ID_COBERTURA
											, DESCUENTO, PRECIO_UNITARIO, CANTIDAD, MATRICULA, CODIGO_VALIDACION
										FROM inserted
								END

			END
		ELSE
			BEGIN
						DECLARE @STOCK_PRODUCTO INT
						SELECT @STOCK_PRODUCTO = s.CANTIDAD FROM inserted i join STOCKS s on i.ID_PRODUCTO = s.ID_PRODUCTO
							join FACTURAS f on f.ID_FACTURA = i.ID_FACTURA
							join PERSONAL_CARGOS_ESTABLECIMIENTOS p on p.ID_PERSONAL_CARGOS_ESTABLECIMIENTOS = f.ID_PERSONAL_CARGOS_ESTABLECIMIENTOS
							join ESTABLECIMIENTOS e on p.ID_ESTABLECIMIENTO = e.ID_ESTABLECIMIENTO
							where p.ID_ESTABLECIMIENTO = s.ID_ESTABLECIMIENTO

							IF(@STOCK_PRODUCTO = 0 OR @STOCK_PRODUCTO is null)
							begin
								raiserror('No hay stock del producto para vender', 10, 1)
								rollback transaction
								RETURN
							end
							ELSE
								BEGIN
								
									INSERT INTO DISPENSACIONES(ID_FACTURA, ID_DISPENSACION, ID_PRODUCTO
												, DESCUENTO, PRECIO_UNITARIO, CANTIDAD)
									SELECT ID_FACTURA, ID_DISPENSACION, ID_PRODUCTO
												, DESCUENTO, PRECIO_UNITARIO, CANTIDAD
											FROM inserted
								END
			END




-- INICIO TEST TRIGGER DIS_VERIFICAR_STOCK_VENTA
INSERT INTO DISPENSACIONES(ID_DISPENSACION, ID_FACTURA, ID_MEDICAMENTO_LOTE, ID_PRODUCTO, DESCUENTO, PRECIO_UNITARIO, CANTIDAD, MATRICULA, CODIGO_VALIDACION)
VALUES(13, 1, NULL, 5, 0, 2220, 2, NULL, NULL)


	--establecimiento 2
	--producto 5
	-- FUNCIONA PRODUCTOS si no tiene stock tira el error y si no, inserta bien


INSERT INTO DISPENSACIONES(ID_DISPENSACION,ID_FACTURA,ID_MEDICAMENTO_LOTE, ID_COBERTURA, DESCUENTO,PRECIO_UNITARIO,CANTIDAD,MATRICULA,CODIGO_VALIDACION)
	VALUES(26,2,3,1,0.20,855.54,6,'AB123CD','JCKI4902')

	-- establecimiento 4
	-- medicamento 3
	-- FUNCIONA MEDICAMENTOS si no tiene stock tira el error y si no, inserta bien

--- FIN TEST TRIGGER DIS_VERIFICAR_STOCK_VENTA



-- Trigger para la autoinsercion de inventarios en casos de reposicion.
-- El trigger insertara un registro por cada insercion en detalles_pedidos, 
-- tomando en cuenta el ultimo stock del establecimiento (conseguido mediante fecha en caso de que hayan registros de stocks historicos).
-- En caso de que el establecimiento no posea registros de ese stock, es decir, es la primera vez que se repone
-- ese articulo, el trigger procedera a crear un nuevo registro en stock, el cual tendr� por defecto los siguientes valores:
--	- Fecha: Valor en formato DATE en el que se disparo el trigger,
--	- Cantidad: Valor proveniente del detalle_pedido
--	- Cantidad_Minima: Valor 200 por defecto (SUJETO A CAMBIO!!!)
--Una vez insertado el stock, procedera a insertar a inventario haciendo referencia a ese nuevo stock
CREATE TRIGGER DIS_REPONER_ARTICULO
ON DETALLES_PEDIDOS
FOR INSERT
AS
BEGIN
	IF(EXISTS (SELECT S.ID_STOCK
			   FROM inserted I
			   JOIN STOCKS S ON S.ID_PRODUCTO = I.ID_PRODUCTO
			   JOIN PEDIDOS P ON P.ID_PEDIDO = I.ID_PEDIDO
			   JOIN PERSONAL_CARGOS_ESTABLECIMIENTOS PCE ON PCE.ID_PERSONAL_CARGOS_ESTABLECIMIENTOS = P.ID_PERSONAL_CARGOS_ESTABLECIMIENTOS
			   WHERE S.ID_ESTABLECIMIENTO = PCE.ID_ESTABLECIMIENTO)
	  OR EXISTS(SELECT S.ID_STOCK
			   FROM inserted I
			   JOIN STOCKS S ON S.ID_MEDICAMENTO_LOTE = I.ID_MEDICAMENTO_LOTE
			   JOIN PEDIDOS P ON P.ID_PEDIDO = I.ID_PEDIDO
			   JOIN PERSONAL_CARGOS_ESTABLECIMIENTOS PCE ON PCE.ID_PERSONAL_CARGOS_ESTABLECIMIENTOS = P.ID_PERSONAL_CARGOS_ESTABLECIMIENTOS
			   WHERE S.ID_ESTABLECIMIENTO = PCE.ID_ESTABLECIMIENTO))
	BEGIN
		IF ((SELECT I.ID_MEDICAMENTO_LOTE FROM inserted I) IS NULL)
		BEGIN
			INSERT INTO INVENTARIOS(ID_PEDIDO,ID_DETALLE_PEDIDO,ID_TIPO_MOV,ID_STOCK)
			SELECT I.ID_PEDIDO, I.ID_DETALLE_PEDIDO, 1, S.ID_STOCK
			FROM inserted I
			JOIN STOCKS S ON S.ID_PRODUCTO = I.ID_PRODUCTO
			JOIN PEDIDOS P ON P.ID_PEDIDO = I.ID_PEDIDO
			JOIN PERSONAL_CARGOS_ESTABLECIMIENTOS PCE ON PCE.ID_PERSONAL_CARGOS_ESTABLECIMIENTOS = P.ID_PERSONAL_CARGOS_ESTABLECIMIENTOS
			WHERE PCE.ID_ESTABLECIMIENTO = S.ID_ESTABLECIMIENTO
			AND S.ID_STOCK = (SELECT TOP 1 S1.ID_STOCK
							  FROM STOCKS S1
							  WHERE S1.ID_ESTABLECIMIENTO = PCE.ID_ESTABLECIMIENTO
							  AND S1.ID_PRODUCTO = S.ID_PRODUCTO
							  ORDER BY S1.FECHA DESC)
			RETURN
		END
		ELSE
		BEGIN
			INSERT INTO INVENTARIOS(ID_PEDIDO,ID_DETALLE_PEDIDO,ID_TIPO_MOV,ID_STOCK)
			SELECT I.ID_PEDIDO, I.ID_DETALLE_PEDIDO, 1, S.ID_MEDICAMENTO_LOTE
			FROM inserted I
			JOIN STOCKS S ON S.ID_MEDICAMENTO_LOTE = I.ID_MEDICAMENTO_LOTE
			JOIN PEDIDOS P ON P.ID_PEDIDO = I.ID_PEDIDO
			JOIN PERSONAL_CARGOS_ESTABLECIMIENTOS PCE ON PCE.ID_PERSONAL_CARGOS_ESTABLECIMIENTOS = P.ID_PERSONAL_CARGOS_ESTABLECIMIENTOS
			WHERE PCE.ID_ESTABLECIMIENTO = S.ID_ESTABLECIMIENTO
			AND S.ID_STOCK = (SELECT TOP 1 S1.ID_STOCK
							  FROM STOCKS S1
							  WHERE S1.ID_ESTABLECIMIENTO = PCE.ID_ESTABLECIMIENTO
							  AND S1.ID_MEDICAMENTO_LOTE = S.ID_MEDICAMENTO_LOTE
							  ORDER BY S1.FECHA DESC)
			RETURN
		END
	END
	ELSE
	BEGIN
		DECLARE @ID_STOCK INT;
		SELECT @ID_STOCK = (SELECT MAX(ID_STOCK) FROM STOCKS) + 1
		INSERT INTO STOCKS(ID_STOCK, FECHA, CANTIDAD, CANTIDAD_MINIMA, ID_PRODUCTO, ID_MEDICAMENTO_LOTE, ID_ESTABLECIMIENTO)
		SELECT @ID_STOCK, 
			   CONVERT(DATE,GETDATE()), 
			   I.CANTIDAD, 200, 
			   IIF(I.ID_PRODUCTO IS NOT NULL,I.ID_PRODUCTO,NULL),
			   IIF(I.ID_MEDICAMENTO_LOTE IS NOT NULL,I.ID_MEDICAMENTO_LOTE,NULL),
			   E.ID_ESTABLECIMIENTO
		FROM inserted I
		JOIN PEDIDOS P ON P.ID_PEDIDO = I.ID_PEDIDO
		JOIN PERSONAL_CARGOS_ESTABLECIMIENTOS PCE ON PCE.ID_PERSONAL_CARGOS_ESTABLECIMIENTOS = P.ID_PERSONAL_CARGOS_ESTABLECIMIENTOS
		JOIN ESTABLECIMIENTOS E ON E.ID_ESTABLECIMIENTO = PCE.ID_ESTABLECIMIENTO;

		INSERT INTO INVENTARIOS(ID_PEDIDO,ID_DETALLE_PEDIDO,ID_TIPO_MOV,ID_STOCK)
		SELECT I.ID_PEDIDO, I.ID_DETALLE_PEDIDO, 1, @ID_STOCK
		FROM inserted I
	END
END

-- INICIO TEST TRIGGER DIS_REPONER_ARTICULO

--Se debe tener en cuenta la posibilidad de que el establecimiento tenga o no previamente 
--un registro de stock cargado; seg�n eso, proceder� a crear uno o usar el ya existente
INSERT INTO DETALLES_PEDIDOS(ID_PEDIDO,ID_DETALLE_PEDIDO,ID_MEDICAMENTO_LOTE,ID_PROVEEDOR,ID_PRODUCTO,CANTIDAD,PRECIO_UNITARIO)
VALUES (4,5,NULL,11,11,300,3500)

--Para el seguimiento de valores insertados al pedido con id_pedido = 4
SELECT * FROM DETALLES_PEDIDOS
SELECT * FROM INVENTARIOS
WHERE ID_PEDIDO = 4
SELECT * FROM STOCKS
WHERE ID_ESTABLECIMIENTO = 3
