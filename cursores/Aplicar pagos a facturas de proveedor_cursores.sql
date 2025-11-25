CREATE PROCEDURE usp_AplicarPagoProveedor
    @ProveedorID INT,
    @Monto DECIMAL(18,2)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @OrdenCompraID INT, @Saldo DECIMAL(18,2);

    DECLARE cur CURSOR FOR
        SELECT OrdenCompraID, Total - ISNULL(Pagado,0) AS SaldoPendiente
        FROM OrdenesCompra
        WHERE ProveedorID = @ProveedorID AND Estado = 'APROBADA'
        ORDER BY Fecha ASC;

    OPEN cur;
    FETCH NEXT FROM cur INTO @OrdenCompraID, @Saldo;

    WHILE @@FETCH_STATUS = 0 AND @Monto > 0
    BEGIN
        DECLARE @Aplicar DECIMAL(18,2) = CASE WHEN @Monto >= @Saldo THEN @Saldo ELSE @Monto END;

        INSERT INTO PagosProveedoresFacturas (OrdenCompraID, MontoAplicado)
        VALUES (@OrdenCompraID, @Aplicar);

        UPDATE OrdenesCompra
        SET Pagado = ISNULL(Pagado,0) + @Aplicar
        WHERE OrdenCompraID = @OrdenCompraID;

        SET @Monto = @Monto - @Aplicar;

        FETCH NEXT FROM cur INTO @OrdenCompraID, @Saldo;
    END

    CLOSE cur;
    DEALLOCATE cur;
END;
GO
