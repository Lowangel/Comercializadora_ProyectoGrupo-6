-- 1. Estado de cuenta proveedor
CREATE FUNCTION fnEstadoCuentaProveedor(@ProveedorID INT)
RETURNS TABLE
AS
RETURN (
    SELECT 
        oc.OrdenCompraID,
        oc.Total AS MontoOrden,
        ISNULL(p.Monto,0) AS MontoPagado,
        oc.Fecha
    FROM OrdenesCompra oc
    LEFT JOIN Pagos p ON oc.ProveedorID = p.ProveedorID
    WHERE oc.ProveedorID = @ProveedorID
);

-- 2. Estado de cuenta cliente
CREATE FUNCTION fnEstadoCuentaCliente(@ClienteID INT)
RETURNS TABLE
AS
RETURN (
    SELECT 
        v.VentaID,
        v.Total AS MontoVenta,
        ISNULL(p.Monto,0) AS MontoPagado,
        v.Fecha
    FROM Ventas v
    LEFT JOIN Pagos p ON v.ClienteID = p.ClienteID
    WHERE v.ClienteID = @ClienteID
);

-- 3. Lotes disponibles
CREATE FUNCTION fnLotesDisponibles(@ProductoID INT)
RETURNS TABLE
AS
RETURN (
    SELECT 
        Lote,
        Cantidad,
        FechaVencimiento
    FROM Inventario
    WHERE ProductoID = @ProductoID AND Cantidad > 0
);

-- 4. Inventario por producto
CREATE FUNCTION fnInventarioProducto(@ProductoID INT)
RETURNS TABLE
AS
RETURN (
    SELECT 
        Lote,
        Cantidad,
        FechaVencimiento
    FROM Inventario
    WHERE ProductoID = @ProductoID
);

-- 5. Productos por vencer
CREATE FUNCTION fnProductosPorVencer(@Dias INT)
RETURNS TABLE
AS
RETURN (
    SELECT 
        ProductoID,
        Lote,
        Cantidad,
        FechaVencimiento
    FROM Inventario
    WHERE FechaVencimiento IS NOT NULL
      AND FechaVencimiento < DATEADD(DAY,@Dias,GETDATE())
);
