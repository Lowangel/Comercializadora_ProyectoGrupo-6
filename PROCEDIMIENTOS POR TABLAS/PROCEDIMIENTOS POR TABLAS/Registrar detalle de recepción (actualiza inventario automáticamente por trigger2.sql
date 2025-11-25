CREATE TRIGGER trg_ActualizarInventario_Recepcion
ON DetalleOrdenCompra
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT UPDATE(CantidadRecibida)
        RETURN;

    MERGE Inventario AS target
    USING (
        SELECT ProductoID, CantidadRecibida, Lote, FechaVencimiento
        FROM inserted
    ) AS source
    ON target.ProductoID = source.ProductoID AND target.Lote = source.Lote
    WHEN MATCHED THEN
        UPDATE SET 
            target.Cantidad = target.Cantidad + source.CantidadRecibida,
            target.FechaVencimiento = source.FechaVencimiento,
            target.LastUpdated = GETDATE()
    WHEN NOT MATCHED THEN
        INSERT (ProductoID, Cantidad, Lote, FechaVencimiento, LastUpdated)
        VALUES (source.ProductoID, source.CantidadRecibida, source.Lote, source.FechaVencimiento, GETDATE());
END
GO
