-- Tipo de tabla (TVP) para detalles de venta
IF TYPE_ID('VentaDetalleType') IS NULL
    CREATE TYPE VentaDetalleType AS TABLE
    (
        ProductoID INT NOT NULL,
        Cantidad INT NOT NULL,
        PrecioUnitario DECIMAL(18,2) NOT NULL
    );
GO

-- Procedimiento corregido alineado a tus tablas (Ventas, DetalleVentas, Inventario, Clientes)
IF OBJECT_ID('dbo.usp_EmitirVenta','P') IS NOT NULL
    DROP PROCEDURE dbo.usp_EmitirVenta;
GO

CREATE PROCEDURE dbo.usp_EmitirVenta
    @ClienteID INT,
    @Detalles VentaDetalleType READONLY
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRAN;

        -- Crear cabecera de venta
        DECLARE @VentaID INT;
        INSERT INTO Ventas (ClienteID, Fecha, Estado, Total)
        VALUES (@ClienteID, GETDATE(), 'EMITIDA', 0);
        SET @VentaID = SCOPE_IDENTITY();

        -- Insertar detalles en DetalleVentas (nombre correcto según tu esquema)
        INSERT INTO DetalleVentas (VentaID, ProductoID, Cantidad, PrecioUnitario)
        SELECT @VentaID, ProductoID, Cantidad, PrecioUnitario
        FROM @Detalles;

        -- Validar stock antes de descontar
        IF EXISTS (
            SELECT 1
            FROM @Detalles d
            LEFT JOIN Inventario i ON i.ProductoID = d.ProductoID
            WHERE i.ProductoID IS NULL OR i.Cantidad < d.Cantidad
        )
        BEGIN
            RAISERROR('Stock insuficiente o producto sin inventario.',16,1);
            ROLLBACK TRAN;
            RETURN;
        END

        -- Descontar inventario
        UPDATE i
        SET i.Cantidad = i.Cantidad - d.Cantidad,
            i.LastUpdated = GETDATE()
        FROM Inventario i
        INNER JOIN @Detalles d ON i.ProductoID = d.ProductoID;

        -- Calcular y actualizar total de la venta
        UPDATE v
        SET v.Total = dv.SumTotal
        FROM Ventas v
        INNER JOIN (
            SELECT VentaID, SUM(Cantidad * PrecioUnitario) AS SumTotal
            FROM DetalleVentas
            WHERE VentaID = @VentaID
            GROUP BY VentaID
        ) dv ON dv.VentaID = v.VentaID
        WHERE v.VentaID = @VentaID;

        -- Validar saldo pendiente del cliente (si es contado estricto)
        DECLARE @Saldo DECIMAL(18,2);
        SELECT @Saldo = ISNULL(SaldoActual,0) FROM Clientes WHERE ClienteID = @ClienteID;

        IF @Saldo > 0
        BEGIN
            RAISERROR('Cliente con saldo pendiente.',16,1);
            ROLLBACK TRAN;
            RETURN;
        END

        COMMIT TRAN;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0 ROLLBACK TRAN;
        THROW;
    END CATCH
END;
GO
