--*************************************************************************--
-- Title: Assignment06
-- Author: Kiana Sua
-- Desc: This file demonstrates how to use Views
-- Change Log: When,Who,What
-- 2021-05-21,KianaSua,Created File
--**************************************************************************--
Begin Try
	Use Master;
	If Exists(Select Name From SysDatabases Where Name = 'Assignment06DB_KianaSua')
	 Begin 
	  Alter Database [Assignment06DB_KianaSua] set Single_user With Rollback Immediate;
	  Drop Database Assignment06DB_KianaSua;
	 End
	Create Database Assignment06DB_KianaSua;
End Try
Begin Catch
	Print Error_Number();
End Catch
go
Use Assignment06DB_KianaSua;

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
'NOTES------------------------------------------------------------------------------------ 
 1) You can use any name you like for you views, but be descriptive and consistent
 2) You can use your working code from assignment 5 for much of this assignment
 3) You must use the BASIC views for each table after they are created in Question 1
------------------------------------------------------------------------------------------'

-- Question 1 (5% pts): How can you create BACIC views to show data from each table in the database.
-- NOTES: 1) Do not use a *, list out each column!
--        2) Create one view per table!
--		  3) Use SchemaBinding to protect the views from being orphaned!

CREATE VIEW VCategories
WITH SCHEMABINDING
	AS
		SELECT CategoryID, CategoryName
			FROM dbo.Categories
;
GO

CREATE VIEW VProducts
WITH SCHEMABINDING
	AS 
		SELECT ProductID, ProductName, CategoryID, UnitPrice
			FROM dbo.Products
;
GO

CREATE VIEW VEmployees
WITH SCHEMABINDING
	AS
		SELECT EmployeeID, EmployeeFirstName, EmployeeLastName, ManagerID
			FROM dbo.Employees
;
GO

CREATE VIEW VInventories
WITH SCHEMABINDING
	AS
		SELECT InventoryID, InventoryDate, EmployeeID, ProductID, [Count]
			FROM dbo.Inventories
;
GO

-- Question 2 (5% pts): How can you set permissions, so that the public group CANNOT select data 
-- from each table, but can select data from each view?

DENY SELECT ON Categories TO PUBLIC;
DENY SELECT ON Products TO PUBLIC;
DENY SELECT ON Employees TO PUBLIC;
DENY SELECT ON Inventories TO PUBLIC;
GO

GRANT SELECT ON VCategories TO PUBLIC;
GRANT SELECT ON VProducts TO PUBLIC;
GRANT SELECT ON VEmployees TO PUBLIC;
GRANT SELECT ON VInventories TO PUBLIC;
GO


-- Question 3 (10% pts): How can you create a view to show a list of Category and Product names, 
-- and the price of each product?
-- Order the result by the Category and Product!

CREATE VIEW VProductsbyCategories

AS
	SELECT TOP 1000000 
	C.CategoryName
	,P.ProductName
	,P.UnitPrice
	FROM VCategories AS C
		INNER JOIN VProducts as P
			ON C.CategoryID = P.CategoryID
ORDER BY CategoryName, ProductName ASC
;
GO 

-- Here is an example of some rows selected from the view:
-- CategoryName,ProductName,UnitPrice
-- Beverages,Chai,18.00
-- Beverages,Chang,19.00
-- Beverages,Chartreuse verte,18.00

-- Question 4 (10% pts): How can you create a view to show a list of Product names 
-- and Inventory Counts on each Inventory Date?
-- Order the results by the Product, Date, and Count!

CREATE VIEW VInventoriesbyProductsbyDates
AS
	SELECT TOP 1000000
	P.ProductName
	,I.InventoryDate
	,I.[Count]
	FROM VProducts AS P
		INNER JOIN VInventories as I
			ON P.ProductID = I.ProductID
	ORDER BY ProductName, InventoryDate, [Count] ASC
;
GO
-- Here is an example of some rows selected from the view:
--ProductName,InventoryDate,Count
--Alice Mutton,2017-01-01,15
--Alice Mutton,2017-02-01,78
--Alice Mutton,2017-03-01,83

-- Question 5 (10% pts): How can you create a view to show a list of Inventory Dates 
-- and the Employee that took the count?
-- Order the results by the Date and return only one row per date!

CREATE VIEW VInventoriesbyEmployeesbyDate
AS
	SELECT DISTINCT TOP 1000000
	I.InventoryDate
	,E.EmployeeFirstName + ' ' + E.EmployeeLastName AS EmployeeName
	FROM VInventories AS I
		INNER JOIN VEmployees AS E 
			ON I.EmployeeID = E.EmployeeID
	ORDER BY InventoryDate
;
GO

-- Here is an example of some rows selected from the view:
-- InventoryDate,EmployeeName
-- 2017-01-01,Steven Buchanan
-- 2017-02-01,Robert King
-- 2017-03-01,Anne Dodsworth

-- Question 6 (10% pts): How can you create a view show a list of Categories, Products, 
-- and the Inventory Date and Count of each product?
-- Order the results by the Category, Product, Date, and Count!

CREATE VIEW vInventoriesbyProductsbyCategorieswithDateandCount
AS
	SELECT TOP 1000000
	C.CategoryName
	,P.ProductName
	,I.InventoryDate
	,I.[Count]
	FROM VInventories AS I
		INNER JOIN VProducts as P
			ON I.ProductID = P.ProductID
		INNER JOIN VCategories AS C
			ON P.CategoryID = C.CategoryID
	ORDER BY CategoryName, ProductName, InventoryDate, [Count] ASC 
;
GO

-- Here is an example of some rows selected from the view:
-- CategoryName,ProductName,InventoryDate,Count
-- Beverages,Chai,2017-01-01,72
-- Beverages,Chai,2017-02-01,52
-- Beverages,Chai,2017-03-01,54

-- Question 7 (10% pts): How can you create a view to show a list of Categories, Products, 
-- the Inventory Date and Count of each product, and the EMPLOYEE who took the count?
-- Order the results by the Inventory Date, Category, Product and Employee!

CREATE VIEW VInventoriesbyProductsbyEmployeewithDateandCount
AS
	SELECT TOP 1000000
	C.CategoryName
	,P.ProductName
	,I.InventoryDate
	,I.[Count]
	,E.EmployeeFirstName + ' ' + E.EmployeeLastName AS EmployeeName
	FROM VInventories AS I
		INNER JOIN VEmployees AS E 
			ON I.EmployeeID = E.EmployeeID
		INNER JOIN VProducts AS P
			ON I.ProductID = P.ProductID
		INNER JOIN VCategories AS C
			ON P.CategoryID = C.CategoryID
	ORDER BY InventoryDate, CategoryName, ProductName, EmployeeName
;
GO

-- Here is an example of some rows selected from the view:
-- CategoryName,ProductName,InventoryDate,Count,EmployeeName
-- Beverages,Chai,2017-01-01,72,Steven Buchanan
-- Beverages,Chang,2017-01-01,46,Steven Buchanan
-- Beverages,Chartreuse verte,2017-01-01,61,Steven Buchanan

-- Question 8 (10% pts): How can you create a view to show a list of Categories, Products, 
-- the Inventory Date and Count of each product, and the Employee who took the count
-- for the Products 'Chai' and 'Chang'? 

CREATE VIEW VInventoriesforChaiandChangbyEmployeeswithDateandCount
AS
	SELECT TOP 1000000 
	C.CategoryName
	,P.ProductName
	,I.InventoryDate
	,I.[Count]
	,E.EmployeeFirstName + ' ' + E.EmployeeLastName AS EmployeeName
	FROM VInventories AS I
		INNER JOIN VEmployees AS E 
			ON I.EmployeeID = E.EmployeeID
		INNER JOIN VProducts AS P
			ON I.ProductID = P.ProductID
		INNER JOIN VCategories AS C
			ON P.CategoryID = C.CategoryID
	WHERE I.ProductID 
		IN (SELECT P.ProductID
			FROM Products AS P
				WHERE P.ProductName 
					IN ('Chai', 'Chang'))
	ORDER BY InventoryDate, CategoryName, ProductName ASC
;
GO

-- Here is an example of some rows selected from the view:
-- CategoryName,ProductName,InventoryDate,Count,EmployeeName
-- Beverages,Chai,2017-01-01,72,Steven Buchanan
-- Beverages,Chang,2017-01-01,46,Steven Buchanan
-- Beverages,Chai,2017-02-01,52,Robert King

-- Question 9 (10% pts): How can you create a view to show a list of Employees and the Manager who manages them?
-- Order the results by the Manager's name!

CREATE VIEW VEmployeesbyManager
AS
	SELECT TOP 1000000 
	M.EmployeeFirstName + ' ' + M.EmployeeLastName AS Manager
	,E.EmployeeFirstName + ' ' + E.EmployeeLastName AS Employee
	FROM VEmployees AS E
		INNER JOIN VEmployees AS M
			ON E.ManagerID = M.EmployeeID
	ORDER BY Manager
;
GO

-- Here is an example of some rows selected from the view:
-- Manager,Employee
-- Andrew Fuller,Andrew Fuller
-- Andrew Fuller,Janet Leverling
-- Andrew Fuller,Laura Callahan

-- Question 10 (20% pts): How can you create one view to show all the data from all four 
-- BASIC Views?

CREATE VIEW VInventoriesbyProductsbyCategoriesbyEmployees
AS
	SELECT TOP 1000000
	C.CategoryID
	,C.CategoryName
	,P.ProductID
	,P.ProductName
	,P.UnitPrice
	,I.InventoryID
	,I.InventoryDate
	,I.[Count]
	,E.EmployeeID
	,E.EmployeeFirstName + ' ' + E.EmployeeLastName AS Employee
	,M.EmployeeFirstName + ' ' + M.EmployeeLastName AS Manager
	FROM VCategories AS C
		INNER JOIN VProducts AS P
			ON P.CategoryID = C.CategoryID
		INNER JOIN VInventories AS I
			ON P.ProductID = I.ProductID
		INNER JOIN VEmployees AS E
			ON I.EmployeeID = E.EmployeeID
		INNER JOIN VEmployees AS M
			ON E.ManagerID = M.EmployeeID
		ORDER BY CategoryID,ProductID, InventoryID, EmployeeID ASC
;
GO


-- Here is an example of some rows selected from the view:
-- CategoryID,CategoryName,ProductID,ProductName,UnitPrice,InventoryID,InventoryDate,Count,EmployeeID,Employee,Manager
-- 1,Beverages,1,Chai,18.00,1,2017-01-01,72,5,Steven Buchanan,Andrew Fuller
-- 1,Beverages,1,Chai,18.00,78,2017-02-01,52,7,Robert King,Steven Buchanan
-- 1,Beverages,1,Chai,18.00,155,2017-03-01,54,9,Anne Dodsworth,Steven Buchanan

-- Test your Views (NOTE: You must change the names to match yours as needed!)
Select * From [dbo].[VCategories]
Select * From [dbo].[VProducts]
Select * From [dbo].[VInventories]
Select * From [dbo].[VEmployees]

Select * From [dbo].[VProductsbyCategories]
Select * From [dbo].[VInventoriesbyProductsbyDates]
Select * From [dbo].[VInventoriesbyEmployeesbyDate]
Select * From [dbo].[vInventoriesbyProductsbyCategorieswithDateandCount]
Select * From [dbo].[VInventoriesbyProductsbyEmployeewithDateandCount]
Select * From [dbo].[VInventoriesforChaiandChangbyEmployeeswithDateandCount]
Select * From [dbo].[VEmployeesbyManager]
Select * From [dbo].[VInventoriesbyProductsbyCategoriesbyEmployees]
/***************************************************************************************/