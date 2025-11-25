USE DB20222000041;
GO

-- 1. Crear el tipo de tabla (TVP) si no existe
IF TYPE_ID('RecepcionDetalleType') IS NULL
    CREATE TYPE RecepcionDetalleType AS TABLE
    (
        ProductoID INT NOT NULL,
        Cantidad INT NOT NULL,
        FechaVencimiento DATE NULL
    );
GO

-- 2. Crear la tabla de detalle de recepciones si no existe
IF OBJECT_ID('dbo.DetalleRecepcion','U') IS NULL
BEGIN
    CREATE TABLE dbo.DetalleRecepcion (
        DetalleRecepcionID INT IDENTITY(1,1) PRIMARY KEY,
        RecepcionID INT NOT NULL,
        ProductoID INT NOT NULL,
        Cantidad INT NOT NULL,
        FechaVencimiento DATE NULL,
        CONSTRAINT FK_DetalleRecepcion_Recepcion FOREIGN KEY (RecepcionID) REFERENCES Recepciones(RecepcionID),
        CONSTRAINT FK_DetalleRecepcion_Producto FOREIGN KEY (ProductoID) REFERENCES Productos(ProductoID)
    );
END
GO

-- 3. Crear el procedimiento
IF OBJECT_ID('dbo.usp_RegistrarRecepcion','P') IS NOT NULL
    DROP PROCEDURE dbo.usp_RegistrarRecepcion;
GO

CREATE PROCEDURE dbo.usp_RegistrarRecepcion
    @OrdenCompraID INT,
    @Usuario NVARCHAR(100),
    @Detalles RecepcionDetalleType READONLY
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRAN;

        DECLARE @RecepcionID INT;

        -- Insertar cabecera de recepción
        INSERT INTO Recepciones (OrdenCompraID, Usuario, Observaciones)
        VALUES (@OrdenCompraID, @Usuario, 'Recepción registrada');
        SET @RecepcionID = SCOPE_IDENTITY();

        -- Insertar detalles
        INSERT INTO DetalleRecepcion (RecepcionID, ProductoID, Cantidad, FechaVencimiento)
        SELECT @RecepcionID, ProductoID, Cantidad, FechaVencimiento
        FROM @Detalles;

        -- Actualizar estado de la orden
        UPDATE OrdenesCompra
        SET Estado = 'RECIBIDA'
        WHERE OrdenCompraID = @OrdenCompraID;

        COMMIT TRAN;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0 ROLLBACK TRAN;
        THROW;
    END CATCH
END;
GO
