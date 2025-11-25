-- 1. Inventario general
CREATE VIEW vw_Inventario AS
SELECT 
    i.InventarioID,
    p.Nombre AS Producto,
    i.Cantidad,
    i.Ubicacion,
    i.Lote,
    i.FechaVencimiento,
    i.LastUpdated
FROM Inventario i
INNER JOIN Productos p ON i.ProductoID = p.ProductoID;

-- 2. Productos bajo el mínimo
CREATE VIEW vw_ProductosBajoMinimo AS
SELECT p.ProductoID, p.Nombre, i.Cantidad, p.Minimo
FROM Productos p
INNER JOIN Inventario i ON p.ProductoID = i.ProductoID
WHERE i.Cantidad < p.Minimo;

-- 3. Saldos de proveedores
CREATE VIEW vw_SaldoProveedores AS
SELECT pr.ProveedorID, pr.Nombre, pr.LimiteCredito,
       SUM(oc.Total) - SUM(ISNULL(pg.Monto,0)) AS Saldo
FROM Proveedores pr
LEFT JOIN OrdenesCompra oc ON pr.ProveedorID = oc.ProveedorID
LEFT JOIN PagosProveedores pg ON pr.ProveedorID = pg.ProveedorID
GROUP BY pr.ProveedorID, pr.Nombre, pr.LimiteCredito;

-- 4. Saldos de clientes
CREATE VIEW vw_SaldoClientes AS
SELECT c.ClienteID, c.Nombre,
       SUM(v.Total) - SUM(ISNULL(cb.Monto,0)) AS Saldo
FROM Clientes c
LEFT JOIN Ventas v ON c.ClienteID = v.ClienteID
LEFT JOIN Cobros cb ON c.ClienteID = cb.ClienteID
GROUP BY c.ClienteID, c.Nombre;

-- 5. Productos próximos a vencer
CREATE VIEW vw_ProductosPorVencer AS
SELECT p.Nombre, i.Lote, i.FechaVencimiento, i.Cantidad
FROM Inventario i
INNER JOIN Productos p ON i.ProductoID = p.ProductoID
WHERE i.FechaVencimiento < DATEADD(DAY,30,GETDATE());
