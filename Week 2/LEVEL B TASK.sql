-- Stored procedure

-- 1
CREATE PROCEDURE InsertOrderDetails
    @OrderID INT,
    @ProductID INT,
    @UnitPrice DECIMAL(10, 2) = NULL,
    @Quantity INT,
    @Discount DECIMAL(4, 2) = 0
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @CurrentUnitPrice DECIMAL(10, 2);
    DECLARE @CurrentStock INT;
    DECLARE @ReorderLevel INT;
    
    IF @UnitPrice IS NULL
    BEGIN
        SELECT @CurrentUnitPrice = UnitPrice 
        FROM Product 
        WHERE ProductID = @ProductID;
    END
    ELSE
    BEGIN
        SET @CurrentUnitPrice = @UnitPrice;
    END
	
    SELECT @CurrentStock = UnitsInStock, @ReorderLevel = ReorderLevel 
    FROM Product 
    WHERE ProductID = @ProductID;
  
    IF @CurrentStock < @Quantity
    BEGIN
        PRINT 'Not enough stock available. Transaction aborted.';
        RETURN;
    END
    
    INSERT INTO [Order Details] (OrderID, ProductID, UnitPrice, Quantity, Discount)
    VALUES (@OrderID, @ProductID, @CurrentUnitPrice, @Quantity, @Discount);
    
    IF @@ROWCOUNT = 0
    BEGIN
        PRINT 'Failed to place the order. Please try again.';
        RETURN;
    END
    
    UPDATE Product 
    SET UnitsInStock = UnitsInStock - @Quantity 
    WHERE ProductID = @ProductID;
    
    IF (@CurrentStock - @Quantity) < @ReorderLevel
    BEGIN
        PRINT 'Warning: Stock level has dropped below the reorder level.';
    END
END;

-- 2
CREATE PROCEDURE UpdateOrderDetails
    @OrderID INT,
    @ProductID INT,
    @UnitPrice DECIMAL(10, 2) = NULL,
    @Quantity INT = NULL,
    @Discount DECIMAL(4, 2) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @CurrentUnitPrice DECIMAL(10, 2);
    DECLARE @CurrentQuantity INT;
    DECLARE @CurrentDiscount DECIMAL(4, 2);
    DECLARE @OldQuantity INT;
    DECLARE @CurrentStock INT;

    SELECT @OldQuantity = Quantity
    FROM [Order Details]
    WHERE OrderID = @OrderID AND ProductID = @ProductID;

    SELECT @CurrentStock = UnitsInStock 
    FROM Product 
    WHERE ProductID = @ProductID;
    
    SELECT 
        @CurrentUnitPrice = ISNULL(@UnitPrice, UnitPrice),
        @CurrentQuantity = ISNULL(@Quantity, Quantity),
        @CurrentDiscount = ISNULL(@Discount, Discount)
    FROM [Order Details]
    WHERE OrderID = @OrderID AND ProductID = @ProductID;
    
    IF @Quantity IS NOT NULL AND @CurrentStock + @OldQuantity - @CurrentQuantity < 0
    BEGIN
        PRINT 'Not enough stock available. Transaction aborted.';
        RETURN;
    END
    
    UPDATE [Order Details]
    SET 
        UnitPrice = @CurrentUnitPrice,
        Quantity = @CurrentQuantity,
        Discount = @CurrentDiscount
    WHERE OrderID = @OrderID AND ProductID = @ProductID;
 
    UPDATE Product 
    SET UnitsInStock = UnitsInStock + @OldQuantity - @CurrentQuantity
    WHERE ProductID = @ProductID;
    
END;

-- 3
CREATE PROCEDURE GetOrderDetails
    @OrderID INT
AS
BEGIN
    SET NOCOUNT ON;
    
    IF NOT EXISTS (SELECT 1 FROM [Order Details] WHERE OrderID = @OrderID)
    BEGIN
        PRINT 'The OrderID ' + CAST(@OrderID AS VARCHAR) + ' does not exist.';
        RETURN 1;
    END
    
    SELECT * 
    FROM [Order Details]
    WHERE OrderID = @OrderID;
END;

-- 4
CREATE PROCEDURE DeleteOrderDetails
    @OrderID INT,
    @ProductID INT
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Validate parameters
    IF NOT EXISTS (SELECT 1 FROM [Order Details] WHERE OrderID = @OrderID AND ProductID = @ProductID)
    BEGIN
        PRINT 'Invalid parameters. OrderID or ProductID does not exist.';
        RETURN -1;
    END
    
    -- Get the quantity of the product in the order before deletion
    DECLARE @Quantity INT;
    SELECT @Quantity = Quantity
    FROM [Order Details]
    WHERE OrderID = @OrderID AND ProductID = @ProductID;
    
    -- Delete the order detail
    DELETE FROM [Order Details]
    WHERE OrderID = @OrderID AND ProductID = @ProductID;
    
    -- Check if deletion was successful
    IF @@ROWCOUNT = 0
    BEGIN
        PRINT 'Failed to delete the order detail. Please try again.';
        RETURN -1;
    END
    
    -- Update the stock quantity
    UPDATE Product 
    SET UnitsInStock = UnitsInStock + @Quantity 
    WHERE ProductID = @ProductID;
    
    PRINT 'Order detail successfully deleted.';
END;

-- Functions

-- 1
CREATE FUNCTION FormatDate_MMDDYYYY (@InputDate DATETIME)
RETURNS VARCHAR(10)
AS
BEGIN
    RETURN CONVERT(VARCHAR(10), @InputDate, 101); -- 101 is the style for MM/DD/YYYY
END;

-- 2
CREATE FUNCTION FormatDate_YYYYMMDD (@InputDate DATETIME)
RETURNS VARCHAR(8)
AS
BEGIN
    RETURN CONVERT(VARCHAR(8), @InputDate, 112); -- 112 is the style for YYYYMMDD
END;

---------------------------------------------------
-- sample TABLES
---------------------------------------------------
CREATE TABLE Customers (
    CustomerID INT PRIMARY KEY,
    CompanyName VARCHAR(100)
);

CREATE TABLE Orders (
    OrderID INT PRIMARY KEY,
    CustomerID INT,
    OrderDate DATETIME,
    FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID)
);

CREATE TABLE [Order Details] (
    OrderID INT,
    ProductID INT,
    Quantity INT,
    UnitPrice DECIMAL(10, 2),
    Discount DECIMAL(4, 2),
    PRIMARY KEY (OrderID, ProductID),
    FOREIGN KEY (OrderID) REFERENCES Orders(OrderID)
);

CREATE TABLE Products (
    ProductID INT PRIMARY KEY,
    ProductName VARCHAR(100),
    SupplierID INT,
    CategoryID INT,
    QuantityPerUnit VARCHAR(50),
    UnitPrice DECIMAL(10, 2),
    UnitsInStock INT,
    Discontinued BIT
);

CREATE TABLE Suppliers (
    SupplierID INT PRIMARY KEY,
    CompanyName VARCHAR(100)
);

CREATE TABLE Categories (
    CategoryID INT PRIMARY KEY,
    CategoryName VARCHAR(100)
);

INSERT INTO Customers (CustomerID, CompanyName) VALUES (1, 'Customer A');
INSERT INTO Suppliers (SupplierID, CompanyName) VALUES (1, 'Supplier A');
INSERT INTO Categories (CategoryID, CategoryName) VALUES (1, 'Category A');
INSERT INTO Products (ProductID, ProductName, SupplierID, CategoryID, QuantityPerUnit, UnitPrice, UnitsInStock, Discontinued) 
VALUES (1, 'Product A', 1, 1, '10 boxes', 20.00, 100, 0);

INSERT INTO Orders (OrderID, CustomerID, OrderDate) VALUES (1, 1, GETDATE());
INSERT INTO [Order Details] (OrderID, ProductID, Quantity, UnitPrice, Discount) VALUES (1, 1, 10, 20.00, 0);


-- Views

-- 1
CREATE VIEW vwCustomerOrders AS
SELECT 
    c.CompanyName,
    o.OrderID,
    o.OrderDate,
    od.ProductID,
    p.ProductName,
    od.Quantity,
    od.UnitPrice,
    od.Quantity * od.UnitPrice AS QuantityOfUnitPrice
FROM 
    Orders o
JOIN 
    [Order Details] od ON o.OrderID = od.OrderID
JOIN 
    Products p ON od.ProductID = p.ProductID
JOIN 
    Customers c ON o.CustomerID = c.CustomerID;

-- 2
CREATE VIEW vwCustomerOrdersYesterday AS
SELECT 
    c.CompanyName,
    o.OrderID,
    o.OrderDate,
    od.ProductID,
    p.ProductName,
    od.Quantity,
    od.UnitPrice,
    od.Quantity * od.UnitPrice AS QuantityOfUnitPrice
FROM 
    Orders o
JOIN 
    [Order Details] od ON o.OrderID = od.OrderID
JOIN 
    Products p ON od.ProductID = p.ProductID
JOIN 
    Customers c ON o.CustomerID = c.CustomerID
WHERE 
    CONVERT(DATE, o.OrderDate) = CONVERT(DATE, GETDATE() - 1);

-- 3 
CREATE VIEW MyProducts AS
SELECT 
    p.ProductID,
    p.ProductName,
    p.QuantityPerUnit,
    p.UnitPrice,
    s.CompanyName,
    c.CategoryName
FROM 
    Products p
JOIN 
    Suppliers s ON p.SupplierID = s.SupplierID
JOIN 
    Categories c ON p.CategoryID = c.CategoryID
WHERE 
    p.Discontinued = 0;

-- TRIGGERS

-- 1
CREATE TRIGGER trgInsteadOfDeleteOrder ON Orders
INSTEAD OF DELETE
AS
BEGIN
    SET NOCOUNT ON;

    DELETE FROM [Order Details]
    WHERE OrderID IN (SELECT OrderID FROM deleted);

    DELETE FROM Orders
    WHERE OrderID IN (SELECT OrderID FROM deleted);
END;

-- 2 
CREATE TRIGGER trgBeforeInsertOrderDetails ON [Order Details]
FOR INSERT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @ProductID INT;
    DECLARE @Quantity INT;
    DECLARE @UnitsInStock INT;

    SELECT @ProductID = i.ProductID, @Quantity = i.Quantity
    FROM inserted i;

    SELECT @UnitsInStock = UnitsInStock
    FROM Products
    WHERE ProductID = @ProductID;

    IF @UnitsInStock < @Quantity
    BEGIN
        PRINT 'Order could not be filled due to insufficient stock.';
        ROLLBACK TRANSACTION;
        RETURN;
    END

    UPDATE Products
    SET UnitsInStock = UnitsInStock - @Quantity
    WHERE ProductID = @ProductID;
END;


