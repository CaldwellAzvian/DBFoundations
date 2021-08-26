--*************************************************************************--
-- Title: Assignment07
-- Author: RobertBoyd
-- Desc: This file demonstrates how to use Functions
-- Change Log: When,Who,What
-- 2021-08-21,RobertBoyd,Created File
-- 2021-08-25,RobertBoyd,Final Adjustments
--**************************************************************************--
Begin Try
	Use Master;
	If Exists(Select Name From SysDatabases Where Name = 'Assignment07DB_RobertBoyd')
	 Begin 
	  Alter Database [Assignment07DB_RobertBoyd] set Single_user With Rollback Immediate;
	  Drop Database Assignment07DB_RobertBoyd;
	 End
	Create Database Assignment07DB_RobertBoyd;
End Try
Begin Catch
	Print Error_Number();
End Catch
go
Use Assignment07DB_RobertBoyd;

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
,[UnitPrice] [money] NOT NULL
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
,[EmployeeID] [int] NOT NULL
,[ProductID] [int] NOT NULL
,[ReorderLevel] int NOT NULL -- New Column 
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
(InventoryDate, EmployeeID, ProductID, ReorderLevel, [Count])
Select '20170101' as InventoryDate, 5 as EmployeeID, ProductID, ReorderLevel, ABS(CHECKSUM(NewId())) % 100 as RandomValue
From Northwind.dbo.Products
Union
Select '20170201' as InventoryDate, 7 as EmployeeID, ProductID, ReorderLevel, ABS(CHECKSUM(NewId())) % 100 as RandomValue
From Northwind.dbo.Products
Union
Select '20170301' as InventoryDate, 9 as EmployeeID, ProductID, ReorderLevel, ABS(CHECKSUM(NewId())) % 100 as RandomValue
From Northwind.dbo.Products
Order By 1, 2
go

-- Adding Views (Module 06) -- 
Create View vCategories With SchemaBinding
 AS
  Select CategoryID, CategoryName From dbo.Categories;
go
Create View vProducts With SchemaBinding
 AS
  Select ProductID, ProductName, CategoryID, UnitPrice From dbo.Products;
go
Create View vEmployees With SchemaBinding
 AS
  Select EmployeeID, EmployeeFirstName, EmployeeLastName, ManagerID From dbo.Employees;
go
Create View vInventories With SchemaBinding 
 AS
  Select InventoryID, InventoryDate, EmployeeID, ProductID, ReorderLevel, [Count] From dbo.Inventories;
go

-- Show the Current data in the Categories, Products, and Inventories Tables
Select * From vCategories;
go
Select * From vProducts;
go
Select * From vEmployees;
go
Select * From vInventories;
go

/********************************* Questions and Answers *********************************/
/*
'NOTES------------------------------------------------------------------------------------ 
 1) You must use the BASIC views for each table.
 2) Remember that Inventory Counts are Randomly Generated. So, your counts may not match mine
 3) To make sure the Dates are sorted correctly, you can use Functions in the Order By clause!
------------------------------------------------------------------------------------------'
*/

-- Question 1 (5% of pts): What built-in SQL Server function can you use to show a list 
-- of Product names, and the price of each product, with the price formatted as US dollars?
-- Order the result by the product!

/*
--The function we want to use is the Format function with the parameters of: UnitPrice, 'C', 'en-US'
--First, let's build our select statement, and apply our order by
SELECT ProductName, UnitPrice
  FROM vProducts
  ORDER BY ProductName;
GO
*/

--Now we can use the Format function to change the price into USD.
--We will apply this function to the unit price, but as a result we will also need to use an alias
SELECT ProductName, FORMAT(UnitPrice, 'C', 'en-US') AS UnitPrice
  FROM vProducts
  ORDER BY ProductName;
GO


-- Question 2 (10% of pts): What built-in SQL Server function can you use to show a list 
-- of Category and Product names, and the price of each product, 
-- with the price formatted as US dollars?
-- Order the result by the Category and Product!

/*
--The function we want to use is the Format function with the parameters of: UnitPrice, 'C', 'en-US'
--First, building our select statements
SELECT C.CategoryName
  FROM vCategories AS C
  ORDER BY C.CategoryName;
GO

SELECT P.ProductName, P.UnitPrice
  FROM vProducts AS P
  ORDER BY P.ProductName;
GO

--Now lets join them together
SELECT C.CategoryName, P.ProductName, P.UnitPrice
  FROM vCategories AS C
  INNER JOIN vProducts AS P ON
  C.CategoryID = P.CategoryID
  ORDER BY C.CategoryName, P.ProductName;
GO
*/

--Lastly, lets use the Format function like we were doing before to make it so that UnitPrice is displayed in USD
SELECT C.CategoryName, P.ProductName, FORMAT(P.UnitPrice, 'C', 'en-US') AS UnitPrice
  FROM vCategories AS C
  INNER JOIN vProducts AS P ON
  C.CategoryID = P.CategoryID
  ORDER BY C.CategoryName, P.ProductName, P.UnitPrice;
GO

-- Question 3 (10% of pts): What built-in SQL Server function can you use to show a list 
-- of Product names, each Inventory Date, and the Inventory Count,
-- with the date formatted like "January, 2017?" 
-- Order the results by the Product, Date, and Count!

/*
--The functions we want to use is DateName and Year put together in a string.
--First, building out select statements:
SELECT P.ProductName
  FROM vProducts as P
  ORDER BY P.ProductName;
GO

SELECT I.InventoryDate, I.Count
  FROM vInventories AS I
  ORDER BY I.InventoryDate, I.Count;
GO

--Then joining them together
SELECT P.ProductName, I.InventoryDate, I.Count
  FROM vProducts AS P
  INNER JOIN vInventories AS I ON
  P.ProductID = I.ProductID
  ORDER BY P.ProductName, I.InventoryDate, I.Count;
GO

--Here is what I am thinking I need to use for functions to get the date to display correctly. However, there is some extra space being put before
--the year of 2017. I will use an LTRIM to get rid of it in the final version
SELECT DATENAME(mm,I.InventoryDate) + ', ' + STR(YEAR(I.InventoryDate)) AS InventoryDate
  FROM Inventories AS I;
GO

--Now we want to apply our function package to create the correct display, using the aforementioned LTRIM as well. However, this is still the wrong approach:
--I will want to sort it by the chronological date, not the alphabetical result we get from the display, so I must change my order by back to using the raw date.
SELECT P.ProductName, DATENAME(mm,I.InventoryDate) + ', ' + LTRIM(STR(YEAR(I.InventoryDate))) AS InventoryDate, I.Count
  FROM vProducts AS P
  INNER JOIN vInventories AS I ON
  P.ProductID = I.ProductID
  ORDER BY P.ProductName, DATENAME(mm,I.InventoryDate) + ', ' + LTRIM(STR(YEAR(I.InventoryDate))), I.Count;
GO


--Below is the final product with the column name adjusted to match that of the output
SELECT P.ProductName, DATENAME(mm,I.InventoryDate) + ', ' + LTRIM(STR(YEAR(I.InventoryDate))) AS InventoryDate, I.Count AS InventoryCount
  FROM vProducts AS P
  INNER JOIN vInventories AS I ON
  P.ProductID = I.ProductID
  ORDER BY P.ProductName, I.InventoryDate, I.Count;
GO
*/

--But here is another version in which you can use DATENAME to extract year and do a cast to avoid the date issue
SELECT P.ProductName, DATENAME(mm,I.InventoryDate) + ', ' + DATENAME(yy,I.InventoryDate) AS InventoryDate, I.Count AS InventoryCount
  FROM vProducts AS P
  INNER JOIN vInventories AS I ON
  P.ProductID = I.ProductID
  ORDER BY P.ProductName, CAST(InventoryDate AS DATE), I.Count;
GO

-- Question 4 (10% of pts): How can you CREATE A VIEW called vProductInventories 
-- That shows a list of Product names, each Inventory Date, and the Inventory Count, 
-- with the date FORMATTED like January, 2017? Order the results by the Product, Date,
-- and Count!
/*
--This is a continuation of the previous problem. Lets take our code from the ending of the previous question
SELECT P.ProductName, DATENAME(mm,I.InventoryDate) + ', ' + LTRIM(STR(YEAR(I.InventoryDate))) AS InventoryDate, I.Count
  FROM vProducts AS P
  INNER JOIN vInventories AS I ON
  P.ProductID = I.ProductID
  ORDER BY P.ProductName, I.InventoryDate, I.Count;
GO


--Our order by matches, and the formatting request is also the same. So, all we must do is nest this into a view. Note we must also add TOP to the select
--in order for the the view to work properly due to the presence of an ORDER BY
CREATE  --DROP
  VIEW vProductInventories AS
    SELECT TOP 100000 P.ProductName, DATENAME(mm,I.InventoryDate) + ', ' + LTRIM(STR(YEAR(I.InventoryDate))) AS InventoryDate, I.Count AS InventoryCount
      FROM vProducts AS P
      INNER JOIN vInventories AS I ON
      P.ProductID = I.ProductID
      ORDER BY P.ProductName, I.InventoryDate, I.Count;
GO
*/

--Here is final version using the updated select statement and updated order by to use CAST
CREATE  --DROP
  VIEW vProductInventories AS
    SELECT TOP 100000 P.ProductName, DATENAME(mm,I.InventoryDate) + ', ' + DATENAME(yy,I.InventoryDate) AS InventoryDate, I.Count AS InventoryCount
      FROM vProducts AS P
      INNER JOIN vInventories AS I ON
      P.ProductID = I.ProductID
      ORDER BY P.ProductName, CAST(InventoryDate AS DATE), I.Count;
GO

-- Check that it works: Select * From vProductInventories;
SELECT * FROM vProductInventories;
GO

-- Question 5 (10% of pts): How can you CREATE A VIEW called vCategoryInventories 
-- that shows a list of Category names, Inventory Dates, 
-- and a TOTAL Inventory Count BY CATEGORY, with the date FORMATTED like January, 2017?

/*
--We will need to be using that same format function group from before for the date, but we will also need to get a total
--of inventory count, which will be an aggregate function. First, lets ignore all of that and get select statements without it
SELECT C.CategoryName
  FROM vCategories AS C;
GO

SELECT I.InventoryDate, I.Count
  FROM vInventories AS I;
GO

--A specific part of this to note is that you can't join categories and inventories directly, so we'll have to join
--to the products table first
SELECT C.CategoryName, I.InventoryDate, I.Count
  FROM vCategories AS C
  INNER JOIN vProducts AS P ON
  C.CategoryID = P.CategoryID
  INNER JOIN vInventories AS I ON
  P.ProductID = I.ProductID;
GO

--Now lets apply our formatting to the date, and also apply the order by that we have been going with in previous problems
SELECT C.CategoryName, DATENAME(mm,I.InventoryDate) + ', ' + LTRIM(STR(YEAR(I.InventoryDate))) AS InventoryDate, I.Count
  FROM vCategories AS C
  INNER JOIN vProducts AS P ON
  C.CategoryID = P.CategoryID
  INNER JOIN vInventories AS I ON
  P.ProductID = I.ProductID
  ORDER BY C.CategoryName, I.InventoryDate, I.Count;
GO

--Now we need to do the aggregate function. We'll be grouping the total by category and date
SELECT C.CategoryName, DATENAME(mm,I.InventoryDate) + ', ' + LTRIM(STR(YEAR(I.InventoryDate))) AS InventoryDate, SUM(I.Count) AS InventoryCountByCategory
  FROM vCategories AS C
  INNER JOIN vProducts AS P ON
  C.CategoryID = P.CategoryID
  INNER JOIN vInventories AS I ON
  P.ProductID = I.ProductID
  GROUP BY C.CategoryName, InventoryDate
  ORDER BY C.CategoryName, I.InventoryDate, InventoryCountByCategory;
GO


--Finally, now that we have our select statement, we can nest it into a view
CREATE  --DROP
  VIEW vCategoryInventories AS
    SELECT TOP 1000000 C.CategoryName, DATENAME(mm,I.InventoryDate) + ', ' + LTRIM(STR(YEAR(I.InventoryDate))) AS InventoryDate, SUM(I.Count) AS InventoryCountByCategory
      FROM vCategories AS C
      INNER JOIN vProducts AS P ON
      C.CategoryID = P.CategoryID
      INNER JOIN vInventories AS I ON
      P.ProductID = I.ProductID
      GROUP BY C.CategoryName, InventoryDate
      ORDER BY C.CategoryName, I.InventoryDate, InventoryCountByCategory;
GO
*/

--Here is final version using the new select statement and order by logic
CREATE  --DROP
  VIEW vCategoryInventories AS
    SELECT TOP 1000000 C.CategoryName, DATENAME(mm,I.InventoryDate) + ', ' + DATENAME(yy,I.InventoryDate) AS InventoryDate, SUM(I.Count) AS InventoryCountByCategory
      FROM vCategories AS C
      INNER JOIN vProducts AS P ON
      C.CategoryID = P.CategoryID
      INNER JOIN vInventories AS I ON
      P.ProductID = I.ProductID
      GROUP BY C.CategoryName, InventoryDate
      ORDER BY C.CategoryName, CAST(InventoryDate AS DATE), InventoryCountByCategory;
GO

-- Check that it works: Select * From vCategoryInventories;
SELECT * FROM vCategoryInventories;
GO

-- Question 6 (10% of pts): How can you CREATE ANOTHER VIEW called 
-- vProductInventoriesWithPreviouMonthCounts to show 
-- a list of Product names, Inventory Dates, Inventory Count, AND the Previous Month
-- Count? Use a functions to set any null counts or 1996 counts to zero. Order the
-- results by the Product, Date, and Count. This new view must use your
-- vProductInventories view!

/*
--So we begin with this view, giving us product name, inventory date and count.
SELECT * FROM vProductInventories;
GO

--This means our missing components are the previous month's count, and a function to setting null/1996 counts to 0
--Lets start with grabbing the previous month count in addition to what we've got.
--However, an interesting side effect of selecting this way is it breaks our order by from inside the view.
--We'll need to avoid the alphabetical sorting of the formatted way, and reconvert it into date to check our work
SELECT X.ProductName, X.InventoryDate, X.InventoryCount, LAG(X.InventoryCount) OVER (ORDER BY X.InventoryDate) AS PreviousMonthCount
  FROM vProductInventories AS X;
GO

--Using a substring function, let's break apart our date to build a formatted one again. This grabs the month and year respectively
SELECT DATEPART(MM,SUBSTRING(X.InventoryDate,0,PATINDEX('%,%',X.InventoryDate)) + ' 01 1900') AS Month, SUBSTRING(X.InventoryDate,PATINDEX('%,%',X.InventoryDate) + 2,4) AS Year
  FROM vProductInventories AS X;
GO

--Change of format for different code as a test. This is much longer, so it will not be used, but is a valid alternative
SELECT 
  CASE
    WHEN SUBSTRING(X.InventoryDate,0,PATINDEX('%,%',X.InventoryDate)) = 'January' THEN 1
	WHEN SUBSTRING(X.InventoryDate,0,PATINDEX('%,%',X.InventoryDate)) = 'February' THEN 2
	WHEN SUBSTRING(X.InventoryDate,0,PATINDEX('%,%',X.InventoryDate)) = 'March' THEN 3
	WHEN SUBSTRING(X.InventoryDate,0,PATINDEX('%,%',X.InventoryDate)) = 'April' THEN 4
	WHEN SUBSTRING(X.InventoryDate,0,PATINDEX('%,%',X.InventoryDate)) = 'May' THEN 5
	WHEN SUBSTRING(X.InventoryDate,0,PATINDEX('%,%',X.InventoryDate)) = 'June' THEN 6
	WHEN SUBSTRING(X.InventoryDate,0,PATINDEX('%,%',X.InventoryDate)) = 'July' THEN 7
	WHEN SUBSTRING(X.InventoryDate,0,PATINDEX('%,%',X.InventoryDate)) = 'August' THEN 8
	WHEN SUBSTRING(X.InventoryDate,0,PATINDEX('%,%',X.InventoryDate)) = 'September' THEN 9
	WHEN SUBSTRING(X.InventoryDate,0,PATINDEX('%,%',X.InventoryDate)) = 'October' THEN 10
	WHEN SUBSTRING(X.InventoryDate,0,PATINDEX('%,%',X.InventoryDate)) = 'November' THEN 11
	WHEN SUBSTRING(X.InventoryDate,0,PATINDEX('%,%',X.InventoryDate)) = 'December' THEN 12
	ELSE 0
	END
  AS Month,
  SUBSTRING(X.InventoryDate,PATINDEX('%,%',X.InventoryDate) + 2,4) AS Year
  FROM vProductInventories AS X;
GO

--Now lets put this in order by. Changing format to better accomodate complexity. Yet this has an issue: it seems to not be isolating itself to one product.
--This is related to not having our not-null filters implemented yet.
SELECT 
  X.ProductName,
  X.InventoryDate,
  X.InventoryCount,
  LAG(X.InventoryCount) OVER
    (ORDER BY X.ProductName,
    SUBSTRING(X.InventoryDate,PATINDEX('%,%',X.InventoryDate) + 2,4),
    DATEPART(MM,SUBSTRING(X.InventoryDate,0,PATINDEX('%,%',X.InventoryDate)) + ' 01 1900'))
	AS PreviousMonthCount
  FROM vProductInventories AS X
  ORDER BY
    X.ProductName,
    SUBSTRING(X.InventoryDate,PATINDEX('%,%',X.InventoryDate) + 2,4),
    DATEPART(MM,SUBSTRING(X.InventoryDate,0,PATINDEX('%,%',X.InventoryDate)) + ' 01 1900');
GO

--Implementing an IIF function, where if it is equal to our first reporting date, previous is 0, here is the result
SELECT 
  X.ProductName,
  X.InventoryDate,
  X.InventoryCount,
  IIF(X.InventoryDate = 'January, 2017',0,LAG(X.InventoryCount) OVER 
  (ORDER BY 
    X.ProductName,
    SUBSTRING(X.InventoryDate,PATINDEX('%,%',X.InventoryDate) + 2,4),
    DATEPART(MM,SUBSTRING(X.InventoryDate,0,PATINDEX('%,%',X.InventoryDate)) + ' 01 1900')))
	AS PreviousMonthCount
  FROM vProductInventories AS X
  ORDER BY
    X.ProductName,
    SUBSTRING(X.InventoryDate,PATINDEX('%,%',X.InventoryDate) + 2,4),
    DATEPART(MM,SUBSTRING(X.InventoryDate,0,PATINDEX('%,%',X.InventoryDate)) + ' 01 1900'),
	X.InventoryCount;
GO


--Alternatively, using YEAR and MONTH on the InventoryDate seems to work:
SELECT 
  X.ProductName,
  X.InventoryDate,
  X.InventoryCount,
  YEAR(X.InventoryDate),
  MONTH(X.InventoryDate),
  IIF(X.InventoryDate = 'January, 2017',0,LAG(X.InventoryCount) OVER 
  (ORDER BY 
    X.ProductName,
	YEAR(X.InventoryDate),
    MONTH(X.InventoryDate)))
	AS PreviousMonthCount
  FROM vProductInventories AS X
  ORDER BY
    X.ProductName,
    MONTH(X.InventoryDate),
	X.InventoryCount;
GO


--Finally, we put this code into a view. 
CREATE --DROP
  VIEW vProductInventoriesWithPreviousMonthCounts
  AS
    SELECT TOP 1000000
    X.ProductName,
    X.InventoryDate,
    X.InventoryCount,
    IIF(X.InventoryDate = 'January, 2017',0,LAG(X.InventoryCount) OVER --This eliminates any nulls as well
    (ORDER BY 
      X.ProductName,
	  YEAR(X.InventoryDate),
      MONTH(X.InventoryDate)))
  	AS PreviousMonthCount
    FROM vProductInventories AS X
    ORDER BY
      X.ProductName,
	  YEAR(X.InventoryDate),
      MONTH(X.InventoryDate),
	  X.InventoryCount;
GO
*/

--Final adjustments using the new CAST logic for Order By 
CREATE --DROP
  VIEW vProductInventoriesWithPreviousMonthCounts
  AS
    SELECT TOP 1000000
    X.ProductName,
    X.InventoryDate,
    X.InventoryCount,
    IIF(X.InventoryDate = 'January, 2017',0,LAG(X.InventoryCount) OVER --This eliminates any nulls as well
    (ORDER BY 
      X.ProductName,
      CAST(X.InventoryDate AS DATE)))
  	AS PreviousMonthCount
    FROM vProductInventories AS X
    ORDER BY
      X.ProductName,
      CAST(X.InventoryDate AS DATE),
	  X.InventoryCount;
GO

-- Check that it works: Select * From vProductInventoriesWithPreviousMonthCounts;
SELECT * FROM vProductInventoriesWithPreviousMonthCounts;
GO

-- Question 7 (20% of pts): How can you CREATE one more VIEW 
-- called vProductInventoriesWithPreviousMonthCountsWithKPIs
-- to show a list of Product names, Inventory Dates, Inventory Count, the Previous Month 
-- Count and a KPI that displays an increased count as 1, 
-- the same count as 0, and a decreased count as -1? Order the results by the 
-- Product, Date, and Count!
-- Important: This new view must use your vProductInventoriesWithPreviousMonthCounts view!

/*
--First, we begin with our older view
SELECT * FROM vProductInventoriesWithPreviousMonthCounts;
GO

--The only thing we need to add is a KPI, which we will be using a CASE to do.
--So if last month's amount is smaller than this amount's, we will have a KPI of 1. If less, -1, if equal, 0

This would look like:
CASE
  WHEN InventoryCount > PreviousMonthCount THEN 1
  WHEN InventoryCount = PreviousMonthCount THEN 0
  WHEN InventoryCount < PreviousMonthCount THEN -1
  END
  AS CountVsPreviousCountKPI

--So, building our select statement and implementing the order by:
SELECT
  X.ProductName,
  X.InventoryDate,
  X.InventoryCount,
  X.PreviousMonthCount,
  CASE
    WHEN InventoryCount > PreviousMonthCount THEN 1
    WHEN InventoryCount = PreviousMonthCount THEN 0
    WHEN InventoryCount < PreviousMonthCount THEN -1
    END
    AS CountVsPreviousCountKPI
  FROM vProductInventoriesWithPreviousMonthCounts AS X
  ORDER BY
    X.ProductName,
    SUBSTRING(X.InventoryDate,PATINDEX('%,%',X.InventoryDate) + 2,4),
    DATEPART(MM,SUBSTRING(X.InventoryDate,0,PATINDEX('%,%',X.InventoryDate)) + ' 01 1900'),
	X.InventoryCount;
GO
*/

--Then finally, building all of this into our view. Note that I have changed out my order by with a more elegant function
CREATE --DROP
  VIEW vProductInventoriesWithPreviousMonthCountsWithKPIs
  AS
    SELECT TOP 1000000
    X.ProductName,
    X.InventoryDate,
    X.InventoryCount,
    X.PreviousMonthCount,
    CASE
      WHEN InventoryCount > PreviousMonthCount THEN 1
      WHEN InventoryCount = PreviousMonthCount THEN 0
      WHEN InventoryCount < PreviousMonthCount THEN -1
      END
      AS CountVsPreviousCountKPI
    FROM vProductInventoriesWithPreviousMonthCounts AS X
    ORDER BY
      X.ProductName,
      CAST(X.InventoryDate AS DATE),
	  X.InventoryCount;
GO

-- Check that it works: Select * From vProductInventoriesWithPreviousMonthCountsWithKPIs;
SELECT * FROM vProductInventoriesWithPreviousMonthCountsWithKPIs;
GO

-- Question 8 (25% of pts): How can you CREATE a User Defined Function (UDF) 
-- called fProductInventoriesWithPreviousMonthCountsWithKPIs
-- to show a list of Product names, Inventory Dates, Inventory Count, the Previous Month
-- Count and a KPI that displays an increased count as 1, the same count as 0, and a
-- decreased count as -1 AND the result can show only KPIs with a value of either 1, 0,
-- or -1? This new function must use you
-- ProductInventoriesWithPreviousMonthCountsWithKPIs view!
-- Include an Order By clause in the function using this code: 
-- Year(Cast(v1.InventoryDate as Date))
-- and note what effect it has on the results.
/*
--Essentially, if I were to boil this down to its simplest form: this is a function used to filter our output
--We start with our previous view:
SELECT * FROM vProductInventoriesWithPreviousMonthCountsWithKPIs;
GO

--What we basically need to add to it is an exclusion to all values not passed in as parameters to the function
--We are returning a table
--So to lay it out:
--We have an input variable as an INT (calling it @KPI_IND)
--We are returning a table, so it will be using RETURNS TABLE AS RETURN( )
--The table we are returning is filtered on a WHERE in which the INT we get matches the KPI we found in the view
--Then we are ordering it on Name, Date, InventoryCount
*/

--Taking all of the above, I assembled this function:
CREATE FUNCTION fProductInventoriesWithPreviousMonthCountsWithKPIs (
  @KPI_IND INT  --our input integer
  )
  RETURNS TABLE  --returning a table
  AS
  RETURN(
    SELECT TOP 1000000
	  v1.ProductName,
	  v1.InventoryDate,
	  v1.InventoryCount,
	  v1.PreviousMonthCount,
	  v1.CountVsPreviousCountKPI
	FROM vProductInventoriesWithPreviousMonthCountsWithKPIs AS v1
	WHERE CountVsPreviousCountKPI = @KPI_IND  --only where provided integer is equal to the KPI
	ORDER BY 
	  v1.ProductName,
      CAST(v1.InventoryDate AS DATE),
	  v1.InventoryCount
	);
GO

--Check that it works:
SELECT * FROM fProductInventoriesWithPreviousMonthCountsWithKPIs(1);
SELECT * FROM fProductInventoriesWithPreviousMonthCountsWithKPIs(0);
SELECT * FROM fProductInventoriesWithPreviousMonthCountsWithKPIs(-1);
GO


/***************************************************************************************/
