use DB20222000041
GO
INSERT INTO Proveedores (Nombre, Contacto, Telefono, Email, LimiteCredito)
VALUES ('Proveedor Prueba', 'Juan Pérez', '12345678', 'prueba@mail.com', 1000);
INSERT INTO Proveedores (Nombre, Contacto, Telefono, Email, LimiteCredito)
VALUES ('Proveedor Prueba', 'Juan Pérez', '12345678', 'prueba@mail.com', 1000);

EXEC usp_Proveedores_GetAll;

