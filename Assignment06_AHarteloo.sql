--*************************************************************************--
-- Title: Assignment06
-- Author: Alex_Harteloo
-- Desc: This file demonstrates how to use Views
-- Change Log: When,Who,What
-- 11/17/2024,Alex_Harteloo,Created File
--**************************************************************************--
Begin Try
	Use Master;
	If Exists(Select Name From SysDatabases Where Name = 'Assignment06DB_Alex_Harteloo
')
	 Begin 
	  Alter Database [Assignment06DB_Alex_Harteloo
	] set Single_user With Rollback Immediate;
	  Drop Database Assignment06DB_Alex_Harteloo
	;
	 End
	Create Database Assignment06DB_Alex_Harteloo
;
End Try
Begin Catch
	Print Error_Number();
End Catch
go
Use Assignment06DB_Alex_Harteloo;

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
Select '20170101' as InventoryDate, 5 as EmployeeID, ProductID, UnitsInStock
From Northwind.dbo.Products
UNIOn
Select '20170201' as InventoryDate, 7 as EmployeeID, ProductID, UnitsInStock + 10 -- Using this is to create a made up value
From Northwind.dbo.Products
UNIOn
Select '20170301' as InventoryDate, 9 as EmployeeID, ProductID, UnitsInStock + 20 -- Using this is to create a made up value
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
print 
'NOTES------------------------------------------------------------------------------------ 
 1) You can use any name you like for you views, but be descriptive and consistent
 2) You can use your working code from assignment 5 for much of this assignment
 3) You must use the BASIC views for each table after they are created in Question 1
------------------------------------------------------------------------------------------'

-- Question 1 (5% pts): How can you create BACIC views to show data from each table in the database.
-- NOTES: 1) Do not use a *, list out each column!
--        2) Create one view per table!
--		  3) Use SchemaBinding to protect the views from being orphaned!

go
CREATE VIEW vCategories
WITH SCHEMABINDING 
AS 
SELECT CategoryID, CategoryName
FROM dbo.Categories;
go

CREATE VIEW vProducts
WITH SCHEMABINDING 
AS
SELECT ProductID, ProductName, CategoryID, UnitPrice
from dbo.Products
GO

CREATE view vEmployees
WITH SCHEMABINDING 
AS
Select EmployeeID, EmployeeFirstName, EmployeeLastName, ManagerID
from dbo.Employees
GO

Create view vInventories
WITH SCHEMABINDING 
AS
SELECT InventoryID, InventoryDate, EmployeeID, ProductID, Count
from dbo.Inventories
GO


-- Question 2 (5% pts): How can you set permissions, so that the public group CANNOT select data 
-- from each table, but can select data from each view?

DENY select on Categories to PUBLIC;
GRANT select on vCategories to PUBLIC;

DENY select on Products to PUBLIC;
GRANT select on vProducts to PUBLIC;

DENY select on Employees to PUBLIC;
GRANT select on vEmployees to PUBLIC;

DENY select on Inventories to PUBLIC;
GRANT select on vInventories to PUBLIC;

-- Question 3 (10% pts): How can you create a view to show a list of Category and Product names, 
-- and the price of each product?
-- Order the result by the Category and Product!
/*
Select 
 C.CategoryName
,P.ProductName
,P.UnitPrice
FROM Categories as C
INNER JOIN Products as P
	ON C.CategoryID = P.CategoryID
ORDER BY CategoryName, ProductName
go */

SELECT 
  vC.CategoryName
, vP.ProductName
, vP.UnitPrice
FROM vCategories vC
INNER JOIN vProducts as vP
	on vC.CategoryID = vP.CategoryID
ORDER BY CategoryName, ProductName
go


-- Question 4 (10% pts): How can you create a view to show a list of Product names 
-- and Inventory Counts on each Inventory Date?
-- Order the results by the Product, Date, and Count!

/*
SELECT DISTINCT
 P.ProductName
,I.InventoryDate
,I.Count
FROM Inventories as I
INNER JOIN Products as P
	ON I.ProductID = P.ProductID
ORDER BY InventoryDate, ProductName, Count
go
*/

SELECT distinct
  vP.ProductName
, vI.InventoryDate
, vI.COUNT
FROM vInventories as vI
INNER JOIN vProducts as vP
	on vI.ProductID = vP.ProductID
ORDER by ProductName, InventoryDate, Count
go

-- Question 5 (10% pts): How can you create a view to show a list of Inventory Dates 
-- and the Employee that took the count?
-- Order the results by the Date and return only one row per date!

-- Here is are the rows selected from the view:

-- InventoryDate	EmployeeName
-- 2017-01-01	    Steven Buchanan
-- 2017-02-01	    Robert King
-- 2017-03-01	    Anne Dodsworth
/*
SELECT DISTINCT
I.InventoryDate 
,E.EmployeeFirstName + ' ' + E.EmployeeLastName as EmployeeName
From Employees as E
INNER JOIN Inventories as I
	on E.EmployeeID = I.EmployeeID
ORDER BY InventoryDate
go
*/

SELECT distinct
  vI.InventoryDate
, vE.EmployeeFirstName + ' ' + vE.EmployeeLastName as vEmployeeName
FROM vEmployees as vE
INNER JOIN vInventories as vI
	ON vE.EmployeeID = vI.EmployeeID
order by InventoryDate
go

-- Question 6 (10% pts): How can you create a view show a list of Categories, Products, 
-- and the Inventory Date and Count of each product?
-- Order the results by the Category, Product, Date, and Count!
/*
SELECT DISTINCT
 C.CategoryName
,P.ProductName
,I.InventoryDate
,I.Count
FROM Products as P
INNER JOIN Categories as C
	on C.CategoryID = P.CategoryID
INNER JOIN Inventories as I
	on I.ProductID = P.ProductID
ORDER By CategoryName, ProductName, InventoryDate, Count
go
*/

SELECT DISTINCT
 vC.CategoryName
,vP.ProductName
,vI.InventoryDate
,vI.Count
FROM vProducts as vP
INNER JOIN vCategories as vC
	on vC.CategoryID = vP.CategoryID
INNER JOIN vInventories as vI
	on vI.ProductID = vP.ProductID
ORDER By CategoryName, ProductName, InventoryDate, Count
go


-- Question 7 (10% pts): How can you create a view to show a list of Categories, Products, 
-- the Inventory Date and Count of each product, and the EMPLOYEE who took the count?
-- Order the results by the Inventory Date, Category, Product and Employee!

SELECT DISTINCT
 vC.CategoryName
,vP.ProductName
,vI.InventoryDate
,vI.Count
,vE.EmployeeFirstName + ' ' + vE.EmployeeLastName as EmployeeName
FROM vProducts as vP
INNER JOIN vCategories as vC
	on vC.CategoryID = vP.CategoryID
INNER JOIN vInventories as vI
	on vI.ProductID = vP.ProductID
INNER JOIN vEmployees as vE
	on vI.EmployeeID = vE.EmployeeID
ORDER By InventoryDate, CategoryName, ProductName, EmployeeName
go
-- Question 8 (10% pts): How can you create a view to show a list of Categories, Products, 
-- the Inventory Date and Count of each product, and the Employee who took the count
-- for the Products 'Chai' and 'Chang'? 

SELECT DISTINCT
 vC.CategoryName
,vP.ProductName
,vI.InventoryDate
,vI.Count
,vE.EmployeeFirstName + ' ' + vE.EmployeeLastName as EmployeeName
FROM vProducts as vP
INNER JOIN vCategories as vC
	on vC.CategoryID = vP.CategoryID
INNER JOIN vInventories as vI
	on vI.ProductID = vP.ProductID
INNER JOIN vEmployees as vE
	on vI.EmployeeID = vE.EmployeeID
WHERE vP.ProductName IN ('Chai', 'Chang')
ORDER By InventoryDate, CategoryName, ProductName
go

-- Question 9 (10% pts): How can you create a view to show a list of Employees and the Manager who manages them?
-- Order the results by the Manager's name!

SELECT DISTINCT
 vM.EmployeeFirstName + ' ' + vM.EmployeeLastName as ManagerName
,vE.EmployeeFirstName + ' ' + vE.EmployeeLastName as EmployeeName
FROM vEmployees as vE 
INNER JOIN Employees as vM
	ON vE.ManagerID = vM.EmployeeID
ORDER BY ManagerName, EmployeeName
go

-- Question 10 (20% pts): How can you create one view to show all the data from all four 
-- BASIC Views? Also show the Employee's Manager Name and order the data by 
-- Category, Product, InventoryID, and Employee.
/*
create view [vEmployeesByManager] AS
SELECT DISTINCT
 M.EmployeeFirstName + ' ' + M.EmployeeLastName as ManagerName
,E.EmployeeFirstName + ' ' + E.EmployeeLastName as EmployeeName
FROM Employees as E 
INNER JOIN Employees as M
	ON E.ManagerID = M.EmployeeID
go


select * from vCategories
GO
select * from vProducts
GO
select * from vInventories
GO
select * from vEmployees
GO
select * from [vEmployeesByManager]
go
*/

CREATE VIEW [vInventoriesByProductsByCategoriesByEmployees] AS
SELECT 
     vCategories.CategoryID
    ,vCategories.CategoryName
    ,vProducts.ProductID
    ,vProducts.ProductName
    ,vInventories.InventoryID
    ,vInventories.Count
    ,vE.EmployeeID AS EmployeeID
	,vE.EmployeeFirstName + ' ' + vE.EmployeeLastName as EmployeeName
	,vM.EmployeeFirstName + ' ' + vM.EmployeeLastName as ManagerName
FROM vCategories
INNER JOIN vProducts
    ON vCategories.CategoryID = vProducts.CategoryID
INNER JOIN vInventories
    ON vProducts.ProductID = vInventories.ProductID
INNER JOIN vEmployees AS vE
    ON vInventories.EmployeeID = vE.EmployeeID
INNER JOIN vEmployees AS vM
    ON vE.ManagerID = vM.EmployeeID;
go


SELECT * from [vInventoriesByProductsByCategoriesByEmployees]
ORDER BY CategoryName, ProductName, InventoryID, EmployeeName, ManagerName
go




-- Test your Views (NOTE: You must change the your view names to match what I have below!)
Print 'Note: You will get an error until the views are created!'
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