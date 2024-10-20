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

