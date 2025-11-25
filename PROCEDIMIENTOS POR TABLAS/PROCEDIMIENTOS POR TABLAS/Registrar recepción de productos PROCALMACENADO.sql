use DB20222000041
GO
CREATE PROCEDURE usp_Recepcion_Insert
    @OrdenCompraID INT,
    @Usuario NVARCHAR(100),
    @Observaciones NVARCHAR(1000),
    @NewRecepcionID INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO Recepciones (OrdenCompraID, Usuario, Observaciones)
    VALUES (@OrdenCompraID, @Usuario, @Observaciones);

    SET @NewRecepcionID = SCOPE_IDENTITY();

    SELECT @NewRecepcionID AS RecepcionID;
END
GO
