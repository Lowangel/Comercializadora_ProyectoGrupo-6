use DB20222000041
GO

CREATE PROCEDURE usp_OrdenesCompra_GetAll
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        oc.OrdenCompraID,
        p.Nombre AS Proveedor,
        oc.Fecha,
        oc.Total,
        oc.Estado,
        oc.CreatedBy
    FROM OrdenesCompra oc
    INNER JOIN Proveedores p ON oc.ProveedorID = p.ProveedorID
    ORDER BY oc.OrdenCompraID DESC;
END
GO

