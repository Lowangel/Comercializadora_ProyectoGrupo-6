USE DB20222000041
GO
SELECT *FROM DetalleOrdenCompra;
CREATE TYPE RecepcionDetalleType AS TABLE
(
    ProductoID INT,
    Cantidad INT,
    FechaVencimiento DATE NULL
);
GO
GO
CREATE PROCEDURE usp_RegistrarRecepcionINV
    @OrdenCompraID INT,
    @Usuario NVARCHAR(50),
    @Detalles RecepcionDetalleType READONLY
AS
BEGIN
    SET NOCOUNT ON;


    INSERT INTO Recepciones (OrdenCompraID, Usuario)
    VALUES (@OrdenCompraID, @Usuario);

    DECLARE @RecepcionID INT = SCOPE_IDENTITY();

    UPDATE d
    SET 
        d.CantidadRecibida = t.Cantidad,
        d.FechaVencimiento = t.FechaVencimiento
    FROM DetalleOrdenCompra d
    INNER JOIN @Detalles t ON d.ProductoID = t.ProductoID
    WHERE d.OrdenCompraID = @OrdenCompraID;


    MERGE Inventario AS inv
    USING @Detalles AS det
        ON inv.ProductoID = det.ProductoID
    WHEN MATCHED THEN
        UPDATE SET 
            inv.Cantidad = inv.Cantidad + det.Cantidad,
            inv.FechaVencimiento = det.FechaVencimiento,
            inv.LastUpdated = GETDATE()
    WHEN NOT MATCHED THEN
        INSERT (ProductoID, Cantidad, FechaVencimiento)
        VALUES (det.ProductoID, det.Cantidad, det.FechaVencimiento);

    IF NOT EXISTS (
        SELECT 1 FROM DetalleOrdenCompra
        WHERE OrdenCompraID = @OrdenCompraID
        AND (CantidadRecibida IS NULL OR CantidadRecibida < CantidadSolicitada)
    )
    BEGIN
        UPDATE OrdenesCompra
        SET Estado = 'RECIBIDA'
        WHERE OrdenCompraID = @OrdenCompraID;
    END
END
GO

