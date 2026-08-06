-- ============================================================
-- Smart Inventory Management System - Full Database Schema
-- MySQL 8.0+
-- ============================================================

CREATE DATABASE IF NOT EXISTS smart_inventory_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE smart_inventory_db;

-- ============================================================
-- ROLES TABLE
-- ============================================================
CREATE TABLE IF NOT EXISTS roles (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(50) NOT NULL UNIQUE,
    description VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================================
-- USERS TABLE
-- ============================================================
CREATE TABLE IF NOT EXISTS users (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(100) NOT NULL UNIQUE,
    email VARCHAR(150) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    full_name VARCHAR(200) NOT NULL,
    phone VARCHAR(20),
    role_id BIGINT NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    last_login TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (role_id) REFERENCES roles(id)
);

-- ============================================================
-- PRODUCT CATEGORIES TABLE
-- ============================================================
CREATE TABLE IF NOT EXISTS product_categories (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,
    description VARCHAR(500),
    image_path VARCHAR(500),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- ============================================================
-- SUPPLIERS TABLE
-- ============================================================
CREATE TABLE IF NOT EXISTS suppliers (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(200) NOT NULL,
    contact_person VARCHAR(200),
    email VARCHAR(150),
    phone VARCHAR(30) NOT NULL,
    address TEXT,
    city VARCHAR(100),
    country VARCHAR(100) DEFAULT 'Sri Lanka',
    tax_number VARCHAR(50),
    payment_terms VARCHAR(100),
    is_active BOOLEAN DEFAULT TRUE,
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- ============================================================
-- PRODUCTS TABLE
-- ============================================================
CREATE TABLE IF NOT EXISTS products (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(200) NOT NULL,
    sku VARCHAR(100) NOT NULL UNIQUE,
    barcode VARCHAR(100),
    description TEXT,
    category_id BIGINT NOT NULL,
    supplier_id BIGINT,
    unit VARCHAR(50) DEFAULT 'pcs',
    buying_price DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    selling_price DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    quantity INT NOT NULL DEFAULT 0,
    min_stock_level INT DEFAULT 10,
    max_stock_level INT DEFAULT 1000,
    image_path VARCHAR(500),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (category_id) REFERENCES product_categories(id),
    FOREIGN KEY (supplier_id) REFERENCES suppliers(id) ON DELETE SET NULL,
    INDEX idx_products_sku (sku),
    INDEX idx_products_category (category_id),
    INDEX idx_products_supplier (supplier_id)
);

-- ============================================================
-- INVENTORY LOGS TABLE
-- ============================================================
CREATE TABLE IF NOT EXISTS inventory_logs (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    product_id BIGINT NOT NULL,
    user_id BIGINT,
    movement_type ENUM('STOCK_IN','STOCK_OUT','ADJUSTMENT','DAMAGED','RETURN','INVOICE_UPDATE') NOT NULL,
    quantity INT NOT NULL,
    quantity_before INT NOT NULL DEFAULT 0,
    quantity_after INT NOT NULL DEFAULT 0,
    reference_no VARCHAR(100),
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (product_id) REFERENCES products(id),
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL,
    INDEX idx_inventory_logs_product (product_id),
    INDEX idx_inventory_logs_date (created_at)
);

-- ============================================================
-- SALES TABLE
-- ============================================================
CREATE TABLE IF NOT EXISTS sales (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    invoice_number VARCHAR(100) NOT NULL UNIQUE,
    user_id BIGINT,
    customer_name VARCHAR(200),
    customer_phone VARCHAR(30),
    subtotal DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    discount_amount DECIMAL(12,2) DEFAULT 0.00,
    tax_amount DECIMAL(12,2) DEFAULT 0.00,
    total_amount DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    payment_method ENUM('CASH','CARD','BANK_TRANSFER','CREDIT') DEFAULT 'CASH',
    payment_status ENUM('PAID','PENDING','PARTIAL') DEFAULT 'PAID',
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL,
    INDEX idx_sales_invoice (invoice_number),
    INDEX idx_sales_date (created_at)
);

-- ============================================================
-- SALES ITEMS TABLE
-- ============================================================
CREATE TABLE IF NOT EXISTS sales_items (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    sale_id BIGINT NOT NULL,
    product_id BIGINT NOT NULL,
    quantity INT NOT NULL,
    unit_price DECIMAL(12,2) NOT NULL,
    discount_percent DECIMAL(5,2) DEFAULT 0.00,
    total_price DECIMAL(12,2) NOT NULL,
    FOREIGN KEY (sale_id) REFERENCES sales(id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products(id),
    INDEX idx_sales_items_sale (sale_id),
    INDEX idx_sales_items_product (product_id)
);

-- ============================================================
-- INVOICES (OCR) TABLE
-- ============================================================
CREATE TABLE IF NOT EXISTS invoices (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    invoice_number VARCHAR(100),
    supplier_id BIGINT,
    user_id BIGINT,
    file_path VARCHAR(500) NOT NULL,
    file_type ENUM('IMAGE','PDF') NOT NULL,
    ocr_status ENUM('PENDING','PROCESSING','COMPLETED','FAILED','VALIDATED') DEFAULT 'PENDING',
    raw_ocr_text TEXT,
    extracted_data JSON,
    total_amount DECIMAL(12,2),
    invoice_date DATE,
    is_applied BOOLEAN DEFAULT FALSE,
    applied_at TIMESTAMP,
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (supplier_id) REFERENCES suppliers(id) ON DELETE SET NULL,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL
);

-- ============================================================
-- INVOICE ITEMS TABLE (Extracted from OCR)
-- ============================================================
CREATE TABLE IF NOT EXISTS invoice_items (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    invoice_id BIGINT NOT NULL,
    product_id BIGINT,
    product_name VARCHAR(200),
    quantity INT,
    unit_price DECIMAL(12,2),
    total_price DECIMAL(12,2),
    confidence_score DECIMAL(5,2),
    is_validated BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (invoice_id) REFERENCES invoices(id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE SET NULL
);

-- ============================================================
-- FORECAST RESULTS TABLE
-- ============================================================
CREATE TABLE IF NOT EXISTS forecast_results (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    product_id BIGINT NOT NULL,
    forecast_date DATE NOT NULL,
    predicted_demand INT,
    confidence_lower INT,
    confidence_upper INT,
    model_version VARCHAR(50),
    mae DECIMAL(10,4),
    rmse DECIMAL(10,4),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (product_id) REFERENCES products(id),
    INDEX idx_forecast_product_date (product_id, forecast_date)
);

-- ============================================================
-- PURCHASE ORDERS TABLE
-- ============================================================
CREATE TABLE IF NOT EXISTS purchase_orders (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    po_number VARCHAR(100) NOT NULL UNIQUE,
    supplier_id BIGINT NOT NULL,
    user_id BIGINT,
    status ENUM('DRAFT','SENT','RECEIVED','CANCELLED') DEFAULT 'DRAFT',
    total_amount DECIMAL(12,2) DEFAULT 0.00,
    expected_delivery DATE,
    received_at TIMESTAMP,
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (supplier_id) REFERENCES suppliers(id),
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL
);

-- ============================================================
-- PURCHASE ORDER ITEMS TABLE
-- ============================================================
CREATE TABLE IF NOT EXISTS purchase_order_items (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    po_id BIGINT NOT NULL,
    product_id BIGINT NOT NULL,
    quantity_ordered INT NOT NULL,
    quantity_received INT DEFAULT 0,
    unit_price DECIMAL(12,2) NOT NULL,
    total_price DECIMAL(12,2) NOT NULL,
    FOREIGN KEY (po_id) REFERENCES purchase_orders(id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products(id)
);

-- ============================================================
-- AUDIT LOGS TABLE
-- ============================================================
CREATE TABLE IF NOT EXISTS audit_logs (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT,
    username VARCHAR(100),
    action VARCHAR(100) NOT NULL,
    entity_type VARCHAR(100),
    entity_id BIGINT,
    old_values TEXT,
    new_values TEXT,
    ip_address VARCHAR(50),
    user_agent TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL,
    INDEX idx_audit_logs_user (user_id),
    INDEX idx_audit_logs_date (created_at),
    INDEX idx_audit_logs_action (action)
);

-- ============================================================
-- SEED DATA
-- ============================================================

-- Roles
INSERT IGNORE INTO roles (name, description) VALUES
('ROLE_ADMIN', 'Full system access - Admin'),
('ROLE_INVENTORY_MANAGER', 'Manage inventory, products, suppliers'),
('ROLE_STAFF', 'View and process sales only');

-- Admin User (password: admin123)
INSERT IGNORE INTO users (username, email, password, full_name, phone, role_id, is_active) VALUES
('admin', 'admin@stocksense.com', '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', 'System Administrator', '+94 77 123 4567', 1, TRUE),
('manager', 'manager@stocksense.com', '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', 'Inventory Manager', '+94 77 234 5678', 2, TRUE),
('staff1', 'staff@stocksense.com', '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', 'Sales Staff', '+94 77 345 6789', 3, TRUE);

-- Categories
INSERT IGNORE INTO product_categories (name, description) VALUES
('Beverages', 'Drinks, juices, water, soft drinks'),
('Dairy Products', 'Milk, cheese, butter, yogurt'),
('Bakery', 'Bread, cakes, biscuits, pastries'),
('Snacks', 'Chips, crackers, nuts, candy'),
('Personal Care', 'Shampoo, soap, toothpaste'),
('Household', 'Cleaning products, detergents'),
('Frozen Foods', 'Ice cream, frozen meals'),
('Grains & Cereals', 'Rice, flour, pasta, oats'),
('Condiments', 'Sauces, spices, oil, vinegar'),
('Electronics', 'Batteries, bulbs, cables');

-- Suppliers
INSERT IGNORE INTO suppliers (name, contact_person, email, phone, address, city, payment_terms) VALUES
('Ceylon Beverages Ltd', 'Kamal Silva', 'kamal@ceylonbev.lk', '+94 11 234 5678', '45 Industrial Zone', 'Colombo', 'NET 30'),
('Lanka Dairy Co', 'Nimal Perera', 'nimal@lankadairy.lk', '+94 11 345 6789', '12 Dairy Road', 'Kandy', 'NET 15'),
('Fresh Bakers PLC', 'Sunil Fernando', 'sunil@freshbakers.lk', '+94 11 456 7890', '78 Bakery Lane', 'Gampaha', 'IMMEDIATE'),
('Metro Distributors', 'Chamari Wijesinghe', 'chamari@metro.lk', '+94 11 567 8901', '23 Metro Complex', 'Colombo', 'NET 45'),
('Island Spices Ltd', 'Aruna Bandara', 'aruna@islandspices.lk', '+94 11 678 9012', '56 Spice Garden', 'Matara', 'NET 30');

-- Products
INSERT IGNORE INTO products (name, sku, barcode, description, category_id, supplier_id, unit, buying_price, selling_price, quantity, min_stock_level, max_stock_level) VALUES
('Coca-Cola 330ml Can', 'BEV-001', '5000112637922', '330ml can', 1, 1, 'can', 55.00, 80.00, 240, 50, 500),
('Pepsi 500ml Bottle', 'BEV-002', '5000112611361', '500ml bottle', 1, 1, 'bottle', 65.00, 95.00, 180, 50, 400),
('Anchor Milk 1L', 'DAI-001', '9300675012427', 'Full cream milk', 2, 2, 'pack', 280.00, 340.00, 85, 20, 200),
('Kottu Bread 400g', 'BAK-001', '4800120000011', 'White bread', 3, 3, 'loaf', 85.00, 110.00, 60, 15, 150),
('Lays Classic 100g', 'SNK-001', '4890005135071', 'Potato chips', 4, 4, 'pack', 95.00, 130.00, 200, 30, 300),
('Sunlight Soap 90g', 'PC-001', '6001087361041', 'Bathing soap', 5, 4, 'bar', 55.00, 75.00, 300, 50, 600),
('Basmati Rice 5kg', 'GRN-001', '4800000000001', 'Premium basmati', 8, 5, 'bag', 1450.00, 1750.00, 45, 10, 100),
('Sunflower Oil 1L', 'CON-001', '4800000000002', 'Cooking oil', 9, 5, 'bottle', 380.00, 460.00, 90, 20, 200),
('Milo 400g Tin', 'BEV-003', '4800000000003', 'Chocolate malt', 1, 1, 'tin', 520.00, 650.00, 55, 15, 120),
('Maggi Noodles 75g', 'GRN-002', '4800000000004', 'Instant noodles', 8, 4, 'pack', 55.00, 75.00, 350, 50, 700),
('Dettol Soap 75g', 'PC-002', '4800000000005', 'Antibacterial soap', 5, 4, 'bar', 65.00, 90.00, 250, 40, 500),
('Butter 200g', 'DAI-002', '4800000000006', 'Unsalted butter', 2, 2, 'pack', 320.00, 390.00, 40, 10, 100),
('Chocolate Biscuits 200g', 'BAK-002', '4800000000007', 'Cream biscuits', 3, 3, 'pack', 120.00, 160.00, 150, 30, 300),
('Atta Flour 1kg', 'GRN-003', '4800000000008', 'Wheat flour', 8, 5, 'bag', 180.00, 220.00, 70, 20, 200),
('Sprite 330ml Can', 'BEV-004', '4800000000009', '330ml can', 1, 1, 'can', 55.00, 80.00, 5, 50, 500);

-- Generate some sales history for AI forecasting
INSERT IGNORE INTO sales (invoice_number, user_id, customer_name, subtotal, total_amount, payment_method, payment_status, created_at) VALUES
('INV-2024-001', 1, 'Walk-in Customer', 450.00, 450.00, 'CASH', 'PAID', '2024-01-05 10:30:00'),
('INV-2024-002', 2, 'Walk-in Customer', 890.00, 890.00, 'CASH', 'PAID', '2024-01-08 14:20:00'),
('INV-2024-003', 3, 'Nimal Stores', 2340.00, 2340.00, 'CARD', 'PAID', '2024-01-12 11:15:00'),
('INV-2024-004', 1, 'Walk-in Customer', 670.00, 670.00, 'CASH', 'PAID', '2024-01-15 16:45:00'),
('INV-2024-005', 2, 'Kamal Shop', 1250.00, 1250.00, 'CASH', 'PAID', '2024-01-20 09:30:00'),
('INV-2024-006', 3, 'Walk-in Customer', 560.00, 560.00, 'CASH', 'PAID', '2024-02-03 13:20:00'),
('INV-2024-007', 1, 'Local Store', 1890.00, 1890.00, 'CARD', 'PAID', '2024-02-10 15:00:00'),
('INV-2024-008', 2, 'Walk-in Customer', 430.00, 430.00, 'CASH', 'PAID', '2024-02-18 10:45:00'),
('INV-2024-009', 3, 'City Mart', 3200.00, 3200.00, 'BANK_TRANSFER', 'PAID', '2024-03-05 11:30:00'),
('INV-2024-010', 1, 'Walk-in Customer', 750.00, 750.00, 'CASH', 'PAID', '2024-03-12 14:15:00');

INSERT IGNORE INTO sales_items (sale_id, product_id, quantity, unit_price, total_price) VALUES
(1, 1, 3, 80.00, 240.00),(1, 5, 1, 130.00, 130.00),(1, 6, 1, 75.00, 75.00),
(2, 3, 2, 340.00, 680.00),(2, 9, 1, 650.00, 650.00),
(3, 7, 1, 1750.00, 1750.00),(3, 8, 1, 460.00, 460.00),(3, 10, 2, 75.00, 150.00),
(4, 1, 4, 80.00, 320.00),(4, 2, 2, 95.00, 190.00),(4, 11, 2, 90.00, 180.00),
(5, 4, 3, 110.00, 330.00),(5, 13, 2, 160.00, 320.00),(5, 9, 1, 650.00, 650.00),
(6, 5, 2, 130.00, 260.00),(6, 6, 2, 75.00, 150.00),(6, 10, 2, 75.00, 150.00),
(7, 3, 3, 340.00, 1020.00),(7, 12, 2, 390.00, 780.00),(7, 2, 1, 95.00, 95.00),
(8, 1, 2, 80.00, 160.00),(8, 5, 1, 130.00, 130.00),(8, 14, 1, 220.00, 220.00),
(9, 7, 1, 1750.00, 1750.00),(9, 8, 2, 460.00, 920.00),(9, 9, 1, 650.00, 650.00),
(10, 1, 3, 80.00, 240.00),(10, 2, 2, 95.00, 190.00),(10, 10, 4, 75.00, 300.00);
