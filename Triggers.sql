--- TERMINADO


CREATE TRIGGER DIS_VERIFICAR_STOCK_VENTA
ON DISPENSACIONES
INSTEAD OF INSERT
AS
	DECLARE @PRODUCTO INT
	DECLARE @CANTIDAD INT

	SELECT @CANTIDAD = I.CANTIDAD FROM inserted I
	SELECT @PRODUCTO = i.ID_PRODUCTO FROM inserted i

		IF(@PRODUCTO IS NULL)
			BEGIN
					DECLARE @STOCK_MEDICAMENTO INT						
					DECLARE @ID_STOCK_MED INT

					SELECT @STOCK_MEDICAMENTO = s.CANTIDAD, @ID_STOCK_MED = S.ID_STOCK FROM inserted i join STOCKS s on i.ID_MEDICAMENTO_LOTE = s.ID_MEDICAMENTO_LOTE
						join FACTURAS f on f.ID_FACTURA = i.ID_FACTURA
						join PERSONAL_CARGOS_ESTABLECIMIENTOS p on p.ID_PERSONAL_CARGOS_ESTABLECIMIENTOS = f.ID_PERSONAL_CARGOS_ESTABLECIMIENTOS
						join ESTABLECIMIENTOS e on p.ID_ESTABLECIMIENTO = e.ID_ESTABLECIMIENTO
						where p.ID_ESTABLECIMIENTO = s.ID_ESTABLECIMIENTO
							AND	S.ID_STOCK = (SELECT TOP 1 ID_STOCK FROM STOCKS
												WHERE ID_MEDICAMENTO_LOTE = i.ID_MEDICAMENTO_LOTE AND ID_ESTABLECIMIENTO = p.ID_ESTABLECIMIENTO
												ORDER BY FECHA DESC)

						IF(@STOCK_MEDICAMENTO = 0 OR @STOCK_MEDICAMENTO is null OR @STOCK_MEDICAMENTO < @CANTIDAD)
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
								UPDATE STOCKS
								SET CANTIDAD = CANTIDAD-@CANTIDAD
								WHERE ID_STOCK = @ID_STOCK_MED
							END

			END
		ELSE
			BEGIN
						DECLARE @STOCK_PRODUCTO INT
						DECLARE @ID_STOCK_PROD INT

						SELECT @STOCK_PRODUCTO = s.CANTIDAD, @ID_STOCK_PROD = S.ID_STOCK FROM inserted i join STOCKS s on i.ID_PRODUCTO = s.ID_PRODUCTO
							join FACTURAS f on f.ID_FACTURA = i.ID_FACTURA
							join PERSONAL_CARGOS_ESTABLECIMIENTOS p on p.ID_PERSONAL_CARGOS_ESTABLECIMIENTOS = f.ID_PERSONAL_CARGOS_ESTABLECIMIENTOS
							join ESTABLECIMIENTOS e on p.ID_ESTABLECIMIENTO = e.ID_ESTABLECIMIENTO
							where p.ID_ESTABLECIMIENTO = s.ID_ESTABLECIMIENTO
								AND	S.ID_STOCK = (SELECT TOP 1 ID_STOCK FROM STOCKS
												WHERE ID_PRODUCTO = i.ID_PRODUCTO AND ID_ESTABLECIMIENTO = p.ID_ESTABLECIMIENTO
												ORDER BY FECHA DESC)

							IF(@STOCK_PRODUCTO = 0 OR @STOCK_PRODUCTO is null OR @STOCK_PRODUCTO < @CANTIDAD)
							BEGIN
								raiserror('No hay stock del producto para vender', 10, 1)
								rollback transaction
								RETURN
							END
							ELSE
								BEGIN
								
									INSERT INTO DISPENSACIONES(ID_FACTURA, ID_DISPENSACION, ID_PRODUCTO
												, DESCUENTO, PRECIO_UNITARIO, CANTIDAD)
									SELECT ID_FACTURA, ID_DISPENSACION, ID_PRODUCTO
												, DESCUENTO, PRECIO_UNITARIO, CANTIDAD
											FROM inserted
									UPDATE STOCKS
									SET CANTIDAD = CANTIDAD-@CANTIDAD
									WHERE ID_STOCK = @ID_STOCK_PROD
								END
			END





-------------------------------------------------------
---- TERMINADO
CREATE TRIGGER DIS_ACTUALIZAR_INVENTARIO_VENTA
ON DISPENSACIONES
FOR INSERT
AS
BEGIN
	DECLARE @PRODUCTO INT
	
	SELECT @PRODUCTO = i.ID_PRODUCTO FROM inserted i

	IF(@PRODUCTO IS NULL)
		BEGIN
			INSERT INTO INVENTARIOS(ID_FACTURA, ID_DISPENSACION, ID_TIPO_MOV, ID_STOCK)
			SELECT i.ID_FACTURA, i.ID_DISPENSACION, 2, s.ID_STOCK
			FROM inserted i join STOCKS s on i.ID_MEDICAMENTO_LOTE = s.ID_MEDICAMENTO_LOTE
			join FACTURAS f on f.ID_FACTURA = i.ID_FACTURA
			join PERSONAL_CARGOS_ESTABLECIMIENTOS p on p.ID_PERSONAL_CARGOS_ESTABLECIMIENTOS = f.ID_PERSONAL_CARGOS_ESTABLECIMIENTOS
			join ESTABLECIMIENTOS e on p.ID_ESTABLECIMIENTO = e.ID_ESTABLECIMIENTO
			where p.ID_ESTABLECIMIENTO = s.ID_ESTABLECIMIENTO
					AND	S.ID_STOCK = (SELECT TOP 1 ID_STOCK FROM STOCKS
										WHERE ID_MEDICAMENTO_LOTE = i.ID_MEDICAMENTO_LOTE AND ID_ESTABLECIMIENTO = p.ID_ESTABLECIMIENTO
										ORDER BY FECHA DESC)
		END
	ELSE
			BEGIN
			INSERT INTO INVENTARIOS(ID_FACTURA, ID_DISPENSACION, ID_TIPO_MOV, ID_STOCK)
			SELECT i.ID_FACTURA, i.ID_DISPENSACION, 2, s.ID_STOCK
			FROM inserted i join STOCKS s on i.ID_PRODUCTO = s.ID_PRODUCTO
			join FACTURAS f on f.ID_FACTURA = i.ID_FACTURA
			join PERSONAL_CARGOS_ESTABLECIMIENTOS p on p.ID_PERSONAL_CARGOS_ESTABLECIMIENTOS = f.ID_PERSONAL_CARGOS_ESTABLECIMIENTOS
			join ESTABLECIMIENTOS e on p.ID_ESTABLECIMIENTO = e.ID_ESTABLECIMIENTO
			where p.ID_ESTABLECIMIENTO = s.ID_ESTABLECIMIENTO
								AND	S.ID_STOCK = (SELECT TOP 1 ID_STOCK FROM STOCKS
										WHERE ID_PRODUCTO = i.ID_PRODUCTO AND ID_ESTABLECIMIENTO = p.ID_ESTABLECIMIENTO
										ORDER BY FECHA DESC)
		END
END



-------------------------------------------------------
--- TERMINADO
CREATE TRIGGER DIS_ACTUALIZAR_STOCK_OTROS
ON INVENTARIOS
FOR INSERT
AS
BEGIN
	DECLARE @ID_STOCK INT
	DECLARE @ID_FACTURA INT
	DECLARE @ID_PEDIDO INT
	DECLARE @CANTIDAD INT
	DECLARE @MODIFICADOR INT
	
	SELECT @ID_STOCK = i.ID_STOCK, @ID_FACTURA = i.ID_FACTURA, @ID_PEDIDO = i.ID_PEDIDO, @CANTIDAD = i.CANTIDAD, @MODIFICADOR = tp.MODIFICADOR FROM inserted i
	JOIN TIPOS_MOVIMIENTOS tp on i.ID_TIPO_MOV = tp.ID_TIPO_MOV

	IF(@ID_FACTURA IS NULL AND @ID_PEDIDO IS NULL)
		BEGIN
			UPDATE STOCKS
			SET CANTIDAD = CANTIDAD + (@CANTIDAD * @MODIFICADOR)
			WHERE ID_STOCK = @ID_STOCK
		END

END

--- MODIFICADOR sirve para darle el signo correspondiente a la suma. Actualmente este trigger esta pensado para roturas, vencimientos etc osea todos -1 pero para pensarlo de forma
-- escalable, por si en un futuro tenemos otro tipo de movimiento que sume, lo decidimos usar como una variable.



--------------------------------------------------------------------------------------------------

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
			DECLARE @CANTIDAD INT;
			DECLARE @ID_STOCK_PRODUCTO INT;
			SELECT @CANTIDAD = I.CANTIDAD, @ID_STOCK_PRODUCTO = S.ID_STOCK
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
			UPDATE STOCKS
			SET CANTIDAD = CANTIDAD+@CANTIDAD
			WHERE ID_STOCK = @ID_STOCK_PRODUCTO

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
			DECLARE @CANTIDAD_MED INT;
			DECLARE @ID_STOCK_MED INT;
			SELECT @CANTIDAD_MED = I.CANTIDAD, @ID_STOCK_MED = S.ID_STOCK
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
			UPDATE STOCKS
			SET CANTIDAD = CANTIDAD+@CANTIDAD_MED
			WHERE ID_STOCK = @ID_STOCK_MED
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




-----------------------------------------------------------

CREATE TRIGGER DIS_REPONER_STOCK_DISPENSACION_ELIMINADA
ON DISPENSACIONES
INSTEAD OF DELETE
AS
BEGIN
	DECLARE @ID_PRODUCTO INT
	DECLARE @CANTIDAD INT
	DECLARE @ID_STOCK_PRODUCTO INT
	DECLARE @ID_STOCK_MEDICAMENTO INT
	DECLARE @ID_FACTURA INT
	DECLARE @ID_DISPENSACION INT

	SELECT @CANTIDAD = d.CANTIDAD, @ID_PRODUCTO = d.ID_PRODUCTO FROM deleted d

	IF(@ID_PRODUCTO IS NULL)
		BEGIN
			SELECT @ID_FACTURA = d1.ID_FACTURA, @ID_DISPENSACION = d1.ID_DISPENSACION , @ID_STOCK_MEDICAMENTO = s.ID_STOCK FROM deleted d1 join STOCKS s on d1.ID_MEDICAMENTO_LOTE = s.ID_MEDICAMENTO_LOTE
						join FACTURAS f on f.ID_FACTURA = d1.ID_FACTURA
						join PERSONAL_CARGOS_ESTABLECIMIENTOS p on p.ID_PERSONAL_CARGOS_ESTABLECIMIENTOS = f.ID_PERSONAL_CARGOS_ESTABLECIMIENTOS
						join ESTABLECIMIENTOS e on p.ID_ESTABLECIMIENTO = e.ID_ESTABLECIMIENTO
						where p.ID_ESTABLECIMIENTO = s.ID_ESTABLECIMIENTO
							AND	S.ID_STOCK = (SELECT TOP 1 ID_STOCK FROM STOCKS
												WHERE ID_MEDICAMENTO_LOTE = d1.ID_MEDICAMENTO_LOTE AND ID_ESTABLECIMIENTO = p.ID_ESTABLECIMIENTO
												ORDER BY FECHA DESC)
			
			DELETE FROM INVENTARIOS
			WHERE ID_FACTURA = @ID_FACTURA AND ID_DISPENSACION = @ID_DISPENSACION

			DELETE FROM DISPENSACIONES
			WHERE ID_FACTURA = @ID_FACTURA AND ID_DISPENSACION = @ID_DISPENSACION

			UPDATE STOCKS
			SET CANTIDAD = CANTIDAD + @CANTIDAD
			WHERE ID_STOCK = @ID_STOCK_MEDICAMENTO
		END

	ELSE
		BEGIN

			SELECT @ID_FACTURA = d1.ID_FACTURA, @ID_DISPENSACION = d1.ID_DISPENSACION , @ID_STOCK_PRODUCTO = s.ID_STOCK FROM deleted d1 join STOCKS s on d1.ID_PRODUCTO = s.ID_PRODUCTO
							join FACTURAS f on f.ID_FACTURA = d1.ID_FACTURA
							join PERSONAL_CARGOS_ESTABLECIMIENTOS p on p.ID_PERSONAL_CARGOS_ESTABLECIMIENTOS = f.ID_PERSONAL_CARGOS_ESTABLECIMIENTOS
							join ESTABLECIMIENTOS e on p.ID_ESTABLECIMIENTO = e.ID_ESTABLECIMIENTO
							where p.ID_ESTABLECIMIENTO = s.ID_ESTABLECIMIENTO
								AND	S.ID_STOCK = (SELECT TOP 1 ID_STOCK FROM STOCKS
												WHERE ID_PRODUCTO = d1.ID_PRODUCTO AND ID_ESTABLECIMIENTO = p.ID_ESTABLECIMIENTO
												ORDER BY FECHA DESC)



			--INSERT INTO INVENTARIOS(ID_FACTURA, ID_DISPENSACION, ID_TIPO_MOV, ID_STOCK, CANTIDAD, FECHA)
			--SELECT d.ID_FACTURA, d.ID_DISPENSACION, 8, s.ID_STOCK, d.CANTIDAD, GETDATE() FROM deleted d join STOCKS s on d.ID_PRODUCTO = s.ID_PRODUCTO

			DELETE FROM INVENTARIOS
			WHERE ID_FACTURA = @ID_FACTURA AND ID_DISPENSACION = @ID_DISPENSACION

			DELETE FROM DISPENSACIONES
			WHERE ID_FACTURA = @ID_FACTURA AND ID_DISPENSACION = @ID_DISPENSACION

			UPDATE STOCKS
			SET CANTIDAD = CANTIDAD + @CANTIDAD
			WHERE ID_STOCK = @ID_STOCK_PRODUCTO

		END
END




CREATE TRIGGER DIS_REPONER_STOCK_DETALLE_PEDIDO_ELIMINADO
ON DETALLES_PEDIDOS
INSTEAD OF DELETE
AS
BEGIN
	DECLARE @ID_PRODUCTO INT
	DECLARE @CANTIDAD INT
	DECLARE @ID_STOCK_PRODUCTO INT
	DECLARE @ID_STOCK_MEDICAMENTO INT
	DECLARE @ID_PEDIDO INT
	DECLARE @ID_DETALLE_PEDIDO INT

	SELECT @CANTIDAD = d.CANTIDAD, @ID_PRODUCTO = d.ID_PRODUCTO FROM deleted d

	IF(@ID_PRODUCTO IS NULL)
		BEGIN
			SELECT @ID_PEDIDO = d1.ID_PEDIDO, @ID_DETALLE_PEDIDO = d1.ID_DETALLE_PEDIDO , @ID_STOCK_MEDICAMENTO = s.ID_STOCK FROM deleted d1 join STOCKS s on d1.ID_MEDICAMENTO_LOTE = s.ID_MEDICAMENTO_LOTE
						join PEDIDOS f on f.ID_PEDIDO = d1.ID_PEDIDO
						join PERSONAL_CARGOS_ESTABLECIMIENTOS p on p.ID_PERSONAL_CARGOS_ESTABLECIMIENTOS = f.ID_PERSONAL_CARGOS_ESTABLECIMIENTOS
						join ESTABLECIMIENTOS e on p.ID_ESTABLECIMIENTO = e.ID_ESTABLECIMIENTO
						where p.ID_ESTABLECIMIENTO = s.ID_ESTABLECIMIENTO
							AND	S.ID_STOCK = (SELECT TOP 1 ID_STOCK FROM STOCKS
												WHERE ID_MEDICAMENTO_LOTE = d1.ID_MEDICAMENTO_LOTE AND ID_ESTABLECIMIENTO = p.ID_ESTABLECIMIENTO
												ORDER BY FECHA DESC)

			DELETE FROM INVENTARIOS
			WHERE ID_PEDIDO = @ID_PEDIDO AND ID_DETALLE_PEDIDO = @ID_DETALLE_PEDIDO

			DELETE FROM DETALLES_PEDIDOS
			WHERE ID_PEDIDO = @ID_PEDIDO AND ID_DETALLE_PEDIDO = @ID_DETALLE_PEDIDO

			UPDATE STOCKS
			SET CANTIDAD = CANTIDAD - @CANTIDAD
			WHERE ID_STOCK = @ID_STOCK_MEDICAMENTO
		END

	ELSE
		BEGIN

			SELECT @ID_PEDIDO = d1.ID_PEDIDO, @ID_DETALLE_PEDIDO = d1.ID_DETALLE_PEDIDO , @ID_STOCK_PRODUCTO = s.ID_STOCK FROM deleted d1 join STOCKS s on d1.ID_PRODUCTO = s.ID_PRODUCTO
							join PEDIDOS f on f.ID_PEDIDO = d1.ID_PEDIDO
							join PERSONAL_CARGOS_ESTABLECIMIENTOS p on p.ID_PERSONAL_CARGOS_ESTABLECIMIENTOS = f.ID_PERSONAL_CARGOS_ESTABLECIMIENTOS
							join ESTABLECIMIENTOS e on p.ID_ESTABLECIMIENTO = e.ID_ESTABLECIMIENTO
							where p.ID_ESTABLECIMIENTO = s.ID_ESTABLECIMIENTO
								AND	S.ID_STOCK = (SELECT TOP 1 ID_STOCK FROM STOCKS
												WHERE ID_PRODUCTO = d1.ID_PRODUCTO AND ID_ESTABLECIMIENTO = p.ID_ESTABLECIMIENTO
												ORDER BY FECHA DESC)

			DELETE FROM INVENTARIOS
			WHERE ID_PEDIDO = @ID_PEDIDO AND ID_DETALLE_PEDIDO = @ID_DETALLE_PEDIDO

			DELETE FROM DETALLES_PEDIDOS
			WHERE ID_PEDIDO = @ID_PEDIDO AND ID_DETALLE_PEDIDO = @ID_DETALLE_PEDIDO

			UPDATE STOCKS
			SET CANTIDAD = CANTIDAD - @CANTIDAD
			WHERE ID_STOCK = @ID_STOCK_PRODUCTO
		END
END


