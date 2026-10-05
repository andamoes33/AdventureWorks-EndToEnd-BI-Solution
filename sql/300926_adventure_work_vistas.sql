--Al ejecutar la línea permite que la consulta se ejecute con la db que le digo
USE [AdventureWorks2025];


--CREACIÓN DE VISTAS

--vista_fact_sales
CREATE VIEW view_fact_sales AS
SELECT 
	soh.CustomerID, 
	ISNULL(soh.SalesPersonID, -1) AS SalesPersonID, 
	soh.TerritoryID,
	sod.SalesOrderID,
	CAST(soh.OrderDate AS DATE) AS OrderDate,
	
	sod.ProductID, 
	sod.OrderQty, 
	sod.UnitPrice, 
	sod.UnitPriceDiscount,
	
	sod.OrderQty * sod.UnitPrice AS GrossSalesAmount,
	(sod.OrderQty * sod.UnitPrice *  sod.UnitPriceDiscount) AS DiscountAmount,
	sod.LineTotal,

	pch.StandardCost AS ProductStandardCostAtSale,
	(pch.StandardCost*sod.OrderQty) AS TotalCost,
	CASE
        WHEN p.SellEndDate IS NOT NULL
             AND soh.OrderDate > p.SellEndDate
        THEN 1
        ELSE 0
    END AS SoldAfterSellEndDate,
	CASE
		WHEN pch.ProductID IS NULL THEN 0
    ELSE 1
	END AS HasHistoricalCost

FROM Sales.SalesOrderDetail AS sod
INNER JOIN Sales.SalesOrderHeader AS soh ON sod.SalesOrderID = soh.SalesOrderID
INNER JOIN Production.Product AS p ON sod.ProductID = p.ProductID
LEFT JOIN Production.ProductCostHistory AS pch ON sod.ProductID = pch.ProductID
    AND soh.OrderDate >= pch.StartDate
    AND (
        soh.OrderDate <= pch.EndDate
        OR pch.EndDate IS NULL
	);


--vista_dim_product
CREATE VIEW view_dim_product AS
SELECT
	p.ProductID,
	p.ProductNumber,
	p.Name AS NameProduct,
	c.Name AS NameCategory,
	s.Name AS NameSubcategory,
	p.Color,
	p.Size,
	p.StandardCost,
	p.ListPrice

FROM Production.Product AS p
LEFT JOIN Production.ProductSubcategory AS s ON s.ProductSubcategoryID = p.ProductSubcategoryID
LEFT JOIN Production.ProductCategory AS c ON s.ProductCategoryID = c.ProductCategoryID;


--vista_dim_customer
CREATE VIEW view_dim_customer AS
SELECT
	c.CustomerID,
	c.StoreID,
	c.PersonID,
	CASE
		WHEN c.StoreID IS NULL
			THEN 'Retail Customer'
			ELSE 'Store Customer'
		END AS CustomerType,
	c.TerritoryID,
	CASE
		WHEN c.StoreID IS NULL
			THEN 
				TRIM(
					CONCAT(
						COALESCE(p.Title + ' ',''),
						p.FirstName,
						COALESCE(' ' + p.MiddleName,''),
						' ',
						p.LastName,
						COALESCE(' ' + p.Suffix,'')
					)
				)
			ELSE s.Name
		END AS CustomerFullName

FROM Sales.Customer AS c
LEFT JOIN Person.Person AS p ON c.PersonID = p.BusinessEntityID AND p.PersonType = 'IN'
LEFT JOIN Sales.Store AS s ON c.StoreID = s.BusinessEntityID
WHERE PersonID IS NOT NULL;


--vista_DimTerritory
CREATE VIEW view_dim_territory AS
SELECT
	st.TerritoryID,
    st.Name AS TerritoryName,
	st.[Group] AS TerritoryGroup,
	st.CountryRegionCode,

    cr.Name AS CountryRegionName

FROM Sales.SalesTerritory AS st
LEFT JOIN Person.CountryRegion AS cr ON st.CountryRegionCode = cr.CountryRegionCode;


--vista_dim_sales_person
CREATE VIEW view_dim_sales_person AS
SELECT
	sp.BusinessEntityID,
	em.NationalIDNumber,
	TRIM(
		CONCAT(
			COALESCE(p.Title + ' ',''),
			p.FirstName,
			COALESCE(' ' + p.MiddleName,''),
			' ',
			p.LastName,
			COALESCE(' ' + p.Suffix,'')
		)
	) AS SalesPersonFullName,
    em.JobTitle,
	sp.TerritoryID,
	sp.SalesQuota,
	sp.Bonus,
	sp.CommissionPct,
    em.Gender

FROM Sales.SalesPerson AS sp
LEFT JOIN Person.Person AS p ON sp.BusinessEntityID = p.BusinessEntityID
LEFT JOIN HumanResources.Employee AS em ON sp.BusinessEntityID = em.BusinessEntityID

UNION ALL

-- Registro para ventas sin vendedor asignado
SELECT
    -1 AS BusinessEntityID,
	NULL AS NationalIDNumber,
	'Online Sales' AS SalesPersonFullName,
	NULL AS JobTitle,
	NULL AS TerritoryID,
	NULL AS SalesQuota,
    NULL AS Bonus,
    NULL AS CommissionPct,
    NULL AS Gender;