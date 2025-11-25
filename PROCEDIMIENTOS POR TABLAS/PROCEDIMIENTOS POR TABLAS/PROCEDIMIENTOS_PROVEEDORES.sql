USE DB20222000041
GO
-- usp_Proveedores_Insert
CREATE PROCEDURE usp_Proveedores_Insert
    @Nombre NVARCHAR(200),
    @Contacto NVARCHAR(100) = NULL,
    @Telefono NVARCHAR(50) = NULL,
    @Email NVARCHAR(100) = NULL,
    @LimiteCredito DECIMAL(18,2) = 0
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO Proveedores (Nombre, Contacto, Telefono, Email, LimiteCredito)
    VALUES (@Nombre, @Contacto, @Telefono, @Email, @LimiteCredito);
    SELECT SCOPE_IDENTITY() AS NewProveedorID;
END
GO

-- usp_Proveedores_Update
CREATE PROCEDURE usp_Proveedores_Update
    @ProveedorID INT,
    @Nombre NVARCHAR(200),
    @Contacto NVARCHAR(100) = NULL,
    @Telefono NVARCHAR(50) = NULL,
    @Email NVARCHAR(100) = NULL,
    @LimiteCredito DECIMAL(18,2) = 0
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE Proveedores
    SET Nombre = @Nombre,
        Contacto = @Contacto,
        Telefono = @Telefono,
        Email = @Email,
        LimiteCredito = @LimiteCredito
    WHERE ProveedorID = @ProveedorID;
END
GO

-- usp_Proveedores_Delete
CREATE PROCEDURE usp_Proveedores_Delete
    @ProveedorID INT
AS
BEGIN
    SET NOCOUNT ON;
    DELETE FROM Proveedores WHERE ProveedorID = @ProveedorID;
END
GO

-- usp_Proveedores_GetById
CREATE PROCEDURE usp_Proveedores_GetById
    @ProveedorID INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT * FROM Proveedores WHERE ProveedorID = @ProveedorID;
END
GO

-- usp_Proveedores_GetAll
CREATE PROCEDURE usp_Proveedores_GetAll
AS
BEGIN
    SET NOCOUNT ON;
    SELECT * FROM Proveedores;
END
GO
