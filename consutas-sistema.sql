/*1. Consulta: Saldo Proveedores*/

-- Utiliza la vista existente que calcula:
-- (Suma de Órdenes de Compra) - (Suma de Pagos registrados en la tabla Pagos)
SELECT 
    ProveedorID,
    Nombre AS Proveedor,
    LimiteCredito,
    Saldo AS SaldoPendiente
FROM 
    vw_SaldoProveedores
ORDER BY 
    Nombre ASC;

/*Consulta: Existencias por Bodega*/
SELECT 
    ISNULL(i.Ubicacion, 'Sin Ubicación Asignada') AS Bodega,
    p.Codigo,
    p.Nombre AS Producto,
    SUM(i.Cantidad) AS ExistenciaTotal
FROM 
    Inventario i
INNER JOIN 
    Productos p ON i.ProductoID = p.ProductoID
GROUP BY 
    i.Ubicacion,
    p.Codigo,
    p.Nombre
ORDER BY 
    Bodega, p.Nombre;

/*Consulta: Órdenes Recibidas / Pendientes*/
/*Opción A: Resumen por cantidad*/
SELECT 
    ISNULL(Estado, 'Desconocido') AS EstadoOrden,
    COUNT(OrdenCompraID) AS CantidadOrdenes,
    SUM(Total) AS MontoTotal
FROM 
    OrdenesCompra
GROUP BY 
    Estado
ORDER BY 
    Estado;
-- Interpretación según tus procesos:
-- 'RECIBIDA' = Recibidas
-- 'APROBADA' o NULL = Pendientes de recibir

/*Opción B: Detalle de órdenes pendientes (Ejemplo)*/
-- Muestra las órdenes que no han sido marcadas como RECIBIDA
SELECT 
    oc.OrdenCompraID,
    pr.Nombre AS Proveedor,
    oc.Fecha,
    oc.Total,
    ISNULL(oc.Estado, 'PENDIENTE') AS Estado
FROM 
    OrdenesCompra oc
INNER JOIN
    Proveedores pr ON oc.ProveedorID = pr.ProveedorID
WHERE 
    ISNULL(oc.Estado, '') <> 'RECIBIDA'
ORDER BY 
    oc.Fecha DESC;

/*Consulta: Movimientos x Día (Ventas / Pagos)*/

-- Movimientos de Ventas y Pagos/Cobros por Día
SELECT 
    CAST(FechaMovimiento AS DATE) AS Fecha,
    TipoMovimiento,
    SUM(Monto) AS MontoTotalDiario
FROM (
    -- Ventas del día (Ingresos)
    SELECT 
        Fecha AS FechaMovimiento,
        'VENTA' AS TipoMovimiento,
        Total AS Monto
    FROM 
        Ventas
    WHERE 
        Estado <> 'ANULADA' -- Excluir ventas anuladas

    UNION ALL

    -- Pagos a Proveedores del día (Egresos)
    SELECT 
        FechaPago AS FechaMovimiento,
        'PAGO PROVEEDOR' AS TipoMovimiento,
        Monto * -1 AS Monto -- Se multiplica por -1 para representar un egreso
    FROM 
        Pagos
    WHERE 
        ProveedorID IS NOT NULL -- Filtra solo los pagos a proveedores

    UNION ALL

    -- Cobros de Clientes del día (Ingresos)
    SELECT 
        FechaPago AS FechaMovimiento,
        'COBRO CLIENTE' AS TipoMovimiento,
        Monto AS Monto
    FROM 
        Pagos
    WHERE 
        ClienteID IS NOT NULL -- Filtra solo los cobros de clientes
) AS MovimientosDiarios
GROUP BY 
    CAST(FechaMovimiento AS DATE), TipoMovimiento
ORDER BY 
    Fecha, TipoMovimiento;

/*Consulta: Saldo Cuentas Bancarias*/

SELECT 
    -- Total de dinero entrado por Cobros de Clientes
    (SELECT ISNULL(SUM(Monto), 0) FROM Pagos WHERE ClienteID IS NOT NULL) 
    AS TotalIngresosPorCobrosClientes,

    -- Total de dinero salido por Pagos a Proveedores
    (SELECT ISNULL(SUM(Monto), 0) FROM Pagos WHERE ProveedorID IS NOT NULL) 
    AS TotalEgresosPorPagosProveedores,

    -- Saldo Neto Teórico de Flujo de Efectivo
    (
        (SELECT ISNULL(SUM(Monto), 0) FROM Pagos WHERE ClienteID IS NOT NULL)
        -
        (SELECT ISNULL(SUM(Monto), 0) FROM Pagos WHERE ProveedorID IS NOT NULL)
    ) AS SaldoNetoTeoricoActual;


    select * from Pagos