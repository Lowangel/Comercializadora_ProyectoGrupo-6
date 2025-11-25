-- 1. Validar crédito al aprobar orden de compra
IF OBJECT_ID('trg_OrdenCompra_Aprobada_Credito','TR') IS NOT NULL
    DROP TRIGGER trg_OrdenCompra_Aprobada_Credito;
GO

CREATE TRIGGER trg_OrdenCompra_Aprobada_Credito
ON OrdenesCompra
AFTER UPDATE
AS
BEGIN
    IF UPDATE(Estado)
    BEGIN
        DECLARE @ProveedorID INT, @Estado NVARCHAR(50);
        SELECT @ProveedorID = ProveedorID, @Estado = Estado FROM inserted;
        IF @Estado = 'APROBADA' AND dbo.fnAlertaCreditoProveedor(@ProveedorID) = 1
        BEGIN
            RAISERROR('Proveedor excede límite de crédito',16,1);
            ROLLBACK TRANSACTION;
        END
    END
END;
GO

-- 2. Actualizar inventario al recibir productos
IF OBJECT_ID('trg_RecepcionDetalle_Update','TR') IS NOT NULL
    DROP TRIGGER trg_RecepcionDetalle_Update;
GO

CREATE TRIGGER trg_RecepcionDetalle_Update
ON DetalleOrdenCompra
AFTER UPDATE
AS
BEGIN
    IF UPDATE(CantidadRecibida)
    BEGIN
        INSERT INTO Inventario(ProductoID, Cantidad, LastUpdated)
        SELECT ProductoID, CantidadRecibida, GETDATE()
        FROM inserted;
    END
END;
GO

-- 3. Descontar inventario al vender
IF OBJECT_ID('trg_VentaDetalle_Insert','TR') IS NOT NULL
    DROP TRIGGER trg_VentaDetalle_Insert;
GO

CREATE TRIGGER trg_VentaDetalle_Insert
ON DetalleVentas
AFTER INSERT
AS
BEGIN
    UPDATE i
    SET i.Cantidad = i.Cantidad - ins.Cantidad
    FROM Inventario i
    INNER JOIN inserted ins ON i.ProductoID = ins.ProductoID;
END;
GO

-- 4. Restituir inventario al anular venta
IF OBJECT_ID('trg_Venta_Anulada','TR') IS NOT NULL
    DROP TRIGGER trg_Venta_Anulada;
GO

CREATE TRIGGER trg_Venta_Anulada
ON Ventas
AFTER UPDATE
AS
BEGIN
    IF UPDATE(Estado)
    BEGIN
        UPDATE i
        SET i.Cantidad = i.Cantidad + vd.Cantidad
        FROM Inventario i
        INNER JOIN DetalleVentas vd ON i.ProductoID = vd.ProductoID
        INNER JOIN inserted ins ON vd.VentaID = ins.VentaID
        WHERE ins.Estado = 'ANULADA';
    END
END;
GO

-- 5. Actualizar saldo proveedor al registrar pago
IF OBJECT_ID('trg_PagoProveedor_Insert','TR') IS NOT NULL
    DROP TRIGGER trg_PagoProveedor_Insert;
GO

CREATE TRIGGER trg_PagoProveedor_Insert
ON Pagos
AFTER INSERT
AS
BEGIN
    UPDATE p
    SET p.SaldoActual = p.SaldoActual - ins.Monto
    FROM Proveedores p
    INNER JOIN inserted ins ON p.ProveedorID = ins.ProveedorID;
END;
GO

-- 6. Actualizar saldo cliente al registrar cobro
IF OBJECT_ID('trg_CobroCliente_Insert','TR') IS NOT NULL
    DROP TRIGGER trg_CobroCliente_Insert;
GO

CREATE TRIGGER trg_CobroCliente_Insert
ON Pagos
AFTER INSERT
AS
BEGIN
    UPDATE c
    SET c.SaldoActual = c.SaldoActual - ins.Monto
    FROM Clientes c
    INNER JOIN inserted ins ON c.ClienteID = ins.ClienteID;
END;
GO

ALTER TABLE Productos ADD Existencias INT DEFAULT 0;

