--Validación de datos obtenidos mediante POWER BI

--Al ejecutar la línea permite que la consulta se ejecute con la db que le digo
USE [AdventureWorks2025];

--1) Products
--1. Top 10 productos con mayores ventas ($)
SELECT TOP (10)
	dp.ProductID,
	dp.ProductNumber,
	dp.NameProduct,
	dp.NameCategory,
	dp.NameSubcategory,
	SUM(fs.LineTotal) AS TotalSales
FROM view_fact_sales AS fs
INNER JOIN view_dim_product AS dp ON fs.ProductID = dp.ProductID
GROUP BY 
	dp.ProductID,
	dp.ProductNumber,
	dp.NameProduct,
	dp.NameCategory,
	dp.NameSubcategory
ORDER BY TotalSales DESC; 

--2. total de ventas 
--a)Con las vistas - 109.846.381,399888
SELECT SUM(fs.LineTotal) AS TotalSales
FROM view_fact_sales AS fs
LEFT JOIN view_dim_product AS dp ON fs.ProductID = dp.ProductID; 

--b) Con las tablas SalesOrderDetail y ProductionProduct - 109846381.399888
SELECT SUM(sod.LineTotal) AS TotalSales
FROM Production.Product AS p
LEFT JOIN Sales.SalesOrderDetail AS sod ON p.ProductID = sod.ProductID; 

--3. Buscar ventas cuando categoría es nula
--a) Agrupo ventas por categoría
SELECT 
	p.NameCategory AS Category,
	CAST(SUM(fs.LineTotal) AS DECIMAL (10,2)) AS Sales
FROM view_fact_sales AS fs
LEFT JOIN view_dim_product AS p ON fs.ProductID = p.ProductID
GROUP BY	
	p.NameCategory
ORDER BY Category ASC;

--b) Uso la lista de los productos sin categoría, y observo que no tienen ventas
SELECT 
	ProductID,
	SUM(LineTotal) AS SalesProductNoCategory
FROM view_fact_sales
WHERE ProductID IN (
	SELECT [ProductID]
	FROM [AdventureWorks2025].[dbo].[view_dim_product]
	WHERE [NameCategory] IS NULL
	)
GROUP BY ProductID;


--2) Clientes

--1. clientes activos tipo store = 635 tiendas activas de 647 tiendas
SELECT 
	COUNT(DISTINCT(soh.CustomerID)) AS TotalActiveStores
FROM Sales.SalesOrderHeader AS soh
LEFT JOIN dbo.view_dim_customer AS vdc ON soh.CustomerID = vdc.CustomerID 
WHERE vdc.CustomerType = 'Store Customer' 
--AND OrderDate BETWEEN '2025-01-01' AND '2025-06-29';

--2. clientes activos tipo retail = 18484
--hay 16 clientes que se llaman exactamente igual pero tienen distinta información demográfica
SELECT 
	COUNT(DISTINCT(soh.CustomerID)) AS TotalRetailCustomers
FROM Sales.SalesOrderHeader AS soh
LEFT JOIN dbo.view_dim_customer AS vdc ON soh.CustomerID = vdc.CustomerID 
WHERE vdc.CustomerType = 'Retail Customer'
--AND OrderDate BETWEEN '2025-01-01' AND '2025-06-29';

--3. calcular venta total clientes - 
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

--1. Verificación de ventas con vendedor nulo o con vendedor que no esté en listado de vendedores
--¿por qué hay ventas sin vendedor? Corresponde a las ventas online
SELECT
	DISTINCT(vsp.BusinessEntityID)
FROM Sales.SalesOrderHeader AS soh
LEFT JOIN view_dim_sales_person vsp ON soh.SalesPersonID = vsp.BusinessEntityID
WHERE vsp.BusinessEntityID IS NULL;

--2. total ventas sin vendedor (ventas online) - 29.358.677,2207
SELECT
	SUM(SubTotal) AS TotalSalesSPNull
FROM Sales.SalesOrderHeader AS soh
WHERE 
	SalesPersonID IS NULL;

--3. Top 10 de mejores vendedores
--a) usando las vistas - La mayor venta es el grupo "sin vendedor" (-1)
SELECT TOP (10)
	vs.SalesPersonID,
	SUM(vs.LineTotal) AS TotalSalesSP
FROM view_fact_sales AS vs
INNER JOIN view_dim_sales_person AS vsp ON vs.SalesPersonID = vsp.BusinessEntityID
GROUP BY vs.SalesPersonID
ORDER BY TotalSalesSP DESC;


--4) Territorios

--1. ranking de ventas por territorios
SELECT 
	t.TerritoryID,
    t.TerritoryName,
    t.TerritoryGroup,
    t.CountryRegionCode,
    t.CountryRegionName,
	SUM(fs.LineTotal) AS TotalSalesTerritory
FROM view_fact_sales AS fs
INNER JOIN view_dim_territory AS t ON fs.TerritoryID = t.TerritoryID
GROUP BY
	t.TerritoryID,
    t.TerritoryName,
    t.TerritoryGroup,
    t.CountryRegionCode,
    t.CountryRegionName
ORDER BY TotalSalesTerritory DESC;

--2. Productos más vendidos por territorio
SELECT TOP (10)
	dp.ProductID,
	dp.ProductNumber,
	dp.NameProduct,
	dp.NameCategory,
	dp.NameSubcategory,
	fs.TerritoryID,
	SUM(fs.LineTotal) AS TotalSales
FROM view_fact_sales AS fs
INNER JOIN view_dim_product AS dp ON fs.ProductID = dp.ProductID
WHERE fs.TerritoryID = 4
--cambiar el id del territorio
GROUP BY 
	dp.ProductID,
	dp.ProductNumber,
	dp.NameProduct,
	dp.NameCategory,
	dp.NameSubcategory,
	fs.TerritoryID
ORDER BY TotalSales DESC; 


--5) Sales

--1. netsales by year
SELECT 
	YEAR(soh.OrderDate) AS OrderYear,
	CAST(SUM(sod.LineTotal) AS DECIMAL (10,2)) AS SalesByYear
FROM Sales.SalesOrderDetail AS sod
INNER JOIN Sales.SalesOrderHeader AS soh ON sod.SalesOrderID = soh.SalesOrderID
GROUP BY YEAR(soh.OrderDate);

--2. netsales in june by year
--a) Con view_fact_sales
SELECT 
	YEAR(OrderDate) AS SalesYear,
	MONTH(OrderDate) AS SalesMonth,
	CAST(SUM(LineTotal) AS DECIMAL (10,2)) AS JuneSales
FROM view_fact_sales
WHERE MONTH(OrderDate) = 6
GROUP BY	
	YEAR(OrderDate),
	MONTH(OrderDate)
ORDER BY YEAR(OrderDate) ASC;

--b) Con SalesOrderDetail y Sales.SalesOrderHeader
SELECT 
	YEAR(soh.OrderDate) AS SalesYear,
	MONTH(soh.OrderDate) AS SalesMonth,
	CAST(SUM(sod.LineTotal) AS DECIMAL (10,2)) AS JuneSales
FROM Sales.SalesOrderDetail AS sod
INNER JOIN Sales.SalesOrderHeader AS soh ON sod.SalesOrderID = soh.SalesOrderID
WHERE MONTH(OrderDate) = 6
GROUP BY	
	YEAR(OrderDate),
	MONTH(OrderDate)
ORDER BY YEAR(OrderDate) ASC;

--3. Net Sales
--a) Total
SELECT
	SUM(LineTotal) AS TotalNetSales
FROM view_fact_sales;

--b) 2025
SELECT
	SUM(LineTotal) AS TotalNetSales
FROM view_fact_sales
WHERE OrderDate BETWEEN '2025-01-01' AND '2025-06-29';

 --4. Online Sales Share % - ¿Online Order Flag is SalesPerson Null?
 --a) cantidad de filas con onlineorderflag = 1
 SELECT count(*)
 FROM [AdventureWorks2025].[Sales].[SalesOrderHeader]
 WHERE OnlineOrderFlag = 1

  --b) cantidad de filas con salespersonID null
 SELECT count(*)
 FROM [AdventureWorks2025].[Sales].[SalesOrderHeader]
 WHERE SalesPersonID is null;

 --c) Online Sales Share %
WITH TotalNetSalesT AS 
(
SELECT
	SUM(LineTotal) AS TotalNetSales
FROM view_fact_sales
),
TotalOnlineSalesT AS
(
SELECT
	SUM(LineTotal) AS TotalOnlineSales
FROM view_fact_sales
WHERE SalesPersonID = -1
)
SELECT 
    TotalOnlineSales,
    TotalNetSales,
    (TotalOnlineSales / NULLIF(TotalNetSales, 0)) * 100 AS OnlineSalesShare
FROM TotalNetSalesT
CROSS JOIN TotalOnlineSalesT;

--d) Online Sales Share % 2025
WITH TotalNetSalesT25 AS 
(
SELECT
	SUM(LineTotal) AS TotalNetSales25
FROM view_fact_sales
WHERE OrderDate BETWEEN '2025-01-01' AND '2025-06-29'
),
TotalOnlineSalesT25 AS
(
SELECT
	SUM(LineTotal) AS TotalOnlineSales25
FROM view_fact_sales
WHERE 
	SalesPersonID = '-1'
	AND
	OrderDate BETWEEN '2025-01-01' AND '2025-06-29'
)
SELECT 
    TotalOnlineSales25,
    TotalNetSales25,
    (TotalOnlineSales25 / NULLIF(TotalNetSales25, 0)) * 100 AS OnlineSalesShare25
FROM TotalNetSalesT25
CROSS JOIN TotalOnlineSalesT25;

--5. Total Sales Orders
--a) Total
SELECT
	COUNT(DISTINCT(SalesOrderID)) AS TotalOrders
FROM view_fact_sales;

--b) 2025
SELECT
	COUNT(DISTINCT(SalesOrderID)) AS TotalOrders
FROM view_fact_sales
WHERE OrderDate BETWEEN '2025-01-01' AND '2025-06-29';

--6. ATV
--a) total
WITH TotalNetSalesT AS
(
SELECT
	SUM(LineTotal) AS TotalNetSales
FROM view_fact_sales
),
TotalOrdersT AS
(
SELECT
	COUNT(DISTINCT(SalesOrderID)) AS TotalOrders
FROM view_fact_sales
)
SELECT 
	TotalNetSales,
	TotalOrders,
	(TotalNetSales / NULLIF(TotalOrders,0)) AS ATV
FROM TotalNetSalesT
CROSS JOIN TotalOrdersT;

--b) 2025
WITH TotalNetSales25T
AS
(
SELECT
	SUM(LineTotal) AS TotalNetSales25
FROM view_fact_sales
WHERE OrderDate BETWEEN '2025-01-01' AND '2025-06-29'
),
TotalOrders25T AS
(
SELECT
	COUNT(DISTINCT(SalesOrderID)) AS TotalOrders25
FROM view_fact_sales
WHERE OrderDate BETWEEN '2025-01-01' AND '2025-06-29'
)
SELECT 
	TotalNetSales25,
	TotalOrders25,
	(TotalNetSales25 / NULLIF(TotalOrders25,0)) AS ATV25
FROM TotalNetSales25T
CROSS JOIN TotalOrders25T;

--7.Lines Without Historical Cost vs Sales Without Historical Cost
--a) SELECT
    COUNT(*) AS LinesWithoutHistoricalCost,
    SUM(LineTotal) AS SalesWithoutHistoricalCost
FROM dbo.view_fact_sales
WHERE HasHistoricalCost = 0;

--b) las ventas para los productos con costos invalidos
--Nota: el 100 % de las líneas sin costo histórico vigente corresponden a productos vendidos después de su SellEndDate.
SELECT
    SUM(LineTotal) AS TotalNetSales
FROM dbo.view_fact_sales
WHERE ProductStandardCostAtSale IS NULL;

--8. Gross Profit Based on Historical Cost or Gross Profit with Available Historical Cost
SELECT
    SUM(LineTotal) - SUM(TotalCost) AS GrossProfit
FROM [dbo].[view_fact_sales]
WHERE HasHistoricalCost = 1;