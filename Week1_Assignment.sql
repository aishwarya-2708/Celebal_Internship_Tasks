/*
Aishwarya Ashok Patil 
User ID :  CT_CSI_SQ_3376

Level A : SQL Queries Assignment 
*/

/*1. List of all customers*/
USE AdventureWorks2017;
GO

SELECT 
    c.CustomerID,
    s.Name AS StoreName,
    p.FirstName,
    p.LastName,
    e.EmailAddress,
    ph.PhoneNumber
FROM Sales.Customer AS c
JOIN Sales.Store AS s ON c.StoreID = s.BusinessEntityID
JOIN Person.BusinessEntityContact AS bec ON s.BusinessEntityID = bec.BusinessEntityID
JOIN Person.Person AS p ON bec.PersonID = p.BusinessEntityID
LEFT JOIN Person.EmailAddress AS e ON p.BusinessEntityID = e.BusinessEntityID
LEFT JOIN Person.PersonPhone AS ph ON p.BusinessEntityID = ph.BusinessEntityID;

/*2.List of all customers where company name ends in N:*/

SELECT *
FROM Sales.Customer c
JOIN Sales.Store s ON c.StoreID = s.BusinessEntityID
WHERE s.Name LIKE '%N';

/*3.  List of all customers who live in Berlin or London:*/

SELECT DISTINCT p.FirstName, p.LastName, a.City
FROM Person.Person p
JOIN Person.BusinessEntityAddress bea ON p.BusinessEntityID = bea.BusinessEntityID
JOIN Person.Address a ON bea.AddressID = a.AddressID
WHERE a.City IN ('Berlin', 'London');

/*4. List of all customers who live in UK or USA:*/
SELECT DISTINCT p.FirstName, p.LastName, sp.Name AS Country
FROM Person.Person p
JOIN Person.BusinessEntityAddress bea ON p.BusinessEntityID = bea.BusinessEntityID
JOIN Person.Address a ON bea.AddressID = a.AddressID
JOIN Person.StateProvince sp ON a.StateProvinceID = sp.StateProvinceID
JOIN Person.CountryRegion cr ON sp.CountryRegionCode = cr.CountryRegionCode
WHERE cr.Name IN ('United Kingdom', 'United States');

/*5. List of all products sorted by product name:*/
SELECT Name
FROM Production.Product
ORDER BY Name;

/*6.List of all products where product name starts with an A:*/
SELECT *
FROM Production.Product
WHERE Name LIKE 'A%';

/*7. List of customers who ever placed an order:*/
SELECT DISTINCT c.CustomerID, p.FirstName, p.LastName
FROM Sales.SalesOrderHeader soh
JOIN Sales.Customer c ON soh.CustomerID = c.CustomerID
JOIN Person.Person p ON c.PersonID = p.BusinessEntityID;


/*8.List of customers who live in London and have bought Chai:*/
SELECT DISTINCT p.FirstName, p.LastName
FROM Sales.SalesOrderHeader soh
JOIN Sales.SalesOrderDetail sod ON soh.SalesOrderID = sod.SalesOrderID
JOIN Production.Product prod ON sod.ProductID = prod.ProductID
JOIN Sales.Customer c ON soh.CustomerID = c.CustomerID
JOIN Person.Person p ON c.PersonID = p.BusinessEntityID
JOIN Person.BusinessEntityAddress bea ON p.BusinessEntityID = bea.BusinessEntityID
JOIN Person.Address a ON bea.AddressID = a.AddressID
WHERE a.City = 'London'
  AND prod.Name = 'Chai';  -- Replace 'Chai' if not found


/*9. List of customers who never placed an order:*/
SELECT p.FirstName, p.LastName
FROM Sales.Customer c
JOIN Person.Person p ON c.PersonID = p.BusinessEntityID
WHERE c.CustomerID NOT IN (
    SELECT DISTINCT CustomerID
    FROM Sales.SalesOrderHeader
);


/*10.  List of customers who ordered Tofu:*/
SELECT DISTINCT p.FirstName, p.LastName
FROM Sales.SalesOrderHeader soh
JOIN Sales.SalesOrderDetail sod ON soh.SalesOrderID = sod.SalesOrderID
JOIN Production.Product prod ON sod.ProductID = prod.ProductID
JOIN Sales.Customer c ON soh.CustomerID = c.CustomerID
JOIN Person.Person p ON c.PersonID = p.BusinessEntityID
WHERE prod.Name = 'Tofu';  -- Replace 'Tofu' if not found


/*11.Details of first order of the system:*/
SELECT TOP 1 *
FROM Sales.SalesOrderHeader
ORDER BY OrderDate ASC;


/*12. Details of most expensive order date:*/
SELECT TOP 1 OrderDate, TotalDue
FROM Sales.SalesOrderHeader
ORDER BY TotalDue DESC;


/*13. For each order, get the OrderID and Average quantity:*/
SELECT SalesOrderID, AVG(OrderQty) AS AvgQuantity
FROM Sales.SalesOrderDetail
GROUP BY SalesOrderID;


/*14. For each order, get OrderID, Min, and Max quantity:*/
SELECT SalesOrderID, MIN(OrderQty) AS MinQty, MAX(OrderQty) AS MaxQty
FROM Sales.SalesOrderDetail
GROUP BY SalesOrderID;


/*15. List of all managers and total employees reporting to them:*/
SELECT 
    manager.BusinessEntityID AS ManagerID,
    p.FirstName + ' ' + p.LastName AS ManagerName,
    COUNT(emp.BusinessEntityID) AS ReportCount
FROM HumanResources.Employee AS emp
JOIN HumanResources.Employee AS manager
    ON emp.OrganizationNode.GetAncestor(1) = manager.OrganizationNode
JOIN Person.Person AS p
    ON manager.BusinessEntityID = p.BusinessEntityID
GROUP BY manager.BusinessEntityID, p.FirstName, p.LastName
ORDER BY ReportCount DESC;



/* 16. Orders with total quantity > 300:*/
SELECT SalesOrderID, SUM(OrderQty) AS TotalQty
FROM Sales.SalesOrderDetail
GROUP BY SalesOrderID
HAVING SUM(OrderQty) > 300;


/*17. Orders placed on or after 1996-12-31:*/
SELECT *
FROM Sales.SalesOrderHeader
WHERE OrderDate >= '1996-12-31';


/*18. Orders shipped to Canada:*/
SELECT soh.*
FROM Sales.SalesOrderHeader soh
JOIN Person.Address a ON soh.ShipToAddressID = a.AddressID
JOIN Person.StateProvince sp ON a.StateProvinceID = sp.StateProvinceID
JOIN Person.CountryRegion cr ON sp.CountryRegionCode = cr.CountryRegionCode
WHERE cr.Name = 'Canada';


/* 19. Orders with order total > 200:*/
SELECT *
FROM Sales.SalesOrderHeader
WHERE TotalDue > 200;


/* 20. Countries and sales made in each:*/
SELECT cr.Name AS Country, SUM(soh.TotalDue) AS TotalSales
FROM Sales.SalesOrderHeader soh
JOIN Person.Address a ON soh.BillToAddressID = a.AddressID
JOIN Person.StateProvince sp ON a.StateProvinceID = sp.StateProvinceID
JOIN Person.CountryRegion cr ON sp.CountryRegionCode = cr.CountryRegionCode
GROUP BY cr.Name
ORDER BY TotalSales DESC;


/*21. List of Customer ContactName and number of orders they placed*/
SELECT 
    p.FirstName + ' ' + p.LastName AS ContactName,
    COUNT(soh.SalesOrderID) AS OrderCount
FROM Sales.SalesOrderHeader AS soh
JOIN Sales.Customer AS c ON soh.CustomerID = c.CustomerID
JOIN Person.Person AS p ON c.PersonID = p.BusinessEntityID
GROUP BY p.FirstName, p.LastName
ORDER BY OrderCount DESC;


/*22. List of customer contact names who have placed more than 3 orders*/

USE AdventureWorks2017;
GO

SELECT 
    p.FirstName + ' ' + p.LastName AS ContactName,
    COUNT(soh.SalesOrderID) AS OrderCount
FROM Sales.Customer AS c
JOIN Person.Person AS p ON c.PersonID = p.BusinessEntityID
JOIN Sales.SalesOrderHeader AS soh ON c.CustomerID = soh.CustomerID
GROUP BY p.FirstName, p.LastName
HAVING COUNT(soh.SalesOrderID) > 3
ORDER BY OrderCount DESC;


/*23. List of discontinued products which were ordered between 1/1/1997 and 1/1/1998*/
SELECT DISTINCT p.Name
FROM Production.Product AS p
JOIN Sales.SalesOrderDetail AS sod ON p.ProductID = sod.ProductID
JOIN Sales.SalesOrderHeader AS soh ON sod.SalesOrderID = soh.SalesOrderID
WHERE p.SellEndDate IS NOT NULL
  AND soh.OrderDate BETWEEN '1997-01-01' AND '1998-01-01';

/*24. List of employee first name, last name, supervisor first name, last name*/
SELECT 
    e.BusinessEntityID AS EmployeeID,
    ep.FirstName AS EmployeeFirstName,
    ep.LastName AS EmployeeLastName,
    mp.FirstName AS SupervisorFirstName,
    mp.LastName AS SupervisorLastName
FROM HumanResources.Employee e
LEFT JOIN HumanResources.Employee m 
    ON e.OrganizationNode.GetAncestor(1) = m.OrganizationNode
LEFT JOIN Person.Person ep 
    ON e.BusinessEntityID = ep.BusinessEntityID
LEFT JOIN Person.Person mp 
    ON m.BusinessEntityID = mp.BusinessEntityID
ORDER BY ep.LastName, ep.FirstName;

/*25. List of Employees ID and total sales conducted by employee*/
SELECT 
    e.BusinessEntityID AS EmployeeID,
    p.FirstName,
    p.LastName,
    SUM(soh.TotalDue) AS TotalSales
FROM HumanResources.Employee AS e
JOIN Person.Person AS p ON e.BusinessEntityID = p.BusinessEntityID
JOIN Sales.SalesPerson AS sp ON e.BusinessEntityID = sp.BusinessEntityID
JOIN Sales.SalesOrderHeader AS soh ON sp.BusinessEntityID = soh.SalesPersonID
GROUP BY e.BusinessEntityID, p.FirstName, p.LastName
ORDER BY TotalSales DESC;

/*26. List of employees whose first name contains character 'a'*/
SELECT 
    p.FirstName,
    p.LastName
FROM HumanResources.Employee AS e
JOIN Person.Person AS p ON e.BusinessEntityID = p.BusinessEntityID
WHERE p.FirstName LIKE '%a%';

/*27. List of managers who have more than four people reporting to them*/
SELECT 
    m.BusinessEntityID AS ManagerID,
    p.FirstName + ' ' + p.LastName AS ManagerName,
    COUNT(e.BusinessEntityID) AS ReportCount
FROM HumanResources.Employee AS e
JOIN HumanResources.Employee AS m ON e.OrganizationNode.GetAncestor(1) = m.OrganizationNode
JOIN Person.Person AS p ON m.BusinessEntityID = p.BusinessEntityID
GROUP BY m.BusinessEntityID, p.FirstName, p.LastName
HAVING COUNT(e.BusinessEntityID) > 4;

/*28. List of Orders and Product Names*/
SELECT 
    soh.SalesOrderID,
    p.Name AS ProductName
FROM Sales.SalesOrderHeader AS soh
JOIN Sales.SalesOrderDetail AS sod ON soh.SalesOrderID = sod.SalesOrderID
JOIN Production.Product AS p ON sod.ProductID = p.ProductID
ORDER BY soh.SalesOrderID;

/*29. List of orders placed by the best customer. Assuming 'best customer' is the one with the highest total purchase amount.*/
WITH CustomerTotal AS (
    SELECT 
        soh.CustomerID,
        SUM(soh.TotalDue) AS TotalPurchase
    FROM Sales.SalesOrderHeader AS soh
    GROUP BY soh.CustomerID
)
SELECT 
    soh.SalesOrderID,
    soh.OrderDate,
    soh.TotalDue
FROM Sales.SalesOrderHeader AS soh
JOIN CustomerTotal AS ct ON soh.CustomerID = ct.CustomerID
WHERE ct.TotalPurchase = (SELECT MAX(TotalPurchase) FROM CustomerTotal);

/*30. List of orders placed by customers who do not have a Fax number*/
SELECT 
    soh.SalesOrderID,
    soh.OrderDate,
    soh.TotalDue
FROM Sales.SalesOrderHeader AS soh
JOIN Sales.Customer AS c ON soh.CustomerID = c.CustomerID
JOIN Person.Person AS p ON c.PersonID = p.BusinessEntityID
LEFT JOIN Person.PersonPhone AS pp ON p.BusinessEntityID = pp.BusinessEntityID
WHERE pp.PhoneNumber IS NULL;

/*31. List of postal codes where the product 'Tofu' was shipped
Note: 'Tofu' is not a product in AdventureWorks. Replace 'Tofu' with an actual product name from the database.
*/
SELECT DISTINCT a.PostalCode
FROM Sales.SalesOrderHeader AS soh
JOIN Sales.SalesOrderDetail AS sod ON soh.SalesOrderID = sod.SalesOrderID
JOIN Production.Product AS p ON sod.ProductID = p.ProductID
JOIN Person.Address AS a ON soh.ShipToAddressID = a.AddressID
WHERE p.Name = 'HL Mountain Front Wheel';

/*32. List of product names that were shipped to France*/
SELECT DISTINCT p.Name AS ProductName
FROM Sales.SalesOrderHeader AS soh
JOIN Sales.SalesOrderDetail AS sod ON soh.SalesOrderID = sod.SalesOrderID
JOIN Production.Product AS p ON sod.ProductID = p.ProductID
JOIN Person.Address AS a ON soh.ShipToAddressID = a.AddressID
JOIN Person.StateProvince AS sp ON a.StateProvinceID = sp.StateProvinceID
JOIN Person.CountryRegion AS cr ON sp.CountryRegionCode = cr.CountryRegionCode
WHERE cr.Name = 'France';

/*33. List of product names and categories for the supplier 'Specialty Biscuits, Ltd.'
Note: 'Specialty Biscuits, Ltd.' is not a vendor in AdventureWorks. Replace with an actual vendor name from the database.
*/
SELECT DISTINCT p.Name AS ProductName, pc.Name AS CategoryName
FROM Production.Product AS p
JOIN Production.ProductSubcategory AS psc ON p.ProductSubcategoryID = psc.ProductSubcategoryID
JOIN Production.ProductCategory AS pc ON psc.ProductCategoryID = pc.ProductCategoryID
JOIN Purchasing.ProductVendor AS pv ON p.ProductID = pv.ProductID
JOIN Purchasing.Vendor AS v ON pv.BusinessEntityID = v.BusinessEntityID
WHERE v.Name = 'Specialty Biscuits, Ltd.'; -- Replace with actual vendor name

/*34. List of products that were never ordered*/
SELECT p.Name AS ProductName
FROM Production.Product AS p
LEFT JOIN Sales.SalesOrderDetail AS sod ON p.ProductID = sod.ProductID
WHERE sod.ProductID IS NULL;

/*35. List of products where units in stock is less than 10 and units on order are 0
Note: AdventureWorks does not have 'UnitsInStock' or 'UnitsOnOrder' fields. Adjust the criteria based on available inventory fields.
*/
SELECT p.Name AS ProductName
FROM Production.Product AS p
WHERE p.SafetyStockLevel < 10 AND p.ReorderPoint = 0;

/*36. List of top 10 countries by sales*/
SELECT TOP 10 
    cr.Name AS Country,
    SUM(soh.TotalDue) AS TotalSales
FROM Sales.SalesOrderHeader AS soh
JOIN Person.Address AS a ON soh.BillToAddressID = a.AddressID
JOIN Person.StateProvince AS sp ON a.StateProvinceID = sp.StateProvinceID
JOIN Person.CountryRegion AS cr ON sp.CountryRegionCode = cr.CountryRegionCode
GROUP BY cr.Name
ORDER BY TotalSales DESC;

/*37. Number of orders each employee has taken for customers with CustomerIDs between 'A' and 'AO'
Note: CustomerID is an integer in AdventureWorks. Adjust the criteria accordingly.
*/
SELECT 
    e.BusinessEntityID AS EmployeeID,
    p.FirstName,
    p.LastName,
    COUNT(soh.SalesOrderID) AS OrderCount
FROM HumanResources.Employee AS e
JOIN Person.Person AS p ON e.BusinessEntityID = p.BusinessEntityID
JOIN Sales.SalesPerson AS sp ON e.BusinessEntityID = sp.BusinessEntityID
JOIN Sales.SalesOrderHeader AS soh ON sp.BusinessEntityID = soh.SalesPersonID
JOIN Sales.Customer AS c ON soh.CustomerID = c.CustomerID
WHERE c.CustomerID BETWEEN 1 AND 100
GROUP BY e.BusinessEntityID, p.FirstName, p.LastName
ORDER BY OrderCount DESC;

/*38. Order date of the most expensive order*/
SELECT TOP 1 OrderDate, TotalDue
FROM Sales.SalesOrderHeader
ORDER BY TotalDue DESC;

/*39. Product name and total revenue from that product*/
SELECT 
    p.Name AS ProductName,
    SUM(sod.LineTotal) AS TotalRevenue
FROM Production.Product AS p
JOIN Sales.SalesOrderDetail AS sod ON p.ProductID = sod.ProductID
GROUP BY p.Name
ORDER BY TotalRevenue DESC;

/*40. Supplier ID and number of products offered*/
SELECT 
    v.BusinessEntityID AS SupplierID,
    COUNT(pv.ProductID) AS NumberOfProducts
FROM Purchasing.Vendor AS v
JOIN Purchasing.ProductVendor AS pv ON v.BusinessEntityID = pv.BusinessEntityID
GROUP BY v.BusinessEntityID
ORDER BY NumberOfProducts DESC;

/*41.Top ten customers based on their business (revenue)*/
SELECT TOP 10 
    c.CustomerID,
    p.FirstName + ' ' + p.LastName AS CustomerName,
    SUM(soh.TotalDue) AS TotalRevenue
FROM Sales.Customer AS c
JOIN Person.Person AS p ON c.PersonID = p.BusinessEntityID
JOIN Sales.SalesOrderHeader AS soh ON c.CustomerID = soh.CustomerID
GROUP BY c.CustomerID, p.FirstName, p.LastName
ORDER BY TotalRevenue DESC;

/*42.Total revenue of the company*/
SELECT 
    SUM(TotalDue) AS TotalCompanyRevenue
FROM Sales.SalesOrderHeader;