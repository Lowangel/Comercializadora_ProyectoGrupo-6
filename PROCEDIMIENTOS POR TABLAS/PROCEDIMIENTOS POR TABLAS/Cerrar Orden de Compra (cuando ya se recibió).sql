use DB20222000041
GO

CREATE PROCEDURE usp_OrdenCompra_Cerrar
    @OrdenCompraID INT
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE OrdenesCompra
    SET Estado = 'RECIBIDA'
    WHERE OrdenCompraID = @OrdenCompraID;
END
GO


