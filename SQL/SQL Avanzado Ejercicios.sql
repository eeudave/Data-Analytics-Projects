--- EJERCICIOS SQL AVANZADO

--1.Agregar una columna llamada “Ranking” con el ranking de ventas en función del monto (SalesOrderHeader.TotalDue)


SELECT 
	SalesOrderID,
	TotalDue,
	ROW_NUMBER() OVER(
		ORDER BY TotalDue DESC 
		) AS Ranking
FROM Sales.SalesOrderHeader

--2.Agregar una columna llamada “Ranking” por territorio con el ranking de ventas en función del monto y territorio. Mostrar el nombre del Territorio, SalesOrderID, OrderDate, TotalDue y Ranking

SELECT 
	st.Name AS Territorio,
	soh.SalesOrderID, 
	soh.OrderDate, 
	soh.TotalDue,
	ROW_NUMBER() OVER(
		PARTITION BY st.Name 
		ORDER BY soh.TotalDue DESC 
		) AS Ranking
FROM Sales.SalesOrderHeader soh 
LEFT JOIN Sales.SalesTerritory st 
ON soh.TerritoryID = st.TerritoryID
--WHERE st.Name IN ('Central','Northeast')

--ranking total por territorio
SELECT 
	st.Name AS Territorio, 
	COUNT(soh.SalesOrderID) AS Ventas, 
	SUM(soh.TotalDue) AS MontoTotal,
	ROW_NUMBER() OVER(
		ORDER BY SUM(soh.TotalDue) DESC 
		) AS Ranking
FROM Sales.SalesOrderHeader soh 
LEFT JOIN Sales.SalesTerritory st 
ON soh.TerritoryID = st.TerritoryID
GROUP BY st.Name

--3.Agregar una columna en la tabla SalesPerson que muestre la contribución de esa persona a las ventas del año (SalesYTD / total de SalesYTD)

SELECT 
	BusinessEntityID,
	TerritoryID,
	SalesYTD,
	SUM(SalesYTD) OVER() AS TotalSalesYTD,
	SalesYTD/SUM(SalesYTD) OVER() AS ContribVentas
FROM Sales.SalesPerson

--4.En la tabla CurrencyRate, buscar los registros que reflejen el tipo de cambio Dólar a Euro y calcular cual fue la máxima fluctuación de un día a otro (considerar el AverageRate).

WITH USDtoEUR AS (	
	SELECT 
		CurrencyRateID,
		CurrencyRateDate,
		FromCurrencyCode,
		ToCurrencyCode,
		AverageRate,
		LAG(AverageRate) OVER(ORDER BY CurrencyRateID) AS CurrencyPrevio,
		LEAD(AverageRate) OVER(ORDER BY CurrencyRateID) AS CurrencySig,
		ABS(AverageRate - LEAD(AverageRate) OVER(ORDER BY CurrencyRateID)) AS Fluctuacion
		FROM Sales.CurrencyRate cr 
	WHERE FromCurrencyCode = 'USD' AND ToCurrencyCode = 'EUR'
)

SELECT 
	CurrencyRateID,
	CurrencyRateDate,
	FromCurrencyCode,
	ToCurrencyCode,
	AverageRate,
	Fluctuacion,
	ROW_NUMBER() OVER(
		ORDER BY Fluctuacion DESC 
		) AS Ranking
FROM USDtoEUR;

--5.De los dos vendedores (SalesPersonID) que hayan tenido mayor cantidad de ventas (TotalDue) en toda la historia, mostrar sus 5 ventas más altas. 
--  La tabla debe tener Nombre y apellido del vendedor (tabla Person), JobTitle, OrderDate y TotalDue

--top 2 vendedores
--SELECT TOP 2 SalesPersonID FROM Sales.SalesOrderHeader WHERE SalesPersonID IS NOT NULL GROUP BY SalesPersonID ORDER BY SUM(TotalDue) DESC

SELECT 
	top5.SalesOrderID AS Orden,
	top5.SalesPersonID AS Vendedor,
	p.FirstName,
	p.LastName,
	e.JobTitle,
	top5.OrderDate,
	top5.TotalDue 
FROM Person.Person p
LEFT JOIN HumanResources.Employee e 
ON p.BusinessEntityID = e.BusinessEntityID 
CROSS APPLY (
	SELECT TOP 5 
		SalesOrderID,
		SalesPersonID,
		OrderDate,
		TotalDue
	FROM Sales.SalesOrderHeader soh
	WHERE soh.SalesPersonID = p.BusinessEntityID AND 
		  soh.SalesPersonID IN (SELECT TOP 2 SalesPersonID 
		  						FROM Sales.SalesOrderHeader 
		  						WHERE SalesPersonID IS NOT NULL 
		  						GROUP BY SalesPersonID 
		  						ORDER BY SUM(TotalDue) DESC)
	ORDER BY TotalDue DESC
) Top5

--6.En la tabla Production.WorkOrder mostrar el día (DueDate) que más piezas se hayan pedido (OrderQty) 
--  de las piezas que tengan un precio de lista mayor a 3000 (Product.ListPrice). Mostrar ProductID, DueDate, OrderQty y ListPrice

SELECT TOP 1
	wo.ProductID,
	wo.DueDate,
	SUM(wo.OrderQty) AS SumQty,
	p.ListPrice 
FROM Production.WorkOrder wo
LEFT JOIN Production.Product p
ON p.ProductID = wo.ProductID 
WHERE wo.ProductID IN (SELECT p.ProductID FROM Production.Product p WHERE  p.ListPrice > 3000)
GROUP BY wo.ProductID, wo.DueDate,p.ListPrice 
ORDER BY SUM(wo.OrderQty) DESC

--- solo 1 valor
SELECT TOP 1
	wo.DueDate,
	SUM(wo.OrderQty) AS SumQty
FROM Production.WorkOrder wo
LEFT JOIN Production.Product p
ON p.ProductID = wo.ProductID 
WHERE  p.ListPrice > 3000
GROUP BY wo.DueDate
ORDER BY SUM(wo.OrderQty) DESC

--7. Buscar cuales fueron los dos compradores que mayores compras realizaron por cada territorio (ver tabla Sales.SalesOrderHeader). 
--   Indicar nombre del territorio, id del cliente y cantidad de compras

SELECT 
	st.TerritoryID,
	st.Name,
	top2.CustomerID AS ClienteID,
	top2.TotalDue AS TotCompras
FROM Sales.SalesTerritory st 
CROSS APPLY (
	SELECT TOP 2
		soh.TerritoryId,
		soh.CustomerID,
		soh.TotalDue
	FROM Sales.SalesOrderHeader soh
	WHERE soh.TerritoryId = st.TerritoryID
	ORDER BY soh.TotalDue DESC
) top2

/*
SELECT TOP 2
	soh.TerritoryId,
	soh.CustomerID,
	soh.TotalDue
FROM Sales.SalesOrderHeader soh
ORDER BY soh.TotalDue DESC
*/

--8. Mostar una tabla que tenga en las filas los territorios y en las columnas las categorías. 
--   La misma debe contener la cantidad de unidades vendidas por cada categoría y territorio respectivamente.

--SELECT TerritoryID, Name FROM Sales.SalesTerritory st 

---
WITH TerritorioCategoria AS (
	SELECT 
		soh.SalesOrderID,
		sod.ProductID,
		st.Name as TerritoryName,
		p.ProductSubCategoryID, 
		ps.ProductCategoryID,
		ps.Name AS SubCategoryName,
		pc.Name AS CategoryName,
		sod.OrderQty AS Cantidad,
		soh.TotalDue
	FROM Sales.SalesOrderHeader soh 
	LEFT JOIN Sales.SalesTerritory st 
	ON st.TerritoryID = soh.TerritoryID 
	LEFT JOIN Sales.SalesOrderDetail sod 
	ON sod.SalesOrderID = soh.SalesOrderID 
	LEFT JOIN Production.Product p
	ON p.ProductID = sod.ProductID
	LEFT JOIN Production.ProductSubcategory ps 
	ON ps.ProductSubcategoryID = p.ProductSubcategoryID 
	LEFT JOIN Production.ProductCategory pc 
	ON pc.ProductCategoryID = ps.ProductCategoryID 
	WHERE p.ProductSubcategoryID IS NOT NULL
)

--- PIVOT
SELECT *
FROM (
	SELECT 
		TerritoryName, 
		CategoryName, 
		Cantidad
	FROM TerritorioCategoria
	) AS tabla_previa
PIVOT (
	SUM(Cantidad)
	FOR CategoryName IN ([Accessories],[Bikes],[Clothing],[Components])
) AS tabla_pivote;

--SELECT Name FROM Production.ProductCategory


