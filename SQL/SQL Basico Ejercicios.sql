-- SQL BASICO

--1.	Seleccionar todos los registros de la tabla Persons

SELECT *
FROM Person.Person

--2.	Seleccionar todos los registros de la tabla Address

SELECT *
FROM Person.Address

--3.	Seleccionar todos los registros de la tabla Employee

SELECT *
FROM HumanResources.Employee

--4.	Seleccionar las columnas FirstName, MiddleName y LastName de la tabla Persons

SELECT FirstName, MiddleName, LastName
FROM Person.Person

--5.	Seleccionar los valores únicos de la columna City de la tabla Adress

SELECT DISTINCT City
FROM Person.Address

--6.	Seleccionar las primeras 10 filas de la tabla Persons

SELECT TOP 10 *
FROM Person.Person

--7.	Traer las 100 primeras filas de Production.Product donde el ListPrice no es 0

SELECT TOP 100 *
FROM Production.Product
WHERE ListPrice != 0

--8.	Seleccionar las columnas FirstName, MiddleName y LastName de la tabla Persons, con los nombre PrimerNombre, SegundoNombre y Apellido respectivamente

SELECT 
     FirstName AS PrimerNombre, 
     MiddleName AS SegundoNombre,
     LastName AS Apellido
FROM Person.Person     

--9.	Indicar el nombre de los productos (bicicletas) que sean de color negro.

SELECT *
FROM Production.Product
WHERE ProductSubcategoryID IN (1,2,3) AND
      Color = 'Black'
      

--10.	Indicar el nombre de los productos (bicicletas) que sean de color negro, su precio de lista sea mayor a 500, el tamaño de la rueda esté entre 40 y 58, y que su número de producto inicie con “BK”

SELECT Name, Color, ListPrice, Size, ProductNumber, ProductSubcategoryID 
FROM Production.Product
WHERE ProductSubcategoryID IN (1,2,3) AND
      Color = 'Black' AND
      ListPrice > 500 AND
      Size BETWEEN 40 AND 58 AND
      ProductNumber LIKE 'BK%' 
      
SELECT * 
FROM Production.ProductSubCategory
WHERE ProductCategoryID IN (SELECT ProductCategoryID FROM Production.ProductCategory WHERE Name = 'Bikes')

SELECT * 
FROM Production.ProductCategory

--11.	Indicar qué personas son empleados en una nueva columna llamada “IsEmployee”. La condición para que una persona sea empleado es que el tipo de persona sea EM (empleado) o SP (sales person). En caso de que sea empleado la columna debe tener el valor “SI”, en caso contrario “NO”.
      
---SELECT * FROM PErson.Person
      
SELECT FirstName, LastName, PersonType,
      CASE WHEN PersonType IN ('EM','SP') THEN 'SI'
           ELSE 'NO'
       END AS IsEmployee
FROM Person.Person
      
--12.	Indicar el nombre y el apellido de todas aquellas personas que no tengan segundo nombre.

SELECT FirstName, LastName
FROM Person.Person
WHERE MiddleName IS NULL
