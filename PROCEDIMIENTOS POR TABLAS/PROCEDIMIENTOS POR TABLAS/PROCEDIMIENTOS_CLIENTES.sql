USE DB20222000041
GO
CREATE PROCEDURE usp_Clientes_Insert
    @Nombre NVARCHAR(200),
    @Documento NVARCHAR(50) = NULL,
    @Telefono NVARCHAR(50) = NULL,
    @Email NVARCHAR(100) = NULL,
    @IsMayorista BIT = 0
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO Clientes (Nombre, Documento, Telefono, Email, IsMayorista)
    VALUES (@Nombre, @Documento, @Telefono, @Email, @IsMayorista);
    SELECT SCOPE_IDENTITY() AS NewClienteID;
END
GO

CREATE PROCEDURE usp_Clientes_Update
    @ClienteID INT,
    @Nombre NVARCHAR(200),
    @Documento NVARCHAR(50) = NULL,
    @Telefono NVARCHAR(50) = NULL,
    @Email NVARCHAR(100) = NULL,
    @IsMayorista BIT = 0
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE Clientes
    SET Nombre = @Nombre, Documento = @Documento, Telefono = @Telefono, Email = @Email, IsMayorista = @IsMayorista
    WHERE ClienteID = @ClienteID;
END
GO

CREATE PROCEDURE usp_Clientes_Delete
    @ClienteID INT
AS
BEGIN
    SET NOCOUNT ON;
    DELETE FROM Clientes WHERE ClienteID = @ClienteID;
END
GO

CREATE PROCEDURE usp_Clientes_GetById
    @ClienteID INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT * FROM Clientes WHERE ClienteID = @ClienteID;
END
GO

CREATE PROCEDURE usp_Clientes_GetAll
AS
BEGIN
    SET NOCOUNT ON;
    SELECT * FROM Clientes;
END
GO
