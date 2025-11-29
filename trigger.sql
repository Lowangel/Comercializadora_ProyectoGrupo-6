USE DB20222000041;
GO

IF OBJECT_ID('trg_AfterInsertUpdate_DetalleOrdenCompra_PagosAutomaticos', 'TR') IS NOT NULL
    DROP TRIGGER trg_AfterInsertUpdate_DetalleOrdenCompra_PagosAutomaticos;
GO

CREATE TRIGGER trg_AfterInsertUpdate_DetalleOrdenCompra_PagosAutomaticos
ON DetalleOrdenCompra
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @OrdenID INT, @ProveedorID INT, @MontoTotal DECIMAL(18,2), @Observacion NVARCHAR(500);

    -- Obtener órdenes afectadas
    ;WITH OrdenesAfectadas AS (
        SELECT DISTINCT OrdenCompraID FROM inserted
        UNION
        SELECT DISTINCT OrdenCompraID FROM deleted
    )
    SELECT OrdenCompraID INTO #OrdenesTmp FROM OrdenesAfectadas;

    DECLARE curOrden CURSOR LOCAL FAST_FORWARD FOR
        SELECT OrdenCompraID FROM #OrdenesTmp;

    OPEN curOrden;
    FETCH NEXT FROM curOrden INTO @OrdenID;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        -- Calcular monto total recibido
        SELECT @MontoTotal = SUM(ISNULL(CantidadRecibida,0) * ISNULL(PrecioUnitario,0))
        FROM DetalleOrdenCompra
        WHERE OrdenCompraID = @OrdenID;

        IF @MontoTotal IS NULL SET @MontoTotal = 0;

        -- Obtener proveedor de la orden
        SELECT @ProveedorID = ProveedorID FROM OrdenesCompra WHERE OrdenCompraID = @OrdenID;

        SET @Observacion = 'PagoAutomaticoRecepcion:OrdenCompraID=' + CAST(@OrdenID AS NVARCHAR(20));

        -- Insertar pago solo si el monto es mayor a 0 y no existe
        IF @MontoTotal > 0 AND NOT EXISTS (SELECT 1 FROM Pagos WHERE ProveedorID = @ProveedorID AND Observacion = @Observacion)
        BEGIN
            INSERT INTO Pagos (TipoTransaccion, ProveedorID, Monto, FechaPago, Observacion)
            VALUES (@OrdenID, @ProveedorID, @MontoTotal, GETDATE(), @Observacion);
        END

        FETCH NEXT FROM curOrden INTO @OrdenID;
    END

    CLOSE curOrden;
    DEALLOCATE curOrden;

    DROP TABLE IF EXISTS #OrdenesTmp;
END
GO
