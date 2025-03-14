---------EJERCICIOS SQL INTERMEDIO

--1.	¿Cuántas filas hay dentro de la tabla personas?

SELECT COUNT(*) AS Personas
FROM Person.Person

--2.	Indicar la cantidad de empleados cuyos apellidos empiecen con una letra inferior a “D”

SELECT COUNT(*) AS Personas
FROM Person.Person
WHERE LastName LIKE '[A-C]%'  

--3.	¿Cuál es el promedio de StandardCost para cada producto donde StandardCost es mayor a $0? (Production.Product)

SELECT 
	Name,	
	AVG(StandardCost) as AvgCost
FROM Production.Product
GROUP BY Name 
HAVING AVG(StandardCost) > 0
ORDER BY Name

--4.	En la tabla personas ¿cuántas personas están asociadas con cada tipo de persona (PersonType)?

SELECT 
	PersonType,
	COUNT(*) AS Personas
FROM Person.Person
GROUP BY PersonType
ORDER BY PersonType 

---SELECT * FROM Person.Person

--5.	¿Cuántos productos en Production.Product hay que son rojos (red) y cuántos que son negros (black)?

SELECT 
	Color,
	COUNT(*) AS Productos
FROM Production.Product
GROUP BY Color 
HAVING Color IN ('Red','Black')
ORDER BY Color

--6.	¿Cuáles son las ventas por territorio para todas las filas de Sales.SalesOrderHeader? Traer sólo los territorios que se pasen de $10 millones en ventas históricas, traer el total de las ventas y el TerritoryID.

SELECT 
	TerritoryID,
	SUM(TotalDue) as TotalVentas
FROM Sales.SalesOrderHeader
GROUP BY TerritoryID 
HAVING SUM(TotalDue) > 10000000
ORDER BY TerritoryID

---SELECT * FROM Sales.SalesOrderHeader

--7.	Usando la query anterior, hacer un join hacia Sales.SalesTerritory y reemplazar el TerritoryID con el nombre del territorio. 

SELECT 
	st.Name,
	SUM(s.TotalDue) as TotalVentas
FROM Sales.SalesOrderHeader s
LEFT JOIN Sales.SalesTerritory st 
ON s.TerritoryID = st.TerritoryID 
GROUP BY st.Name
HAVING SUM(s.TotalDue) > 10000000
ORDER BY st.Name

---SELECT * FROM Sales.SalesTerritory

--8.	¿Cuántas filas en Person.Person no tienen NULL en MiddleName?

SELECT COUNT(*) AS Personas
FROM Person.Person
WHERE MiddleName IS NOT NULL

--9.	Usando Production.Product encontrar cuántos productos están asociados con cada color. Ignorar las filas donde el color no tenga datos (NULL). Luego de agruparlos, devolver sólo los colores que tienen al menos 20 productos en ese color.

SELECT
	Color,
	COUNT(ProductID) as Productos
FROM Production.Product
WHERE Color IS NOT NULL
GROUP BY Color
HAVING COUNT(ProductID) >= 20
ORDER BY Color

---SELECT * FROM Production.Product

--10.	Hacer un join entre Production.Product y Production.ProductInventory sólo cuando los productos aparecen en ambas tablas. Hacerlo sobre el ProductID. Production.ProductInventory tiene la cantidad de cada producto, si se vende cada producto con un ListPrice mayor a cero, ¿cuánto fue el total facturado? 

SELECT 
	p.ProductID, 
	p.Name,
	p.ListPrice, 	
	SUM(pi.Quantity) as Cantidad,
	SUM(pi.Quantity) * p.ListPrice as Facturado
FROM Production.Product p
INNER JOIN Production.ProductInventory pi
ON p.ProductID = pi.ProductID 
GROUP BY p.ProductID, p.Name, p.ListPrice 
HAVING p.ListPrice > 0
ORDER BY p.ProductID


SELECT 
	SUM(pi.Quantity * p.ListPrice) as Facturado
FROM Production.Product p
INNER JOIN Production.ProductInventory pi
ON p.ProductID = pi.ProductID 
WHERE p.ListPrice > 0

/*
SELECT 
	ProductID, 
	Name,
	ListPrice 
FROM Production.Product
WHERE ListPrice > 0

SELECT 
	ProductID,
    SUM(Quantity) as Cantidad
FROM Production.ProductInventory
GROUP BY ProductID 
ORDER BY ProductID
*/

--11.	Traer FirstName y LastName de Person.Person. Crear una tercera columna donde se lea “Promo 1” si el EmailPromotion es 0, “Promo 2” si el valor es 1 o “Promo 3” si es 2

SELECT 
	FirstName,
	LastName,
	CASE 
		WHEN EmailPromotion = 0 THEN 'Promo 1'
		WHEN EmailPromotion = 1 THEN 'Promo 2'
		WHEN EmailPromotion = 2 THEN 'Promo 3'
		ELSE 'Otro'
	END AS Promocion
FROM Person.Person

--SELECT * FROM Person.Person

--12.	Traer el BusinessEntityID y SalesYTD de Sales.SalesPerson, juntarla con Sales.SalesTerritory de tal manera que Sales.SalesPerson devuelva valores aunque no tenga asignado un territorio. Traes el nombre de Sales.SalesTerritory.

SELECT 
	s.BusinessEntityID,
	s.SalesYTD,
	st.Name as Territorio
FROM Sales.SalesPerson s
LEFT JOIN Sales.SalesTerritory st
ON s.TerritoryID = st.TerritoryID 

--SELECT * FROM Sales.SalesPerson
--SELECT * FROM Sales.SalesTerritory

--13.	Usando el ejemplo anterior, vamos a hacerlo un poco más complejo. Unir Person.Person para traer también el nombre y apellido. Sólo traer las filas cuyo territorio sea “Northeast” o “Central”.

SELECT 
	p.FirstName,
	p.LastName,
	s.BusinessEntityID,
	s.SalesYTD,
	st.Name as Territorio
FROM Sales.SalesPerson s
LEFT JOIN Sales.SalesTerritory st
ON s.TerritoryID = st.TerritoryID 
LEFT JOIN Person.Person p 
ON s.BusinessEntityID = p.BusinessEntityID 
WHERE st.Name IN ('Northeast','Central')

--SELECT * FROM Person.Person

--14.	Usando Person.Person y Person.Password hacer un INNER JOIN trayendo FirstName, LastName y PasswordHash.

SELECT 
	pp.FirstName,
	pp.LastName,
	ps.PasswordHash 
FROM Person.Person pp
INNER JOIN Person.Password ps
ON pp.BusinessEntityID = ps.BusinessEntityID 

--SELECT * FROM Person.Person
--SELECT * FROM Person.Password

--15.	Traer el título de Person.Person. Si es NULL devolver “No hay título”.


SELECT 
	FirstName,
	LastName,
	CASE
		WHEN Title IS NULL THEN 'No hay titulo'
		ELSE Title
	END AS Titulo
FROM Person.Person

--16.	Si MiddleName es NULL devolver FirstName y LastName concatenados, con un espacio de por medio. Si MiddeName no es NULL devolver FirstName, MiddleName y LastName concatenados, con espacios de por medio.

SELECT 
	CASE
		WHEN MiddleName IS NULL THEN CONCAT(FirstName,' ',LastName)
		ELSE CONCAT(FirstName,' ',MiddleName,' ',LastName)
	END AS Nombre,    
	CASE
		WHEN Title IS NULL THEN 'No hay titulo'
		ELSE Title
	END AS Titulo
FROM Person.Person

--17.	Usando Production.Product si las columnas MakeFlag y FinishedGoodsFlag son iguales, que devuelva NULL. En caso contrario devolver ambos valores concatenados.

SELECT 
	Name,
	CASE
		WHEN MakeFlag = FinishedGoodsFlag THEN NULL
		ELSE CONCAT(MakeFlag,FinishedGoodsFlag) 
	END AS Flag
FROM Production.Product

--18.	Usando Production.Product si el valor en color es NULL devolver “Sin color”. Si el color sí está, devolver el color. Se puede hacer de por lo menos dos maneras, desarrollar ambas (buscar funciones ISNULL y COALESCE).

SELECT 
	Name,
	CASE
		WHEN Color IS NULL THEN 'Sin Color'
		ELSE Color
	END AS Color
FROM Production.Product

SELECT 
	Name,
	COALESCE(Color,'Sin color') AS Color
FROM Production.Product

SELECT 
	Name,
	ISNULL(Color,'sin color') AS Color
FROM Production.Product

---SELECT * FROM Production.Product

--19.	Traer el primer nombre y el apellido de los empleados que sean solteros. Resolverlode 3 formas diferentes: con una CTE, subquery de lista y una de tabla


---CTE
WITH Empleados AS (
	SELECT 
		p.FirstName, 
		p.LastName, 
		e.MaritalStatus 
	FROM Person.Person p
	LEFT JOIN HumanResources.Employee e
	ON p.BusinessEntityID = e.BusinessEntityID 
)

SELECT * 
FROM Empleados
WHERE MaritalStatus = 'S';

---SUBQUERY

SELECT 
	p.FirstName, 
	p.LastName
FROM Person.Person p
WHERE p.BusinessEntityID IN (SELECT BusinessEntityID FROM HumanResources.Employee WHERE MaritalStatus = 'S')

---TABLA

SELECT 
	p.FirstName, 
	p.LastName, 
	e.MaritalStatus 
FROM Person.Person p
LEFT JOIN HumanResources.Employee e
ON p.BusinessEntityID = e.BusinessEntityID 
WHERE e.MaritalStatus = 'S'

--20.	Traer tabla de empleados mayores a 30 años.

SELECT 
	p.FirstName, 
	p.LastName, 
	YEAR(GETDATE()) - YEAR(e.BirthDate) AS Edad
FROM Person.Person p
LEFT JOIN HumanResources.Employee e
ON p.BusinessEntityID = e.BusinessEntityID 
WHERE YEAR(GETDATE()) - YEAR(e.BirthDate) > 50
ORDER BY Edad 

SELECT 
	p.FirstName, 
	p.LastName, 
	DATEDIFF(YEAR, e.BirthDate,GETDATE()) AS Edad
FROM Person.Person p
LEFT JOIN HumanResources.Employee e
ON p.BusinessEntityID = e.BusinessEntityID 
WHERE DATEDIFF(YEAR, e.BirthDate,GETDATE()) > 50
ORDER BY Edad 

/*
SELECT 
	e.BusinessEntityID,
	e.BirthDate,
	--GETDATE() AS Fecha,
	YEAR(GETDATE()) - YEAR(e.BirthDate) AS Edad
FROM HumanResources.Employee e 
WHERE YEAR(GETDATE()) - YEAR(e.BirthDate) > 50

SELECT 
	MAX(e.BirthDate)
FROM HumanResources.Employee e 
*/
--21.	Indicar el número de entidad de negocio y los tres primeros números del número de identificación nacional de cada uno de los empleados. Renombrar la nueva columna como id_tres.
--Keywords: BusinessEntityId, NationalIDNumber, HumanResources.Employee.

SELECT
	BusinessEntityId, 
	NationalIDNumber,
	SUBSTRING( NationalIDNumber, 1, 3 )  AS id_tres
FROM HumanResources.Employee

--22.	Indicar el id de dirección, la línea 1 de dirección (Addressline1) y los cuatro últimos dígitos del código postal de cada dirección registrada y renombrarla postal_4. Eliminar los espacios en el inicio y el final de los valores resultantes de addressline1. 
--Keywords: addressid, Addresline1, postalcode,person.Address
--23.	Indicar el id de provincia-estado y la concatenación de los campos codigo de region-país, nombre y código de provincia-estado.  El resultado debe utilizar dos separadores: primero barra inclinada (/) y luego guión (-). Ejemplo: CA/California-CA. Renombrar la nueva columna como región. Los resultados de la nueva columna deben estar en mayúsculas. 
--Keywords: stateprovinceid, countryregioncode, name, stateprovinceid, Person.stateProvince
--24.	indicar el id de la foto producto y el nombre de archivo de foto. Reemplazar el tipo de archivo gif por jpeg en cada uno de los registros. Renombrar la nueva columna como foto. 
--Keywords: productphotoid, thumbnailphotofilename, productphoto,production.ProductPhoto
--25.	Indicar el código de unidad de medida, el nombre y el año en el que fue modificado cada registro. Renombrar la nueva columna como anio_modificacion.
--Keywords: unitmeasurecode, name, modifieddate, production.unitMeasure.
--26.	Indicar el id de tarjeta de crédito, el tipo de tarjeta y el mes en el que fue modificado cada registro almacenado para las tarjetas de crédito. Renombrar a la nueva columna Mes_modificacion. 
--Keywords: Creditcardid, cardtype, modifieddate, creditcard, sales.CreditCard.
--27.	Indicar el id del producto,la suma de la cantidad de producto y el día de la semana(ej: lunes, martes, etc) de la transacción. Ordenar descentente por id producto. Prestar atención a la agrupación para que solo aparezca un día de la semana por producto 
--Keywords: transactionid, referenceorderid, transactiondate, transactionhistoryarchive, production.TransactionHistoryArchive.
--28.	Indicar el id de orden de pedido, la fecha de inicio y cual seria la fecha de entrega, si cada orden debe ser recibida 30 días después de su inicio. Consultar para cada orden de pedido registrada. Renombrar la nueva columna como entrega_estimada.
--Keywords: workorderid, startdate, workorder, production.workOrder.
--29.	Indicar el id de orden de pedido y cuántos dias hay entre la fecha programada de inicio y la fecha programada de fin, para los id de orden comprendidos entre 72060 y 72070. Se requiere la información correspondiente a la máxima fecha de registro, sin agregar la fecha de forma manual. Renombrar la nueva columna como diferencia_dias. 
--Keywords: workorderid, scheduledstartdate, scheduledenddate, modifieddate, production.WorkOrderRouting
--30.	Para el número de orden 43659: Indicar el número de orden de venta y el número entero correspondiente al precio unitario de todos los registros de los detalles de ventas. Se requiere la información correspondiente a la mínima fecha de registro, sin agregar la condición de fecha de forma manual. Renombrar la nueva columna como precio_en_enteros. Keywords: salesorderid, unitprice, salesorderdetail, modifieddate, Sales.salesOrderDetail




