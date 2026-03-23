USE masai_assignment_1_pt2;

-- Drop tables if they exist to allow clean re-runs
DROP TABLE IF EXISTS fact_sales;
DROP TABLE IF EXISTS dim_product;
DROP TABLE IF EXISTS dim_store;
DROP TABLE IF EXISTS dim_customer;
DROP TABLE IF EXISTS dim_date;

-- ---------------------------------------------------------
-- 1. CREATE DIMENSION TABLES
-- ---------------------------------------------------------

-- Date Dimension: Allows slicing by year, month, and quarter
CREATE TABLE dim_date (
    date_id INT PRIMARY KEY,         -- Format: YYYYMMDD
    full_date DATE NOT NULL,
    year INT NOT NULL,
    month INT NOT NULL,
    day INT NOT NULL,
    quarter INT NOT NULL
);

-- Store Dimension
CREATE TABLE dim_store (
    store_id INT PRIMARY KEY,
    store_name VARCHAR(100) NOT NULL,
    store_city VARCHAR(50) NOT NULL
);

-- Product Dimension
CREATE TABLE dim_product (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(100) NOT NULL,
    category VARCHAR(50) NOT NULL
);

-- Customer Dimension
CREATE TABLE dim_customer (
    customer_id VARCHAR(20) PRIMARY KEY
);

-- ---------------------------------------------------------
-- 2. CREATE FACT TABLE
-- ---------------------------------------------------------

CREATE TABLE fact_sales (
    transaction_id VARCHAR(20) PRIMARY KEY,
    date_id INT NOT NULL,
    store_id INT NOT NULL,
    product_id INT NOT NULL,
    customer_id VARCHAR(20) NOT NULL,
    units_sold INT NOT NULL,
    unit_price DECIMAL(10, 2) NOT NULL,
    total_sales_amount DECIMAL(12, 2) NOT NULL, -- Derived measure (units_sold * unit_price)
    
    FOREIGN KEY (date_id) REFERENCES dim_date(date_id),
    FOREIGN KEY (store_id) REFERENCES dim_store(store_id),
    FOREIGN KEY (product_id) REFERENCES dim_product(product_id),
    FOREIGN KEY (customer_id) REFERENCES dim_customer(customer_id)
);

-- ---------------------------------------------------------
-- 3. INSERT CLEANED DATA (ETL SIMULATION)
-- ---------------------------------------------------------

-- Load Date Dimension
INSERT INTO dim_date (date_id, full_date, year, month, day, quarter) VALUES
(20230829, '2023-08-29', 2023, 8, 29, 3),
(20231212, '2023-12-12', 2023, 12, 12, 4),
(20230205, '2023-02-05', 2023, 2, 5, 1),
(20230220, '2023-02-20', 2023, 2, 20, 1),
(20230115, '2023-01-15', 2023, 1, 15, 1),
(20230809, '2023-08-09', 2023, 8, 9, 3),
(20230331, '2023-03-31', 2023, 3, 31, 1),
(20231026, '2023-10-26', 2023, 10, 26, 4),
(20230502, '2023-05-02', 2023, 5, 2, 2),
(20231017, '2023-10-17', 2023, 10, 17, 4);

-- Load Store Dimension (Missing NULL city resolved for Store 5)
INSERT INTO dim_store (store_id, store_name, store_city) VALUES
(1, 'Chennai Anna', 'Chennai'),
(2, 'Delhi South', 'Delhi'),
(3, 'Bangalore MG', 'Bangalore'),
(4, 'Pune FC Road', 'Pune'),
(5, 'Mumbai Central', 'Mumbai');

-- Load Product Dimension (Casing standardized to 'Electronics' and 'Groceries')
INSERT INTO dim_product (product_id, product_name, category) VALUES
(101, 'Speaker', 'Electronics'),
(102, 'Tablet', 'Electronics'),
(103, 'Phone', 'Electronics'),
(104, 'Smartwatch', 'Electronics'),
(105, 'Atta 10kg', 'Groceries'),
(106, 'Milk 1L', 'Groceries'),
(107, 'Biscuits', 'Groceries');

-- Load Customer Dimension
INSERT INTO dim_customer (customer_id) VALUES
('CUST045'), ('CUST021'), ('CUST019'), ('CUST007'), ('CUST004'), 
('CUST027'), ('CUST025'), ('CUST001'), ('CUST009'), ('CUST015');

-- Load Fact Table (10 Cleaned Transactions)
INSERT INTO fact_sales (transaction_id, date_id, store_id, product_id, customer_id, units_sold, unit_price, total_sales_amount) VALUES
('TXN5000', 20230829, 1, 101, 'CUST045', 3, 49262.78, 147788.34),
('TXN5001', 20231212, 1, 102, 'CUST021', 11, 23226.12, 255487.32),
('TXN5002', 20230205, 1, 103, 'CUST019', 20, 48703.39, 974067.80),
('TXN5003', 20230220, 2, 102, 'CUST007', 14, 23226.12, 325165.68),
('TXN5004', 20230115, 1, 104, 'CUST004', 10, 58851.01, 588510.10),
('TXN5005', 20230809, 3, 105, 'CUST027', 12, 52464.00, 629568.00),
('TXN5006', 20230331, 4, 104, 'CUST025', 6, 58851.01, 353106.06),
('TXN5007', 20231026, 4, 106, 'CUST001', 10, 43374.39, 433743.90),
('TXN5288', 20230502, 5, 107, 'CUST009', 4,  2700.00,  10800.00),
('TXN5283', 20231017, 1, 104, 'CUST015', 3,  58851.01, 176553.03);