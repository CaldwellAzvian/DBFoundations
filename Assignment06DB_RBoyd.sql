--*************************************************************************--
-- Title: Assignment06
-- Author: RobertBoyd
-- Desc: This file demonstrates how to use Views
-- Change Log: When,Who,What
-- 2021-08-15,RBoyd,Created File
--**************************************************************************--
Begin Try
	Use Master;
	If Exists(Select Name From SysDatabases Where Name = 'Assignment06DB_RobertBoyd')
	 Begin 
	  Alter Database [Assignment06DB_RobertBoyd] set Single_user With Rollback Immediate;
	  Drop Database Assignment06DB_RobertBoyd;
	 End
	Create Database Assignment06DB_RobertBoyd;
End Try
Begin Catch
	Print Error_Number();
End Catch
go
Use Assignment06DB_RobertBoyd;

-- Create Tables (Module 01)-- 
Create Table Categories
([CategoryID] [int] IDENTITY(1,1) NOT NULL 
,[CategoryName] [nvarchar](100) NOT NULL
);
go

Create Table Products
([ProductID] [int] IDENTITY(1,1) NOT NULL 
,[ProductName] [nvarchar](100) NOT NULL 
,[CategoryID] [int] NULL  
,[UnitPrice] [mOney] NOT NULL
);
go

Create Table Employees -- New Table
([EmployeeID] [int] IDENTITY(1,1) NOT NULL 
,[EmployeeFirstName] [nvarchar](100) NOT NULL
,[EmployeeLastName] [nvarchar](100) NOT NULL 
,[ManagerID] [int] NULL  
);
go

Create Table Inventories
([InventoryID] [int] IDENTITY(1,1) NOT NULL
,[InventoryDate] [Date] NOT NULL
,[EmployeeID] [int] NOT NULL -- New Column
,[ProductID] [int] NOT NULL
,[Count] [int] NOT NULL
);
go

-- Add Constraints (Module 02) -- 
Begin  -- Categories
	Alter Table Categories 
	 Add Constraint pkCategories 
	  Primary Key (CategoryId);

	Alter Table Categories 
	 Add Constraint ukCategories 
	  Unique (CategoryName);
End
go 

Begin -- Products
	Alter Table Products 
	 Add Constraint pkProducts 
	  Primary Key (ProductId);

	Alter Table Products 
	 Add Constraint ukProducts 
	  Unique (ProductName);

	Alter Table Products 
	 Add Constraint fkProductsToCategories 
	  Foreign Key (CategoryId) References Categories(CategoryId);

	Alter Table Products 
	 Add Constraint ckProductUnitPriceZeroOrHigher 
	  Check (UnitPrice >= 0);
End
go

Begin -- Employees
	Alter Table Employees
	 Add Constraint pkEmployees 
	  Primary Key (EmployeeId);

	Alter Table Employees 
	 Add Constraint fkEmployeesToEmployeesManager 
	  Foreign Key (ManagerId) References Employees(EmployeeId);
End
go

Begin -- Inventories
	Alter Table Inventories 
	 Add Constraint pkInventories 
	  Primary Key (InventoryId);

	Alter Table Inventories
	 Add Constraint dfInventoryDate
	  Default GetDate() For InventoryDate;

	Alter Table Inventories
	 Add Constraint fkInventoriesToProducts
	  Foreign Key (ProductId) References Products(ProductId);

	Alter Table Inventories 
	 Add Constraint ckInventoryCountZeroOrHigher 
	  Check ([Count] >= 0);

	Alter Table Inventories
	 Add Constraint fkInventoriesToEmployees
	  Foreign Key (EmployeeId) References Employees(EmployeeId);
End 
go

-- Adding Data (Module 04) -- 
Insert Into Categories 
(CategoryName)
Select CategoryName 
 From Northwind.dbo.Categories
 Order By CategoryID;
go

Insert Into Products
(ProductName, CategoryID, UnitPrice)
Select ProductName,CategoryID, UnitPrice 
 From Northwind.dbo.Products
  Order By ProductID;
go

Insert Into Employees
(EmployeeFirstName, EmployeeLastName, ManagerID)
Select E.FirstName, E.LastName, IsNull(E.ReportsTo, E.EmployeeID) 
 From Northwind.dbo.Employees as E
  Order By E.EmployeeID;
go

Insert Into Inventories
(InventoryDate, EmployeeID, ProductID, [Count])
Select '20170101' as InventoryDate, 5 as EmployeeID, ProductID, ABS(CHECKSUM(NewId())) % 100 as RandomValue
From Northwind.dbo.Products
Union
Select '20170201' as InventoryDate, 7 as EmployeeID, ProductID, ABS(CHECKSUM(NewId())) % 100 as RandomValue
From Northwind.dbo.Products
Union
Select '20170301' as InventoryDate, 9 as EmployeeID, ProductID, ABS(CHECKSUM(NewId())) % 100 as RandomValue
From Northwind.dbo.Products
Order By 1, 2
go

-- Show the Current data in the Categories, Products, and Inventories Tables
Select * From Categories;
go
Select * From Products;
go
Select * From Employees;
go
Select * From Inventories;
go

/********************************* Questions and Answers *********************************/
/*
'NOTES------------------------------------------------------------------------------------ 
 1) You can use any name you like for you views, but be descriptive and consistent
 2) You can use your working code from assignment 5 for much of this assignment
 3) You must use the BASIC views for each table after they are created in Question 1
------------------------------------------------------------------------------------------'
*/

-- Question 1 (5% pts): How can you create BACIC views to show data from each table in the database.
-- NOTES: 1) Do not use a *, list out each column!
--        2) Create one view per table!
--		  3) Use SchemaBinding to protect the views from being orphaned!

/*
--first, lets create a select statement for each of the columns for each table that we will be putting into our views
SELECT CategoryID, CategoryName
  FROM Categories;
GO

SELECT ProductID, ProductName, CategoryID, UnitPrice
  FROM Products;
GO

SELECT EmployeeID, EmployeeFirstName, EmployeeLastName, ManagerID
  FROM Employees;
GO

SELECT InventoryID, InventoryDate, EmployeeID, ProductID, Count
  FROM Inventories;
GO
*/

--Now, we will create the views with schema binding to contain these select statements. We will need to append dbo. for the full table names
CREATE  --DROP
  VIEW vCategories
  WITH SCHEMABINDING
  AS
    SELECT CategoryID, CategoryName
      FROM dbo.Categories;
GO

CREATE  --DROP
  VIEW vProducts
  WITH SCHEMABINDING
  AS
    SELECT ProductID, ProductName, CategoryID, UnitPrice
      FROM dbo.Products;
GO

CREATE  --DROP
  VIEW vEmployees
  WITH SCHEMABINDING
  AS
    SELECT EmployeeID, EmployeeFirstName, EmployeeLastName, ManagerID
      FROM dbo.Employees;
GO

CREATE  --DROP
  VIEW vInventories
  WITH SCHEMABINDING
  AS
    SELECT InventoryID, InventoryDate, EmployeeID, ProductID, Count
      FROM dbo.Inventories;
GO

--Check work:
SELECT * FROM vCategories;
SELECT * FROM vProducts;
SELECT * FROM vEmployees;
SELECT * FROM vInventories;
GO


-- Question 2 (5% pts): How can you set permissions, so that the public group CANNOT select data 
-- from each table, but can select data from each view?

--We do this by denying selects on the tables themselves, but granting select on the views. This will force Public to use our views
--and solidify our layer of abstraction
DENY SELECT ON Categories TO Public;
GRANT SELECT ON vCategories TO Public;
DENY SELECT ON Products TO Public;
GRANT SELECT ON vProducts TO Public;
DENY SELECT ON Employees TO Public;
GRANT SELECT ON vEmployees TO Public;
DENY SELECT ON Inventories TO Public;
GRANT SELECT ON vInventories TO Public;
GO

-- Question 3 (10% pts): How can you create a view to show a list of Category and Product names, 
-- and the price of each product?
-- Order the result by the Category and Product!
/*
--Lets create our select statements first. We will have to do a join.
SELECT CategoryName
  FROM vCategories;
GO

SELECT ProductName, UnitPrice
  FROM vProducts;
GO

--Joining the two together, and adding our order by
SELECT C.CategoryName, P.ProductName, P.UnitPrice
  FROM vCategories AS C
  INNER JOIN vProducts AS P ON C.CategoryID = P.CategoryID
  ORDER BY C.CategoryName, P.ProductName;
GO
*/
--Now to put it into a view. However, in order to do an order by in a view, it must select a TOP number, else it will not work
CREATE
  VIEW vProductsByCategories
  AS
  SELECT TOP 100000 C.CategoryName, P.ProductName, P.UnitPrice
    FROM vCategories AS C
    INNER JOIN vProducts AS P
	ON C.CategoryID = P.CategoryID
    ORDER BY C.CategoryName, P.ProductName;
GO

--Check Work
SELECT * FROM vProductsByCategories;
GO
-- Here is an example of some rows selected from the view:
-- CategoryName,ProductName,UnitPrice
-- Beverages,Chai,18.00
-- Beverages,Chang,19.00
-- Beverages,Chartreuse verte,18.00


-- Question 4 (10% pts): How can you create a view to show a list of Product names 
-- and Inventory Counts on each Inventory Date?
-- Order the results by the Product, Date, and Count!
/*
--First, build our select statements
SELECT ProductName
  FROM vProducts;
GO

SELECT Count, InventoryDate
  FROM vInventories;
GO

--Do the join the put them together, and add our order by
SELECT P.ProductName, I.InventoryDate, I.Count
  FROM vProducts AS P
  INNER JOIN vInventories AS I
  ON P.ProductID = I.ProductID
  ORDER BY P.ProductName, I.InventoryDate, I.Count;
GO
*/
--Now to wrap it up in a view. We must use TOP in order to avoid it not working
CREATE
  VIEW vInventoriesByProductsByDates
  AS
    SELECT TOP 100000 P.ProductName, I.InventoryDate, I.Count
      FROM vProducts AS P
      INNER JOIN vInventories AS I
      ON P.ProductID = I.ProductID
      ORDER BY P.ProductName, I.InventoryDate, I.Count;
GO

--Checks work
SELECT * FROM vInventoriesByProductsByDates;
GO

-- Here is an example of some rows selected from the view:
--ProductName,InventoryDate,Count
--Alice Mutton,2017-01-01,15
--Alice Mutton,2017-02-01,78
--Alice Mutton,2017-03-01,83


-- Question 5 (10% pts): How can you create a view to show a list of Inventory Dates 
-- and the Employee that took the count?
-- Order the results by the Date and return only one row per date!
/*
--First, lets build our select statements
SELECT InventoryDate
  FROM vInventories;
GO
--For EmployeeName, must combine first and last name
SELECT EmployeeFirstName + ' ' + EmployeeLastName AS EmployeeName
  FROM vEmployees;
GO

--Now join them together. Additionally, select distinct and add the ordering
SELECT DISTINCT I.InventoryDate, E.EmployeeFirstName + ' ' + E.EmployeeLastName AS EmployeeName
  FROM vInventories AS I
  INNER JOIN vEmployees AS E
  ON I.EmployeeID = E.EmployeeID
  ORDER BY I.InventoryDate;
GO
*/
--Finally, must put into a view.
CREATE
  VIEW vInventoriesByEmployeesByDates
  AS
    SELECT DISTINCT TOP 100000 I.InventoryDate, E.EmployeeFirstName + ' ' + E.EmployeeLastName AS EmployeeName
      FROM vInventories AS I
      INNER JOIN vEmployees AS E
      ON I.EmployeeID = E.EmployeeID
      ORDER BY I.InventoryDate;
GO

--Checks Work
SELECT * FROM vInventoriesByEmployeesByDates;
GO

-- Here is an example of some rows selected from the view:
-- InventoryDate,EmployeeName
-- 2017-01-01,Steven Buchanan
-- 2017-02-01,Robert King
-- 2017-03-01,Anne Dodsworth


-- Question 6 (10% pts): How can you create a view show a list of Categories, Products, 
-- and the Inventory Date and Count of each product?
-- Order the results by the Category, Product, Date, and Count!

/*
--First create our select statements
SELECT CategoryName
  FROM vCategories;
GO

SELECT ProductName
  FROM vProducts;
GO

SELECT InventoryDate, Count
  FROM vInventories;
GO

--Now we must join them together. Categories and Products on CategoryID
SELECT CategoryName, ProductName
  FROM vCategories AS C
  INNER JOIN vProducts AS P
  ON C.CategoryID = P.CategoryID;
GO

--Then add inventories to it by joining on ProductID. Also add sorting
SELECT CategoryName, ProductName, InventoryDate, Count
  FROM vCategories AS C
  INNER JOIN vProducts AS P
  ON C.CategoryID = P.CategoryID
  INNER JOIN vInventories AS I
  ON P.ProductID = I.ProductID
  ORDER BY C.CategoryName, P.ProductName, I.InventoryDate, I.Count;
GO
*/

--Finally, we can put this into a view
CREATE
  VIEW vInventoriesByProductsByCategories
  AS
    SELECT TOP 100000 C.CategoryName, P.ProductName, I.InventoryDate, I.Count
      FROM vCategories AS C
      INNER JOIN vProducts AS P
      ON C.CategoryID = P.CategoryID
      INNER JOIN vInventories AS I
      ON P.ProductID = I.ProductID
      ORDER BY C.CategoryName, P.ProductName, I.InventoryDate, I.Count;
GO

--Checks work
SELECT * FROM vInventoriesByProductsByCategories;
GO

-- Here is an example of some rows selected from the view:
-- CategoryName,ProductName,InventoryDate,Count
-- Beverages,Chai,2017-01-01,72
-- Beverages,Chai,2017-02-01,52
-- Beverages,Chai,2017-03-01,54


-- Question 7 (10% pts): How can you create a view to show a list of Categories, Products, 
-- the Inventory Date and Count of each product, and the EMPLOYEE who took the count?
-- Order the results by the Inventory Date, Category, Product and Employee!

/*
--This is a continuation of the previous problem. So lets grab our previous select statement and the one from employees
SELECT C.CategoryName, P.ProductName, I.InventoryDate, I.Count
  FROM vCategories AS C
  INNER JOIN vProducts AS P
  ON C.CategoryID = P.CategoryID
  INNER JOIN vInventories AS I
  ON P.ProductID = I.ProductID
  ORDER BY C.CategoryName, P.ProductName, I.InventoryDate, I.Count;
GO

SELECT EmployeeFirstName + ' ' + EmployeeLastName AS EmployeeName
  FROM vEmployees;
GO

--Now we extend our join to include Employees on EmployeeID to get EmployeeName
SELECT C.CategoryName, P.ProductName, I.InventoryDate, I.Count, E.EmployeeFirstName + ' ' + E.EmployeeLastName AS EmployeeName
  FROM vCategories AS C
  INNER JOIN vProducts AS P
  ON C.CategoryID = P.CategoryID
  INNER JOIN vInventories AS I
  ON P.ProductID = I.ProductID
  INNER JOIN vEmployees AS E
  ON I.EmployeeID = E.EmployeeID
  ORDER BY I.InventoryDate, C.CategoryName, P.ProductName, EmployeeName;
GO
*/

--Finally, we put it into a view
CREATE
  VIEW vInventoriesByProductsByEmployees
  AS
    SELECT TOP 100000 C.CategoryName, P.ProductName, I.InventoryDate, I.Count, E.EmployeeFirstName + ' ' + E.EmployeeLastName AS EmployeeName
      FROM vCategories AS C
      INNER JOIN vProducts AS P
      ON C.CategoryID = P.CategoryID
      INNER JOIN vInventories AS I
      ON P.ProductID = I.ProductID
      INNER JOIN vEmployees AS E
      ON I.EmployeeID = E.EmployeeID
      ORDER BY I.InventoryDate, C.CategoryName, P.ProductName, EmployeeName;
GO

--Checks work
SELECT * FROM vInventoriesByProductsByEmployees;
GO

-- Here is an example of some rows selected from the view:
-- CategoryName,ProductName,InventoryDate,Count,EmployeeName
-- Beverages,Chai,2017-01-01,72,Steven Buchanan
-- Beverages,Chang,2017-01-01,46,Steven Buchanan
-- Beverages,Chartreuse verte,2017-01-01,61,Steven Buchanan


-- Question 8 (10% pts): How can you create a view to show a list of Categories, Products, 
-- the Inventory Date and Count of each product, and the Employee who took the count
-- for the Products 'Chai' and 'Chang'? 

/*
--This is an extension of the previous problem. Grabbing the previous problem's select statement. 
SELECT C.CategoryName, P.ProductName, I.InventoryDate, I.Count, E.EmployeeFirstName + ' ' + E.EmployeeLastName AS EmployeeName
  FROM vCategories AS C
  INNER JOIN vProducts AS P
  ON C.CategoryID = P.CategoryID
  INNER JOIN vInventories AS I
  ON P.ProductID = I.ProductID
  INNER JOIN vEmployees AS E
  ON I.EmployeeID = E.EmployeeID
  ORDER BY I.InventoryDate, C.CategoryName, P.ProductName, EmployeeName;
GO

--We need to restrict this to only 'Chai' and 'Chang'
SELECT C.CategoryName, P.ProductName, I.InventoryDate, I.Count, E.EmployeeFirstName + ' ' + E.EmployeeLastName AS EmployeeName
  FROM vCategories AS C
  INNER JOIN vProducts AS P
  ON C.CategoryID = P.CategoryID
  INNER JOIN vInventories AS I
  ON P.ProductID = I.ProductID
  INNER JOIN vEmployees AS E
  ON I.EmployeeID = E.EmployeeID
  WHERE P.ProductID IN (
    SELECT ProductID
	  FROM vProducts
	  WHERE ProductName
	  IN ('Chai', 'Chang')
  )
  ORDER BY I.InventoryDate, C.CategoryName, P.ProductName, EmployeeName;
GO
*/

--Now we can put this in a view 
CREATE
  VIEW vInventoriesForChaiAndChangByEmployees
  AS
    SELECT TOP 100000 C.CategoryName, P.ProductName, I.InventoryDate, I.Count, E.EmployeeFirstName + ' ' + E.EmployeeLastName AS EmployeeName
      FROM vCategories AS C
      INNER JOIN vProducts AS P
      ON C.CategoryID = P.CategoryID
      INNER JOIN vInventories AS I
      ON P.ProductID = I.ProductID
      INNER JOIN vEmployees AS E
      ON I.EmployeeID = E.EmployeeID
      WHERE P.ProductID IN (
        SELECT ProductID
	      FROM vProducts
	      WHERE ProductName
	      IN ('Chai', 'Chang')
      )
      ORDER BY I.InventoryDate, C.CategoryName, P.ProductName, EmployeeName;
GO

--Checks work
SELECT * FROM vInventoriesForChaiAndChangByEmployees;
GO

-- Here is an example of some rows selected from the view:
-- CategoryName,ProductName,InventoryDate,Count,EmployeeName
-- Beverages,Chai,2017-01-01,72,Steven Buchanan
-- Beverages,Chang,2017-01-01,46,Steven Buchanan
-- Beverages,Chai,2017-02-01,52,Robert King


-- Question 9 (10% pts): How can you create a view to show a list of Employees and the Manager who manages them?
-- Order the results by the Manager's name!
/*
--This is a self join. To show what we want to begin with:
SELECT ManagerID, EmployeeFirstName + ' ' + EmployeeLastName AS Employee
  FROM vEmployees
GO

--But we'll need to join it on itself to get manager name. Lets also add sort order by Manager's Name
SELECT M.EmployeeFirstName + ' ' + M.EmployeeLastName AS Manager, E.EmployeeFirstName + ' ' + E.EmployeeLastName AS Employee
  FROM vEmployees AS E
  INNER JOIN vEmployees AS M
  ON E.ManagerID = M.EmployeeID
  ORDER BY Manager, Employee;
GO
*/
--Finally, we will want to put this into a view:
CREATE
  VIEW vEmployeesByManager
  AS
    SELECT TOP 100000 M.EmployeeFirstName + ' ' + M.EmployeeLastName AS Manager, E.EmployeeFirstName + ' ' + E.EmployeeLastName AS Employee
      FROM vEmployees AS E
      INNER JOIN vEmployees AS M
      ON E.ManagerID = M.EmployeeID
      ORDER BY Manager, Employee;
GO

--Checks work
SELECT * FROM vEmployeesByManager;
GO

-- Here is an example of some rows selected from the view:
-- Manager,Employee
-- Andrew Fuller,Andrew Fuller
-- Andrew Fuller,Janet Leverling
-- Andrew Fuller,Laura Callahan

-- Question 10 (20% pts): How can you create one view to show all the data from all four 
-- BASIC Views?
/*
--This will be a composite of all of the basic views. To do so, we must do a lot of joins
--First join: Categories on Products via CategoryID
SELECT C.CategoryID, C.CategoryName, P.ProductID, P.ProductName, P.UnitPrice
  FROM vCategories AS C
  INNER JOIN vProducts AS P
  ON C.CategoryID = P.CategoryID
GO
--Next join: Products on Inventories via ProductID
SELECT C.CategoryID, C.CategoryName, P.ProductID, P.ProductName, P.UnitPrice, I.InventoryID, I.InventoryDate, I.Count
  FROM vCategories AS C
  INNER JOIN vProducts AS P
  ON C.CategoryID = P.CategoryID
  INNER JOIN vInventories AS I
  ON P.ProductID = I.ProductID;
GO
--Next join: Inventories on Employees via EmployeeID
SELECT C.CategoryID, C.CategoryName, P.ProductID, P.ProductName, P.UnitPrice, I.InventoryID, I.InventoryDate, I.Count, E.EmployeeID,
  E.EmployeeFirstName + ' ' + E.EmployeeLastName AS Employee
  FROM vCategories AS C
  INNER JOIN vProducts AS P
  ON C.CategoryID = P.CategoryID
  INNER JOIN vInventories AS I
  ON P.ProductID = I.ProductID
  INNER JOIN vEmployees AS E
  ON I.EmployeeID = E.EmployeeID;
GO
--Final join: on Employees again to get manager name
SELECT C.CategoryID, C.CategoryName, P.ProductID, P.ProductName, P.UnitPrice, I.InventoryID, I.InventoryDate, I.Count, E.EmployeeID,
  E.EmployeeFirstName + ' ' + E.EmployeeLastName AS Employee, M.EmployeeFirstName + ' ' + M.EmployeeLastName AS Manager
  FROM vCategories AS C
  INNER JOIN vProducts AS P
  ON C.CategoryID = P.CategoryID
  INNER JOIN vInventories AS I
  ON P.ProductID = I.ProductID
  INNER JOIN vEmployees AS E
  ON I.EmployeeID = E.EmployeeID
  INNER JOIN vEmployees AS M
  ON E.ManagerID = M.EmployeeID;
GO
*/
--With all of this compiled, we can finally put together our last view
CREATE
  VIEW vInventoriesByProductsByCategoriesByEmployees
  AS
    SELECT TOP 100000 C.CategoryID, C.CategoryName, P.ProductID, P.ProductName, P.UnitPrice, I.InventoryID, I.InventoryDate, I.Count, E.EmployeeID,
      E.EmployeeFirstName + ' ' + E.EmployeeLastName AS Employee, M.EmployeeFirstName + ' ' + M.EmployeeLastName AS Manager
      FROM vCategories AS C
      INNER JOIN vProducts AS P
      ON C.CategoryID = P.CategoryID
      INNER JOIN vInventories AS I
      ON P.ProductID = I.ProductID
      INNER JOIN vEmployees AS E
      ON I.EmployeeID = E.EmployeeID
      INNER JOIN vEmployees AS M
      ON E.ManagerID = M.EmployeeID
	  ORDER BY C.CategoryName, P.ProductName, I.InventoryDate, Manager, Employee
GO

--Checks work
SELECT * FROM vInventoriesByProductsByCategoriesByEmployees;
GO

-- Here is an example of some rows selected from the view:
-- CategoryID,CategoryName,ProductID,ProductName,UnitPrice,InventoryID,InventoryDate,Count,EmployeeID,Employee,Manager
-- 1,Beverages,1,Chai,18.00,1,2017-01-01,72,5,Steven Buchanan,Andrew Fuller
-- 1,Beverages,1,Chai,18.00,78,2017-02-01,52,7,Robert King,Steven Buchanan
-- 1,Beverages,1,Chai,18.00,155,2017-03-01,54,9,Anne Dodsworth,Steven Buchanan

-- Test your Views (NOTE: You must change the names to match yours as needed!)

Select * From [dbo].[vCategories]
Select * From [dbo].[vProducts]
Select * From [dbo].[vInventories]
Select * From [dbo].[vEmployees]

Select * From [dbo].[vProductsByCategories]
Select * From [dbo].[vInventoriesByProductsByDates]
Select * From [dbo].[vInventoriesByEmployeesByDates]
Select * From [dbo].[vInventoriesByProductsByCategories]
Select * From [dbo].[vInventoriesByProductsByEmployees]
Select * From [dbo].[vInventoriesForChaiAndChangByEmployees]
Select * From [dbo].[vEmployeesByManager]
Select * From [dbo].[vInventoriesByProductsByCategoriesByEmployees]

/***************************************************************************************/