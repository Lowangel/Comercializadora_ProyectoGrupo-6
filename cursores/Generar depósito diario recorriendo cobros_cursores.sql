CREATE PROCEDURE usp_DepositoDiario_Generar
    @Fecha DATE
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @CobroID INT, @Monto DECIMAL(18,2), @Total DECIMAL(18,2) = 0;

    DECLARE cur CURSOR FOR
        SELECT CobroID, Monto
        FROM Cobros
        WHERE CAST(Fecha AS DATE) = @Fecha;

    OPEN cur;
    FETCH NEXT FROM cur INTO @CobroID, @Monto;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        SET @Total = @Total + @Monto;
        FETCH NEXT FROM cur INTO @CobroID, @Monto;
    END

    CLOSE cur;
    DEALLOCATE cur;

    IF EXISTS (SELECT 1 FROM Depositos WHERE Fecha=@Fecha)
        UPDATE Depositos SET MontoTotal = @Total WHERE Fecha=@Fecha;
    ELSE
        INSERT INTO Depositos(Fecha, MontoTotal) VALUES (@Fecha, @Total);
END;
GO
