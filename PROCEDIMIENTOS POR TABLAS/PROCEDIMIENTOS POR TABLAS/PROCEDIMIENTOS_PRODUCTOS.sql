USE DB20222000041
GO
CREATE PROCEDURE usp_Productos_Insert
    @CategoriaID INT = NULL,
    @Codigo NVARCHAR(50) = NULL,
    @Nombre NVARCHAR(250),
    @Precio DECIMAL(18,2),
    @Minimo INT = 0,
    @ControlVencimiento BIT = 0
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO Productos (CategoriaID, Codigo, Nombre, Precio, Minimo, ControlVencimiento)
    VALUES (@CategoriaID, @Codigo, @Nombre, @Precio, @Minimo, @ControlVencimiento);
    SELECT SCOPE_IDENTITY() AS NewProductoID;
END
GO

CREATE PROCEDURE usp_Productos_Update
    @ProductoID INT,
    @CategoriaID INT = NULL,
    @Codigo NVARCHAR(50) = NULL,
    @Nombre NVARCHAR(250),
    @Precio DECIMAL(18,2),
    @Minimo INT = 0,
    @ControlVencimiento BIT = 0,
    @Activo BIT = 1
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE Productos
    SET CategoriaID = @CategoriaID, Codigo = @Codigo, Nombre = @Nombre, Precio = @Precio, Minimo = @Minimo, ControlVencimiento = @ControlVencimiento, Activo = @Activo
    WHERE ProductoID = @ProductoID;
END
GO

CREATE PROCEDURE usp_Productos_Delete
    @ProductoID INT
AS
BEGIN
    SET NOCOUNT ON;
    DELETE FROM Productos WHERE ProductoID = @ProductoID;
END
GO

CREATE PROCEDURE usp_Productos_GetById
    @ProductoID INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT * FROM Productos WHERE ProductoID = @ProductoID;
END
GO

CREATE PROCEDURE usp_Productos_GetAll
AS
BEGIN
    SET NOCOUNT ON;
    SELECT * FROM Productos;
END
GO
