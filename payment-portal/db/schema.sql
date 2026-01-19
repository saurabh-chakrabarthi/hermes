-- Hermes Payment Portal Database Schema

CREATE DATABASE IF NOT EXISTS hermes_payments;
USE hermes_payments;

-- Payments table
CREATE TABLE IF NOT EXISTS payments (
    id VARCHAR(36) PRIMARY KEY,
    reference VARCHAR(50) UNIQUE NOT NULL,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL,
    amount DECIMAL(10, 2) NOT NULL,
    amount_received DECIMAL(10, 2) NOT NULL,
    school VARCHAR(255),
    sender_full_name VARCHAR(255),
    country_from VARCHAR(100),
    sender_address TEXT,
    currency_from VARCHAR(10),
    student_id VARCHAR(100),
    status VARCHAR(50) DEFAULT 'PENDING',
    validation_status VARCHAR(50) DEFAULT 'PENDING',
    fee_percentage DECIMAL(5, 2),
    fee_amount DECIMAL(10, 2),
    final_amount DECIMAL(10, 2),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_email (email),
    INDEX idx_reference (reference),
    INDEX idx_created_at (created_at),
    INDEX idx_status (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Validation results table
CREATE TABLE IF NOT EXISTS validation_results (
    id INT AUTO_INCREMENT PRIMARY KEY,
    payment_id VARCHAR(36) NOT NULL,
    check_type VARCHAR(100) NOT NULL,
    check_result VARCHAR(50) NOT NULL,
    check_message TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (payment_id) REFERENCES payments(id) ON DELETE CASCADE,
    INDEX idx_payment_id (payment_id),
    INDEX idx_check_type (check_type)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Audit log table
CREATE TABLE IF NOT EXISTS audit_log (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    payment_id VARCHAR(36),
    action VARCHAR(100) NOT NULL,
    old_value TEXT,
    new_value TEXT,
    user_agent TEXT,
    ip_address VARCHAR(45),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_payment_id (payment_id),
    INDEX idx_action (action),
    INDEX idx_created_at (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Insert sample data
INSERT INTO payments (id, reference, name, email, amount, amount_received, school, sender_full_name, country_from, sender_address, currency_from, student_id, status, fee_percentage, fee_amount, final_amount)
VALUES 
    ('1', 'REF001', 'John Doe', 'john@mit.edu', 25000.00, 24800.00, 'MIT', 'John Doe', 'USA', '123 Main St', 'usd', 'MIT001', 'UNDERPAYMENT', 2.00, 500.00, 25500.00),
    ('2', 'REF002', 'Jane Smith', 'jane@stanford.edu', 30000.00, 31500.00, 'Stanford', 'Jane Smith', 'USA', '456 Oak Ave', 'usd', 'STF002', 'OVERPAYMENT', 2.00, 600.00, 30600.00)
ON DUPLICATE KEY UPDATE updated_at = CURRENT_TIMESTAMP;
