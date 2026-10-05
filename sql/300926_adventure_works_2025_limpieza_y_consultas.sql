--Al ejecutar la línea permite que la consulta se ejecute con la db que le digo
USE [AdventureWorks2025];


--Desarrollo de scripts para explorar datos, filtrar registros incoherentes, validar nulos y validar calidad de datos antes de la creación de las vistas


--1) Products

--1. Cantidad de productos - 504
SELECT
	COUNT(ProductID) AS TotalProducts
FROM Production.Product;

--2. Top 10 productos con mayores ventas (Qty)
SELECT TOP (10)
	dp.ProductID,
	dp.ProductNumber,
	dp.NameProduct,
	SUM(fs.OrderQty) AS TotalQty
FROM view_fact_sales AS fs
INNER JOIN view_dim_product AS dp ON fs.ProductID = dp.ProductID
GROUP BY 
	dp.ProductID,
	dp.ProductNumber,
	dp.NameProduct
ORDER BY TotalQty DESC;

--3. limpieza de datos - INTEGRIDAD REFERENCIAL 
--a) ¿Qué productos están en lista productos y no en sales? 238 productos
SELECT
	vdp.ProductID
FROM view_dim_product AS vdp
LEFT JOIN view_fact_sales AS vfs ON vdp.ProductID = vfs.ProductID
WHERE vfs.ProductID IS NULL
ORDER BY vdp.ProductID ASC;

--b) ¿qué productos se venden y no están en la lista de productos? - ninguno, lo que tiene sentido
SELECT
	vdp.ProductID
FROM view_fact_sales AS vfs
LEFT JOIN view_dim_product AS vdp ON vfs.ProductID = vdp.ProductID
WHERE vdp.ProductID IS NULL;

--4. total de ventas 
--a)Con las vistas - 109.846.381,399888
SELECT SUM(fs.LineTotal) AS TotalSales
FROM view_fact_sales AS fs
LEFT JOIN view_dim_product AS dp ON fs.ProductID = dp.ProductID; 

--b)Con las tablas SalesOrderDetail y ProductionProduct - 109846381.399888
SELECT SUM(sod.LineTotal) AS TotalSales
FROM Production.Product AS p
LEFT JOIN Sales.SalesOrderDetail AS sod ON p.ProductID = sod.ProductID; 

--5. verificación de nulos
--a) productos con subcategoria vacía - 209 y con producto ID vacío - 0
SELECT *
FROM Production.Product
WHERE 
	ProductSubcategoryID IS NULL
	OR ProductID IS NULL;

--6. validación de productos sin subcategoría, por lo tanto sin categoría, además sin color y size
SELECT
	p.ProductID,
	p.ProductNumber,
	p.Color,
	p.Size,
	p.StandardCost,
	p.ListPrice
FROM Production.Product AS p
WHERE ProductSubcategoryID IS NULL;

--7. Cantidad de productos sin subcategoría
SELECT
	COUNT(*)
FROM Production.Product
WHERE ProductSubcategoryID IS NULL;


--2) Clientes

--1. cantidad de clientes con datos - 19119
SELECT
	count(CustomerID) AS TotalCustomer
FROM view_dim_customer;

--2. cantidad de clientes activos, es decir con compras = 19119 (todos)
SELECT 
	COUNT(DISTINCT(CustomerID)) AS TotalCustomer
FROM Sales.SalesOrderHeader;

--3. limpieza de datos - INTEGRIDAD REFERENCIAL
--a) primero SalesOrderHeader 
--¿Cuántos clientes activos, es decir con ventas, no están en la bd de clientes? 0
SELECT 
	COUNT(DISTINCT(soh.CustomerID))
FROM Sales.SalesOrderHeader AS soh 
LEFT JOIN view_dim_customer AS vdc ON soh.CustomerID = vdc.CustomerID
WHERE vdc.CustomerID IS NULL;

--b) primero view_dim_customer
--¿cuántos clientes de mi bd de clientes están inactivos, es decir que no tienen compras? 0
SELECT 
	COUNT(DISTINCT(vdc.CustomerID))
FROM view_dim_customer AS vdc 
LEFT JOIN Sales.SalesOrderHeader AS soh ON vdc.CustomerID = soh.CustomerID
WHERE soh.CustomerID IS NULL;

--4. calcular venta total clientes 
--a) con vistas - 109.846.381,399888
SELECT 
	SUM(fv.LineTotal) AS TotalSales
FROM view_fact_sales AS fv
LEFT JOIN view_dim_customer AS dc ON fv.CustomerID = dc.CustomerID;

--b) Venta total con tablas OrderHeader y Customer - 109.846.381,4039
SELECT 
	SUM(soh.SubTotal) AS TotalSales
FROM Sales.SalesOrderHeader AS soh
LEFT JOIN Sales.Customer AS c ON c.CustomerID = soh.CustomerID;


--3) Vendedores

--1. cantidad de vendedores - 17
SELECT
	COUNT(BusinessEntityID) AS TotalSalesPerson
FROM view_dim_sales_person;

--2. limpieza de datos - INTEGRIDAD REFERENCIAL
--a) ¿cuáles vendedores no tienen ventas? - 0
SELECT
	vsp.BusinessEntityID 
FROM view_dim_sales_person vsp
LEFT JOIN Sales.SalesOrderHeader AS soh ON vsp.BusinessEntityID = soh.SalesPersonID
WHERE soh.SalesPersonID IS NULL;

--b) ver si hay ventas que no tienen vendedor o con vendedor que no aparecen en listado de vendedores 
SELECT
	DISTINCT(vsp.BusinessEntityID)
FROM Sales.SalesOrderHeader AS soh
LEFT JOIN view_dim_sales_person vsp ON soh.SalesPersonID = vsp.BusinessEntityID
WHERE vsp.BusinessEntityID IS NULL;

--3. limpieza de datos - VERIFICACIÓN DE NULOS
--a) hay vendedores sin territorio asignado, pero tienen un TerritoryGroup asignado
SELECT *
FROM view_dim_sales_person
WHERE TerritoryID IS NULL;


--4) Territorios

--1. Total ventas territorios
--a) usando las vistas - 109846381.399888
SELECT
	SUM(fs.LineTotal) AS TotalSalesTerritory
FROM view_dim_territory AS t
LEFT JOIN view_fact_sales AS fs ON t.TerritoryID = fs.TerritoryID;

--b) usando tablas sales order header and territory - 109.846.381,4039
SELECT
	SUM(soh.SubTotal) AS TotalSalesTerritory
FROM Sales.SalesTerritory AS st
LEFT JOIN Sales.SalesOrderHeader AS soh ON st.TerritoryID = soh.TerritoryID;

--2. limpieza de datos - INTEGRIDAD REFERENCIAL
--a) ver si hay territorios sin ventas - no
SELECT
	t.TerritoryID
FROM view_dim_territory AS t
LEFT JOIN view_fact_sales AS fs ON t.TerritoryID = fs.TerritoryID
WHERE fs.TerritoryID IS NULL;

--b)ver si hay ventas sin territorio - no
SELECT
	t.TerritoryID
FROM view_fact_sales AS fs
LEFT JOIN view_dim_territory AS t ON fs.TerritoryID = t.TerritoryID
WHERE t.TerritoryID IS NULL;


--5) Sales

--1. Total ventas 
--a) con tabla Sales OrderHeader - 109.846.381,4039
SELECT
	SUM(SubTotal) AS TotalSales
FROM Sales.SalesOrderHeader AS soh;

--b) Usando vista sales - 109.846.381,399888
SELECT
	SUM(LineTotal) AS TotalSales
FROM view_fact_sales;

--c) Usando tabla Sales Order Detail - 109.846.381,399888
SELECT
	SUM(LineTotal) AS TotalSales
FROM Sales.SalesOrderDetail;

--2. verificación de nulos - solo salesperson tiene nulos
SELECT *
FROM view_fact_sales
WHERE ProductID IS NULL
	OR CustomerID IS NULL
	OR SalesPersonID IS NULL
	OR TerritoryID IS NULL;

--3. consulta de validación de calidad de datos - comprobar que cada línea de venta tenga un único costo histórico.
--0 rows = Cada combinación SalesOrderID + ProductID + OrderDate encuentra como máximo un registro de costo histórico.
SELECT
    soh.SalesOrderID,
    sod.ProductID,
    soh.OrderDate,
    COUNT(*) AS NumberOfCostMatches
FROM Sales.SalesOrderDetail AS sod
INNER JOIN Sales.SalesOrderHeader AS soh ON sod.SalesOrderID = soh.SalesOrderID
LEFT JOIN Production.ProductCostHistory AS pch ON sod.ProductID = pch.ProductID
    AND soh.OrderDate >= pch.StartDate
    AND (
        soh.OrderDate <= pch.EndDate
        OR pch.EndDate IS NULL
    )
GROUP BY
    soh.SalesOrderID,
    sod.ProductID,
    soh.OrderDate
HAVING COUNT(*) > 1;

--4. consulta de diagnóstico - validación de calidad de datos -  verificar si productos sin costo estándar coinciden en que orderdate > sellenddate
SELECT
    sod.SalesOrderID,
    sod.ProductID,
    CAST(soh.OrderDate AS DATE) AS OrderDate,
    CAST(p.SellEndDate AS DATE) AS SellEndDate,
    pch.StandardCost AS ProductStandardCostAtSale,

    CASE
        WHEN p.SellEndDate IS NOT NULL
             AND soh.OrderDate > p.SellEndDate
        THEN 'Sale after SellEndDate'
        ELSE 'OK'
    END AS DataQualityStatus

FROM Sales.SalesOrderDetail AS sod
INNER JOIN Sales.SalesOrderHeader AS soh ON sod.SalesOrderID = soh.SalesOrderID
INNER JOIN Production.Product AS p ON sod.ProductID = p.ProductID
LEFT JOIN Production.ProductCostHistory AS pch ON sod.ProductID = pch.ProductID
    AND soh.OrderDate >= pch.StartDate
    AND (
        soh.OrderDate <= pch.EndDate
        OR pch.EndDate IS NULL
    )
WHERE pch.ProductID IS NULL
ORDER BY DataQualityStatus;

--5. comprobar si el 100 % de las líneas sin costo histórico vigente corresponden a productos vendidos después de su SellEndDate
SELECT
    COUNT(*) AS TotalWithoutCost,

    SUM(
        CASE
            WHEN p.SellEndDate IS NOT NULL
                 AND soh.OrderDate > p.SellEndDate
            THEN 1
            ELSE 0
        END
    ) AS SoldAfterSellEndDate

FROM Sales.SalesOrderDetail AS sod
INNER JOIN Sales.SalesOrderHeader AS soh ON sod.SalesOrderID = soh.SalesOrderID
INNER JOIN Production.Product AS p ON sod.ProductID = p.ProductID
LEFT JOIN Production.ProductCostHistory AS pch ON sod.ProductID = pch.ProductID
    AND soh.OrderDate >= pch.StartDate
    AND (
        soh.OrderDate <= pch.EndDate
        OR pch.EndDate IS NULL
    )
WHERE pch.ProductID IS NULL;

--6. Las ventas sin vendedor son [OnlineOrderFlag] = 1 - Todas las ventas Online son las mismas ventas sin vendedir
SELECT
    OnlineOrderFlag,
    COUNT(*) AS TotalOrders,
    SUM([SubTotal]) AS TotalSales
FROM Sales.SalesOrderHeader
WHERE SalesPersonID IS NULL
GROUP BY OnlineOrderFlag;


--6) Date 

--1. consulta exploratoria - primer fecha 2022-05-30 y última fecha 2025-06-29 
SELECT 
	MIN(soh.OrderDate) AS InitialDate,
	MAX(soh.OrderDate) AS FinalDate
FROM Sales.SalesOrderHeader AS soh;