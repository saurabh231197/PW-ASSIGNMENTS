-- Assignment Code: DA-AG-014
-- Introduction to SQL and Advanced Functions | SQL File Solution

-- ==============================================================================
-- QUESTION 6: Create Database, Tables, and Insert Records (ECommerceDB)
-- ==============================================================================

-- 1. Create the database
CREATE DATABASE IF NOT EXISTS ECommerceDB;
USE ECommerceDB;

-- Drop tables if they exist to allow clean re-execution
DROP TABLE IF EXISTS Orders;
DROP TABLE IF EXISTS Customers;
DROP TABLE IF EXISTS Products;
DROP TABLE IF EXISTS Categories;

-- 1. Create Tables with appropriate constraints

-- Categories Table
CREATE TABLE Categories (
    CategoryID INT PRIMARY KEY,
    CategoryName VARCHAR(50) NOT NULL UNIQUE
);

-- Products Table
CREATE TABLE Products (
    ProductID INT PRIMARY KEY,
    ProductName VARCHAR(100) NOT NULL UNIQUE,
    CategoryID INT,
    Price DECIMAL(10,2) NOT NULL,
    StockQuantity INT,
    FOREIGN KEY (CategoryID) REFERENCES Categories(CategoryID)
);

-- Customers Table
CREATE TABLE Customers (
    CustomerID INT PRIMARY KEY,
    CustomerName VARCHAR(100) NOT NULL,
    Email VARCHAR(100) UNIQUE,
    JoinDate DATE
);

-- Orders Table
CREATE TABLE Orders (
    OrderID INT PRIMARY KEY,
    CustomerID INT,
    OrderDate DATE NOT NULL,
    TotalAmount DECIMAL(10,2),
    FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID)
);

-- 2. Insert Records

-- Categories
INSERT INTO Categories (CategoryID, CategoryName) VALUES
(1, 'Electronics'),
(2, 'Books'),
(3, 'Home Goods'),
(4, 'Apparel');

-- Products
INSERT INTO Products (ProductID, ProductName, CategoryID, Price, StockQuantity) VALUES
(101, 'Laptop Pro', 1, 1200.00, 50),
(102, 'SQL Handbook', 2, 45.50, 200),
(103, 'Smart Speaker', 1, 99.99, 150),
(104, 'Coffee Maker', 3, 75.00, 80),
(105, 'Novel: The Great SQL', 2, 25.00, 120),
(106, 'Wireless Earbuds', 1, 150.00, 100),
(107, 'Blender X', 3, 120.00, 60),
(108, 'T-Shirt Casual', 4, 20.00, 300);

-- Customers
INSERT INTO Customers (CustomerID, CustomerName, Email, JoinDate) VALUES
(1, 'Alice Wonderland', 'alice@example.com', '2023-01-10'),
(2, 'Bob the Builder', 'bob@example.com', '2022-11-25'),
(3, 'Charlie Chaplin', 'charlie@example.com', '2023-03-01'),
(4, 'Diana Prince', 'diana@example.com', '2021-04-26');

-- Orders
INSERT INTO Orders (OrderID, CustomerID, OrderDate, TotalAmount) VALUES
(1001, 1, '2023-04-26', 1245.50),
(1002, 2, '2023-10-12', 99.99),
(1003, 1, '2023-07-01', 145.00),
(1004, 3, '2023-01-14', 150.00),
(1005, 2, '2023-09-24', 120.00),
(1006, 1, '2023-06-19', 20.00);


-- ==============================================================================
-- QUESTION 7: Customer Order Report (Including Customers with Zero Orders)
-- ==============================================================================
-- Use LEFT JOIN to include all customers, and COUNT() with GROUP BY to aggregate orders.

SELECT
    c.CustomerName,
    c.Email,
    COUNT(o.OrderID) AS TotalNumberofOrders
FROM
    Customers c
LEFT JOIN
    Orders o ON c.CustomerID = o.CustomerID
GROUP BY
    c.CustomerID, c.CustomerName, c.Email
ORDER BY
    c.CustomerName ASC;


-- ==============================================================================
-- QUESTION 8: Retrieve Product Information with Category
-- ==============================================================================
-- Use INNER JOIN to combine Products and Categories tables.

SELECT
    p.ProductName,
    p.Price,
    p.StockQuantity,
    c.CategoryName
FROM
    Products p
INNER JOIN
    Categories c ON p.CategoryID = c.CategoryID
ORDER BY
    c.CategoryName ASC,
    p.ProductName ASC;


-- ==============================================================================
-- QUESTION 9: Top 2 Most Expensive Products in Each Category (CTE and Window Function)
-- ==============================================================================
-- Use a CTE with the RANK() window function to partition by CategoryName and order by Price.

WITH RankedProducts AS (
    SELECT
        c.CategoryName,
        p.ProductName,
        p.Price,
        -- RANK() assigns a rank within each Category partition based on Price (DESC)
        RANK() OVER (PARTITION BY c.CategoryName ORDER BY p.Price DESC) as product_rank
    FROM
        Products p
    INNER JOIN
        Categories c ON p.CategoryID = c.CategoryID
)
SELECT
    CategoryName,
    ProductName,
    Price
FROM
    RankedProducts
WHERE
    product_rank <= 2  -- Filter for the top 2 ranked products
ORDER BY
    CategoryName, Price DESC;


-- ==============================================================================
-- QUESTION 10: Sakila Database Business Questions (Requires Sakila DB)
-- Note: These queries assume the standard 'sakila' database is in use.
-- ==============================================================================

-- Ensure you switch to the Sakila database if necessary:
-- USE sakila;

-- 1. Identify the top 5 customers based on the total amount they've spent.
SELECT
    c.first_name,
    c.last_name,
    c.email,
    SUM(p.amount) AS TotalAmountSpent
FROM
    customer c
JOIN
    payment p ON c.customer_id = p.customer_id
GROUP BY
    c.customer_id, c.first_name, c.last_name, c.email
ORDER BY
    TotalAmountSpent DESC
LIMIT 5;

-- 2. Which 3 movie categories have the highest rental counts?
SELECT
    c.name AS CategoryName,
    COUNT(r.rental_id) AS RentalCount
FROM
    category c
JOIN
    film_category fc ON c.category_id = fc.category_id
JOIN
    inventory i ON fc.film_id = i.film_id
JOIN
    rental r ON i.inventory_id = r.inventory_id
GROUP BY
    c.name
ORDER BY
    RentalCount DESC
LIMIT 3;

-- 3. Calculate how many films are available at each store and how many of those have never been rented.
SELECT
    i.store_id,
    COUNT(i.inventory_id) AS TotalFilmsAvailable,
    SUM(CASE
        -- Use a subquery to check if the inventory_id exists in the rental table
        WHEN i.inventory_id NOT IN (SELECT inventory_id FROM rental) THEN 1
        ELSE 0
    END) AS NeverRentedCount
FROM
    inventory i
GROUP BY
    i.store_id
ORDER BY
    i.store_id;

-- 4. Show the total revenue per month for the year 2006 (assuming 2023 data is unavailable in standard Sakila).
-- Replace YEAR(payment_date) = 2006 with 2023 if your specific Sakila instance contains 2023 data.
SELECT
    YEAR(payment_date) AS PaymentYear,
    MONTH(payment_date) AS PaymentMonth,
    SUM(amount) AS MonthlyRevenue
FROM
    payment
WHERE
    YEAR(payment_date) = 2006 -- Adjusted to 2006, common year in Sakila data
GROUP BY
    PaymentYear, PaymentMonth
ORDER BY
    PaymentYear, PaymentMonth;

-- 5. Identify customers who have rented more than 10 times in the last 6 months.
SELECT
    c.first_name,
    c.last_name,
    COUNT(r.rental_id) AS TotalRentals
FROM
    customer c
JOIN
    rental r ON c.customer_id = r.customer_id
WHERE
    -- Filters rentals from the last 6 months using the MAX rental date as reference
    r.rental_date >= DATE_SUB( (SELECT MAX(rental_date) FROM rental), INTERVAL 6 MONTH)
GROUP BY
    c.customer_id, c.first_name, c.last_name
HAVING
    TotalRentals > 10
ORDER BY
    TotalRentals DESC;

