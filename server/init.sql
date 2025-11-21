-- Initialize database schema for Hermes Payment Portal
USE hermes_payments;

CREATE TABLE IF NOT EXISTS payments (
  id VARCHAR(36) PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  email VARCHAR(255) NOT NULL,
  amount DECIMAL(12,2) NOT NULL,
  school VARCHAR(100),
  student_id VARCHAR(50),
  country_from VARCHAR(50),
  sender_address TEXT,
  currency_from VARCHAR(3) DEFAULT 'usd',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  INDEX idx_email (email),
  INDEX idx_created_at (created_at)
);

-- Insert sample data for testing
INSERT INTO payments (id, name, email, amount, school, student_id, country_from, currency_from) VALUES
('550e8400-e29b-41d4-a716-446655440001', 'John Doe', 'john.doe@mit.edu', 25000.00, 'MIT', 'MIT001', 'USA', 'usd'),
('550e8400-e29b-41d4-a716-446655440002', 'Jane Smith', 'jane.smith@stanford.edu', 30000.00, 'Stanford', 'STF002', 'Canada', 'usd'),
('550e8400-e29b-41d4-a716-446655440003', 'Carlos Rodriguez', 'carlos@arizona.edu', 15000.00, 'Arizona', 'AZ003', 'Spain', 'usd');