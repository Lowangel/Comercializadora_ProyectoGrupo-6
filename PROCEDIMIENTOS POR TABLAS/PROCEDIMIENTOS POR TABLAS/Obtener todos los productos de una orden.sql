use DB20222000041
GO

CREATE PROCEDURE usp_DetalleOrdenCompra_GetByOrden
    @OrdenCompraID INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        d.DetalleOrdenCompraID,
        d.ProductoID,
        p.Nombre,
        d.CantidadSolicitada,
        d.CantidadRecibida,
        d.PrecioUnitario,
        d.FechaVencimiento
    FROM DetalleOrdenCompra d
    INNER JOIN Productos p ON d.ProductoID = p.ProductoID
    WHERE d.OrdenCompraID = @OrdenCompraID;
END
GO

