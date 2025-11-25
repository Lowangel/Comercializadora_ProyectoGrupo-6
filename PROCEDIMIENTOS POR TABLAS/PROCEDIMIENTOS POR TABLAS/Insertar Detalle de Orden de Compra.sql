use DB20222000041
GO

CREATE PROCEDURE usp_DetalleOrdenCompra_Insert
    @OrdenCompraID INT,
    @ProductoID INT,
    @CantidadSolicitada INT,
    @PrecioUnitario DECIMAL(18,2)
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO DetalleOrdenCompra (OrdenCompraID, ProductoID, CantidadSolicitada, PrecioUnitario)
    VALUES (@OrdenCompraID, @ProductoID, @CantidadSolicitada, @PrecioUnitario);

END
GO
