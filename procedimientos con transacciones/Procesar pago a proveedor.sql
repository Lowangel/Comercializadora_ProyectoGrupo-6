-- Tabla de aplicaciones de pago a órdenes (nueva, si la aceptas)
IF OBJECT_ID('dbo.PagosOrdenCompra','U') IS NULL
BEGIN
    CREATE TABLE dbo.PagosOrdenCompra (
        PagoOrdenID INT IDENTITY(1,1) PRIMARY KEY,
        OrdenCompraID INT NOT NULL,
        ProveedorID INT NOT NULL,
        MontoAplicado DECIMAL(18,2) NOT NULL,
        FechaAplicacion DATETIME NOT NULL DEFAULT GETDATE(),
        CONSTRAINT FK_PagosOrdenCompra_OrdenesCompra FOREIGN KEY (OrdenCompraID) REFERENCES OrdenesCompra(OrdenCompraID),
        CONSTRAINT FK_PagosOrdenCompra_Proveedores FOREIGN KEY (ProveedorID) REFERENCES Proveedores(ProveedorID)
    );
END
GO

-- Tipo de tabla para aplicaciones por factura
IF TYPE_ID('PagoFacturaType') IS NULL
    CREATE TYPE PagoFacturaType AS TABLE
    (
        OrdenCompraID INT NOT NULL,
        MontoAplicado DECIMAL(18,2) NOT NULL
    );
GO

IF OBJECT_ID('dbo.usp_PagoProveedor_Procesar','P') IS NOT NULL
    DROP PROCEDURE dbo.usp_PagoProveedor_Procesar;
GO

CREATE PROCEDURE dbo.usp_PagoProveedor_Procesar
    @ProveedorID INT,
    @Monto DECIMAL(18,2),
    @Facturas PagoFacturaType READONLY,       -- aplicaciones por orden
    @Metodo NVARCHAR(100) = NULL,
    @Observacion NVARCHAR(500) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRAN;

        -- Registrar pago global
        INSERT INTO Pagos (ProveedorID, FechaPago, Monto, Metodo, Observacion)
        VALUES (@ProveedorID, GETDATE(), @Monto, @Metodo, @Observacion);

        -- Registrar aplicaciones por orden (si se enviaron)
        INSERT INTO PagosOrdenCompra (OrdenCompraID, ProveedorID, MontoAplicado)
        SELECT f.OrdenCompraID, @ProveedorID, f.MontoAplicado
        FROM @Facturas f;

        -- Actualizar saldo del proveedor por el monto global
        UPDATE Proveedores
        SET SaldoActual = ISNULL(SaldoActual,0) - @Monto
        WHERE ProveedorID = @ProveedorID;

        COMMIT TRAN;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0 ROLLBACK TRAN;
        THROW;
    END CATCH
END;
GO
