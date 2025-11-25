use db20222000041

select * from Proveedores
select * from Productos
select * from Inventario
select * from OrdenesCompra
select * from Ventas
select * from Pagos
select * from Clientes

UPDATE Proveedores SET SaldoActual = 500.00, Nombre = 'Proveedor A (Activo)' WHERE ProveedorID = 1;
UPDATE Proveedores SET SaldoActual = 1200.75, Nombre = 'Proveedor B (Activo)' WHERE ProveedorID = 2;
UPDATE Proveedores SET SaldoActual = -200.00, Nombre = 'Proveedor C (Activo)' WHERE ProveedorID = 3; -- Saldo negativo de ejemplo
UPDATE Proveedores SET Nombre = 'Proveedor D (Sin Saldo)' WHERE ProveedorID = 4;

INSERT INTO Proveedores (Nombre, Contacto, Telefono, Email, LimiteCredito, SaldoActual, CreatedAt)
VALUES
('Proveedor E (Nuevo Activo)', 'Carlos Ruiz', '98765432', 'carlos@e.com', 2000.00, 300.00, GETDATE()),
('Proveedor F (Nuevo)', 'Luisa Gómez', '11223344', 'luisa@f.com', 800.00, 0.00, GETDATE());

INSERT INTO Clientes (Nombre, Documento, Telefono, Email, IsMayorista, SaldoActual, CreatedAt)
VALUES
('Cliente Particular 1', '1234567-8', '55511122', 'cliente1@mail.com', 0, 0.00, GETDATE()),
('Cliente Mayorista A', '9876543-2', '55533344', 'mayoristaA@mail.com', 1, 0.00, GETDATE());

INSERT INTO Categorias (Nombre, Descripcion)
VALUES
('Medicamentos', 'Productos farmacéuticos para la salud'),
('Equipos Médicos', 'Instrumentos y aparatos para uso médico');

UPDATE Productos SET CategoriaID = 1 WHERE Nombre LIKE '%Paracetamol%';
UPDATE Productos SET CategoriaID = 1 WHERE Nombre LIKE '%Amoxicilina%';
UPDATE Productos SET CategoriaID = 1 WHERE Nombre LIKE '%Ibuprofeno%';
UPDATE Productos SET CategoriaID = 1 WHERE Nombre LIKE '%Vitamina C%';
UPDATE Productos SET CategoriaID = 2 WHERE Nombre LIKE '%Jeringas%';

INSERT INTO Productos (CategoriaID, Codigo, Nombre, Precio, Minimo, ControlVencimiento, Activo, CreatedAt)
VALUES (1, 'MED005', 'Aspirina 100mg', 0.50, 60, 0, 1, GETDATE());

INSERT INTO Inventario (ProductoID, Ubicacion, Cantidad, Lote, FechaVencimiento, LastUpdated)
VALUES
(1, 'PRINCIPAL', 100, 'LOTE202501', '2025-12-31', GETDATE()), -- Paracetamol 500mg
(2, 'SECUNDARIA', 50, 'LOTE202502', '2025-11-30', GETDATE()), -- Amoxicilina 500mg
(3, 'PRINCIPAL', 200, 'LOTE202601', '2026-06-30', GETDATE()), -- Ibuprofeno 400mg
(1, 'TIENDA1', 30, 'LOTE202501', '2025-12-31', GETDATE()); -- Paracetamol también en TIENDA1

UPDATE OrdenesCompra SET Total = 1500.00 WHERE OrdenCompraID = 1007;

UPDATE OrdenesCompra SET Total = 250.00 WHERE OrdenCompraID = 1;
UPDATE OrdenesCompra SET Total = 500.00 WHERE OrdenCompraID = 2;
UPDATE OrdenesCompra SET Total = 120.00, Estado = 'RECIBIDA' WHERE OrdenCompraID = 3; -- Una orden recibida
UPDATE OrdenesCompra SET Total = 300.00, Estado = 'CANCELADA' WHERE OrdenCompraID = 4; -- Una orden cancelada

INSERT INTO OrdenesCompra (ProveedorID, Fecha, Total, Estado, CreatedBy)
VALUES
(1, GETDATE(), 800.00, 'PENDIENTE', 'admin'),
(2, DATEADD(day, -5, GETDATE()), 1200.50, 'PENDIENTE', 'admin'),
(3, DATEADD(day, -10, GETDATE()), 350.25, 'RECIBIDA', 'user');

INSERT INTO Ventas (ClienteID, Fecha, Total, Tipo, Estado, CreatedBy)
VALUES
(1, DATEADD(day, -2, GETDATE()), 500.00, 'DETALLE', 'EMITIDA', 'vendedor1'), -- Venta al Cliente Particular 1
(1, DATEADD(day, -1, GETDATE()), 1200.50, 'DETALLE', 'EMITIDA', 'vendedor1'),
(2, GETDATE(), 3000.75, 'MAYORISTA', 'EMITIDA', 'vendedor2'); -- Venta al Cliente Mayorista A

INSERT INTO Pagos (ProveedorID, ClienteID, FechaPago, Monto, Metodo, Observacion)
VALUES
(1, NULL, DATEADD(day, -3, GETDATE()), 200.00, 'Transferencia', 'Pago parcial factura P123'), -- Pago a Proveedor A
(2, NULL, GETDATE(), 750.50, 'Cheque', 'Pago a Proveedor B'),
(NULL, 1, DATEADD(day, -1, GETDATE()), 100.00, 'Efectivo', 'Devolución efectivo a Cliente 1'); -- Un pago a cliente de ejemplo


-- Ejemplo para SQL Server
INSERT INTO OrdenesCompra(Fecha, ProveedorID, Total, Estado) VALUES
('2023-10-15', 1, 100.00, 'PENDIENTE'); -- Octubre
INSERT INTO OrdenesCompra (Fecha, ProveedorID, Total, Estado) VALUES
('2023-12-01', 2, 250.00, 'RECIBIDA');  -- Diciembre
INSERT INTO OrdenesCompra (Fecha, ProveedorID, Total, Estado) VALUES
('2024-01-05', 1, 300.00, 'PENDIENTE'); -- Enero del próximo año
INSERT INTO OrdenesCompra (Fecha, ProveedorID, Total, Estado) VALUES
('2023-11-22', 3, 50.00, 'CANCELADA'); -- Otra en Noviembre pero diferente día

-- Ejemplo para SQL Server
