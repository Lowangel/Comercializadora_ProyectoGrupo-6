-- 1. Disponible de producto
CREATE FUNCTION fnDisponibleProducto(@ProductoID INT)
RETURNS INT
AS
BEGIN
    RETURN (SELECT Cantidad FROM Inventario WHERE ProductoID = @ProductoID);
END;

-- 2. Alerta de crédito proveedor
CREATE FUNCTION fnAlertaCreditoProveedor(@ProveedorID INT)
RETURNS BIT
AS
BEGIN
    DECLARE @Saldo DECIMAL(18,2), @Limite DECIMAL(18,2);
    SELECT @Saldo = SUM(Total) FROM OrdenesCompra WHERE ProveedorID=@ProveedorID;
    SELECT @Limite = LimiteCredito FROM Proveedores WHERE ProveedorID=@ProveedorID;
    RETURN CASE WHEN @Saldo > @Limite THEN 1 ELSE 0 END;
END;

-- 3. Días para vencer lote
CREATE FUNCTION fnDiasParaVencer(@InventarioID INT)
RETURNS INT
AS
BEGIN
    RETURN (SELECT DATEDIFF(DAY,GETDATE(),FechaVencimiento) FROM Inventario WHERE InventarioID=@InventarioID);
END;

-- 4. Precio de venta según cliente
CREATE FUNCTION fnPrecioVenta(@ProductoID INT,@IsMayorista BIT)
RETURNS DECIMAL(18,2)
AS
BEGIN
    DECLARE @Precio DECIMAL(18,2);
    SELECT @Precio = Precio FROM Productos WHERE ProductoID=@ProductoID;
    RETURN CASE WHEN @IsMayorista=1 THEN @Precio*0.9 ELSE @Precio END;
END;

-- 5. Mes contable
CREATE FUNCTION fnMesContable(@Fecha DATE)
RETURNS NVARCHAR(7)
AS
BEGIN
    RETURN FORMAT(@Fecha,'yyyy-MM');
END;
