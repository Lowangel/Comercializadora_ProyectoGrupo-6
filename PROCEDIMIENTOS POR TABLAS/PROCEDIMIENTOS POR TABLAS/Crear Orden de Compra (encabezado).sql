use DB20222000041
GO

CREATE PROCEDURE usp_OrdenCompra_Insert
    @ProveedorID INT,
    @CreatedBy NVARCHAR(100),
    @NewOrdenCompraID INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO OrdenesCompra (ProveedorID, CreatedBy)
    VALUES (@ProveedorID, @CreatedBy);

    SET @NewOrdenCompraID = SCOPE_IDENTITY();

    SELECT @NewOrdenCompraID AS OrdenCompraID;
END
GO
