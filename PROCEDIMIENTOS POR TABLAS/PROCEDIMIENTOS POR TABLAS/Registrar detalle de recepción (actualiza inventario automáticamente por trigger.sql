use DB20222000041
GO
CREATE PROCEDURE usp_RecepcionDetalle_Insert
    @OrdenCompraID INT,
    @ProductoID INT,
    @Cantidad INT,
    @Lote NVARCHAR(100) = NULL,
    @FechaVencimiento DATE = NULL
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE DetalleOrdenCompra
    SET CantidadRecibida = ISNULL(CantidadRecibida, 0) + @Cantidad,
        FechaVencimiento = @FechaVencimiento
    WHERE OrdenCompraID = @OrdenCompraID
      AND ProductoID = @ProductoID;

END
GO

