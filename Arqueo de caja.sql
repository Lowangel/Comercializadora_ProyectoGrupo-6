
IF OBJECT_ID('dbo.usp_MovimientosCaja_Insert', 'P') IS NOT NULL
    DROP PROCEDURE dbo.usp_MovimientosCaja_Insert;
GO

CREATE PROCEDURE dbo.usp_MovimientosCaja_Insert
    @FechaHora DATETIME,
    @TipoMovimiento NVARCHAR(10), 
    @Monto DECIMAL(18,2),
    @Descripcion NVARCHAR(500),
    @Origen NVARCHAR(50),      -- 'VENTA', 'PAGO_CLIENTE', 'GASTO', etc.
    @ReferenciaID INT = NULL,  -- Puede ser nulo
    @UsuarioID INT,
    @ArqueoID INT = NULL,      -- Puede ser nulo inicialmente
    @MovimientoID_Output INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO MovimientosCaja (FechaHora, TipoMovimiento, Monto, Descripcion, Origen, ReferenciaID, UsuarioID, ArqueoID)
    VALUES (@FechaHora, @TipoMovimiento, @Monto, @Descripcion, @Origen, @ReferenciaID, @UsuarioID, @ArqueoID);

    SET @MovimientoID_Output = SCOPE_IDENTITY();
END;
GO


IF OBJECT_ID('dbo.usp_ArqueosCaja_Insert', 'P') IS NOT NULL
    DROP PROCEDURE dbo.usp_ArqueosCaja_Insert;
GO

CREATE PROCEDURE dbo.usp_ArqueosCaja_Insert
    @FechaArqueo DATE,
    @SaldoInicial DECIMAL(18,2),
    @TotalEntradas DECIMAL(18,2),
    @TotalSalidas DECIMAL(18,2),
    @SaldoFinalTeorico DECIMAL(18,2),
    @MontoContado DECIMAL(18,2),
    @Diferencia DECIMAL(18,2),
    @CerradoPorUsuarioID INT,
    @FechaCierre DATETIME,
    @Observaciones NVARCHAR(1000) = NULL,
    @ArqueoID_Output INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO ArqueosCaja (FechaArqueo, SaldoInicial, TotalEntradas, TotalSalidas, SaldoFinalTeorico, MontoContado, Diferencia, CerradoPorUsuarioID, FechaCierre, Observaciones)
    VALUES (@FechaArqueo, @SaldoInicial, @TotalEntradas, @TotalSalidas, @SaldoFinalTeorico, @MontoContado, @Diferencia, @CerradoPorUsuarioID, @FechaCierre, @Observaciones);

    SET @ArqueoID_Output = SCOPE_IDENTITY();
END;
GO


IF OBJECT_ID('dbo.usp_MovimientosCaja_VincularAArqueo', 'P') IS NOT NULL
    DROP PROCEDURE dbo.usp_MovimientosCaja_VincularAArqueo;
GO

CREATE PROCEDURE dbo.usp_MovimientosCaja_VincularAArqueo
    @Fecha DATE,
    @ArqueoID INT
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE MovimientosCaja
    SET ArqueoID = @ArqueoID
    WHERE CAST(FechaHora AS DATE) = @Fecha
      AND ArqueoID IS NULL; -- Solo movimientos aún no vinculados a un arqueo
END;
GO


IF OBJECT_ID('dbo.usp_MovimientosCaja_Insert', 'P') IS NOT NULL
    DROP PROCEDURE dbo.usp_MovimientosCaja_Insert;
GO

CREATE PROCEDURE dbo.usp_MovimientosCaja_Insert
    @FechaHora DATETIME,
    @TipoMovimiento NVARCHAR(10), -- 'ENTRADA' o 'SALIDA'
    @Monto DECIMAL(18,2),
    @Descripcion NVARCHAR(500),
    @Origen NVARCHAR(50),      -- 'VENTA', 'PAGO_CLIENTE', 'GASTO', etc.
    @ReferenciaID INT = NULL,  -- Puede ser nulo, ej. ID de venta o pago
    @UsuarioID INT,
    @ArqueoID INT = NULL,      -- Puede ser nulo inicialmente
    @MovimientoID_Output INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO MovimientosCaja (FechaHora, TipoMovimiento, Monto, Descripcion, Origen, ReferenciaID, UsuarioID, ArqueoID)
    VALUES (@FechaHora, @TipoMovimiento, @Monto, @Descripcion, @Origen, @ReferenciaID, @UsuarioID, @ArqueoID);

    SET @MovimientoID_Output = SCOPE_IDENTITY();
END;
GO

IF OBJECT_ID('dbo.usp_ArqueosCaja_Insert', 'P') IS NOT NULL
    DROP PROCEDURE dbo.usp_ArqueosCaja_Insert;
GO

CREATE PROCEDURE dbo.usp_ArqueosCaja_Insert
    @FechaArqueo DATE,
    @SaldoInicial DECIMAL(18,2),
    @TotalEntradas DECIMAL(18,2),
    @TotalSalidas DECIMAL(18,2),
    @SaldoFinalTeorico DECIMAL(18,2),
    @MontoContado DECIMAL(18,2),
    @Diferencia DECIMAL(18,2),
    @CerradoPorUsuarioID INT,
    @FechaCierre DATETIME,
    @Observaciones NVARCHAR(1000) = NULL,
    @ArqueoID_Output INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO ArqueosCaja (FechaArqueo, SaldoInicial, TotalEntradas, TotalSalidas, SaldoFinalTeorico, MontoContado, Diferencia, CerradoPorUsuarioID, FechaCierre, Observaciones)
    VALUES (@FechaArqueo, @SaldoInicial, @TotalEntradas, @TotalSalidas, @SaldoFinalTeorico, @MontoContado, @Diferencia, @CerradoPorUsuarioID, @FechaCierre, @Observaciones);

    SET @ArqueoID_Output = SCOPE_IDENTITY();
END;
GO


IF OBJECT_ID('dbo.usp_MovimientosCaja_VincularAArqueo', 'P') IS NOT NULL
    DROP PROCEDURE dbo.usp_MovimientosCaja_VincularAArqueo;
GO

CREATE PROCEDURE dbo.usp_MovimientosCaja_VincularAArqueo
    @Fecha DATE,
    @ArqueoID INT
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE MovimientosCaja
    SET ArqueoID = @ArqueoID
    WHERE CAST(FechaHora AS DATE) = @Fecha
      AND ArqueoID IS NULL; -- Solo movimientos aún no vinculados a un arqueo
END;
GO

IF OBJECT_ID('dbo.usp_RealizarArqueoDiario', 'P') IS NOT NULL
    DROP PROCEDURE dbo.usp_RealizarArqueoDiario;
GO

CREATE PROCEDURE dbo.usp_RealizarArqueoDiario
    @FechaArqueo DATE,
    @MontoContado DECIMAL(18,2),
    @CerradoPorUsuarioID INT,
    @Observaciones NVARCHAR(1000) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @SaldoInicialDia DECIMAL(18,2);
    DECLARE @TotalEntradasDia DECIMAL(18,2);
    DECLARE @TotalSalidasDia DECIMAL(18,2);
    DECLARE @SaldoFinalTeoricoDia DECIMAL(18,2);
    DECLARE @DiferenciaDia DECIMAL(18,2);
    DECLARE @NuevoArqueoID INT;

    BEGIN TRY
        BEGIN TRAN;
        SELECT @SaldoInicialDia = ISNULL(
            (SELECT TOP 1 MontoContado
             FROM ArqueosCaja
             WHERE FechaArqueo < @FechaArqueo
             ORDER BY FechaArqueo DESC),
            0.00
        );

        SELECT @TotalEntradasDia = ISNULL(SUM(Monto), 0)
        FROM MovimientosCaja
        WHERE CAST(FechaHora AS DATE) = @FechaArqueo
          AND TipoMovimiento = 'ENTRADA'
          AND ArqueoID IS NULL;
          
        SELECT @TotalSalidasDia = ISNULL(SUM(Monto), 0)
        FROM MovimientosCaja
        WHERE CAST(FechaHora AS DATE) = @FechaArqueo
          AND TipoMovimiento = 'SALIDA'
          AND ArqueoID IS NULL;

        SET @SaldoFinalTeoricoDia = @SaldoInicialDia + @TotalEntradasDia - @TotalSalidasDia;

        SET @DiferenciaDia = @MontoContado - @SaldoFinalTeoricoDia;
        INSERT INTO ArqueosCaja (
            FechaArqueo, SaldoInicial, TotalEntradas, TotalSalidas, SaldoFinalTeorico,
            MontoContado, Diferencia, CerradoPorUsuarioID, FechaCierre, Observaciones
        )
        VALUES (
            @FechaArqueo, @SaldoInicialDia, @TotalEntradasDia, @TotalSalidasDia, @SaldoFinalTeoricoDia,
            @MontoContado, @DiferenciaDia, @CerradoPorUsuarioID, GETDATE(), @Observaciones
        );

        SET @NuevoArqueoID = SCOPE_IDENTITY(); -- Captura el ID del arqueo rec
        EXEC dbo.usp_MovimientosCaja_VincularAArqueo
            @Fecha = @FechaArqueo,
            @ArqueoID = @NuevoArqueoID;

        COMMIT TRAN;

        -- Devolvemos los datos calculados para información
        SELECT
            ArqueoID = @NuevoArqueoID,
            FechaArqueo = @FechaArqueo,
            SaldoInicial = @SaldoInicialDia,
            TotalEntradas = @TotalEntradasDia,
            TotalSalidas = @TotalSalidasDia,
            SaldoFinalTeorico = @SaldoFinalTeoricoDia,
            SaldoFinalReal = @MontoContado,
            Diferencia = @DiferenciaDia;

    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0 ROLLBACK TRAN;
        THROW; -- Re-lanza el error para que la aplicación cliente pueda manejarlo.
    END CATCH
END;
GO



-- Movimientos de entrada
INSERT INTO MovimientosCaja (FechaHora, TipoMovimiento, Monto, Descripcion, Origen, ReferenciaID, UsuarioID, ArqueoID)
VALUES
(GETDATE(), 'ENTRADA', 100.00, 'Venta X', 'VENTA', 101, 1, NULL),
(GETDATE(), 'ENTRADA', 50.00, 'Venta Y', 'VENTA', 102, 1, NULL),
(DATEADD(hour, 1, GETDATE()), 'ENTRADA', 20.00, 'Pago cliente Z', 'PAGO_CLIENTE', 201, 1, NULL);

-- Movimientos de salida
INSERT INTO MovimientosCaja (FechaHora, TipoMovimiento, Monto, Descripcion, Origen, ReferenciaID, UsuarioID, ArqueoID)
VALUES
(DATEADD(hour, 2, GETDATE()), 'SALIDA', 30.00, 'Compra insumos', 'GASTO', NULL, 1, NULL),
(DATEADD(hour, 3, GETDATE()), 'SALIDA', 15.00, 'Pago transporte', 'GASTO', NULL, 1, NULL);
DECLARE @FechaHoy DATE = GETDATE(); -- O la fecha para la que insertaste los movimientos
DECLARE @MontoContadoCajero DECIMAL(18,2) = 130.00; -- Asume que el cajero cuenta 130.00
DECLARE @UsuarioQueCierra INT = 1; -- ID del usuario que realiza el arqueo
DECLARE @ObservacionesArqueo NVARCHAR(1000) = 'Arqueo diario de prueba';

-- Ejecutar el procedimiento
EXEC dbo.usp_RealizarArqueoDiario
    @FechaArqueo = @FechaHoy,
    @MontoContado = @MontoContadoCajero,
    @CerradoPorUsuarioID = @UsuarioQueCierra,
    @Observaciones = @ObservacionesArqueo;

-- Opcional: Verificar los resultados directamente en las tablas
SELECT * FROM ArqueosCaja ORDER BY ArqueoID DESC;
SELECT * FROM MovimientosCaja WHERE CAST(FechaHora AS DATE) = @FechaHoy;

-- EJEMPLO: Insertar un arqueo anterior para probar el SaldoInicial
INSERT INTO ArqueosCaja (FechaArqueo, SaldoInicial, TotalEntradas, TotalSalidas, SaldoFinalTeorico, MontoContado, Diferencia, CerradoPorUsuarioID, FechaCierre, Observaciones)
VALUES ('2025-11-27', 0.00, 100.00, 50.00, 50.00, 50.00, 0.00, 1, GETDATE(), 'Arqueo día anterior');


-- Vuelve a ejecutar el arqueo para 2025-11-28
DELETE FROM ArqueosCaja WHERE FechaArqueo = '2025-11-28';
DECLARE @FechaHoy DATE = '2025-11-29'; -- O la fecha actual
DECLARE @MontoContadoCajero DECIMAL(18,2) = 130.00;
DECLARE @UsuarioQueCierra INT = 1;
DECLARE @ObservacionesArqueo NVARCHAR(1000) = 'Arqueo diario de prueba con saldo inicial.';

EXEC dbo.usp_RealizarArqueoDiario
    @FechaArqueo = @FechaHoy,
    @MontoContado = @MontoContadoCajero,
    @CerradoPorUsuarioID = @UsuarioQueCierra,
    @Observaciones = @ObservacionesArqueo;

