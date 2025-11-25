CREATE PROCEDURE usp_AsignarLotes_FIFO
    @VentaID INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @ProductoID INT, @Cantidad INT;

    DECLARE cur CURSOR FOR
        SELECT ProductoID, Cantidad
        FROM VentaDetalle
        WHERE VentaID = @VentaID;

    OPEN cur;
    FETCH NEXT FROM cur INTO @ProductoID, @Cantidad;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        DECLARE @Lote NVARCHAR(100), @Disponible INT;

        DECLARE curLotes CURSOR FOR
            SELECT Lote, Cantidad
            FROM Inventario
            WHERE ProductoID = @ProductoID AND Cantidad > 0
            ORDER BY FechaVencimiento ASC;

        OPEN curLotes;
        FETCH NEXT FROM curLotes INTO @Lote, @Disponible;

        WHILE @@FETCH_STATUS = 0 AND @Cantidad > 0
        BEGIN
            DECLARE @Usar INT = CASE WHEN @Disponible >= @Cantidad THEN @Cantidad ELSE @Disponible END;

            UPDATE Inventario
            SET Cantidad = Cantidad - @Usar
            WHERE ProductoID = @ProductoID AND Lote = @Lote;

            SET @Cantidad = @Cantidad - @Usar;

            FETCH NEXT FROM curLotes INTO @Lote, @Disponible;
        END

        CLOSE curLotes;
        DEALLOCATE curLotes;

        FETCH NEXT FROM cur INTO @ProductoID, @Cantidad;
    END

    CLOSE cur;
    DEALLOCATE cur;
END;
GO
