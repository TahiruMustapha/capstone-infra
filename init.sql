CREATE TABLE IF NOT EXISTS clients_tb (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL,
    job VARCHAR(255),
    rate DECIMAL(10, 2),
    isactive BOOLEAN DEFAULT true
);

INSERT INTO clients_tb (name, email, job, rate, isactive) VALUES 
('John Doe', 'john@example.com', 'Developer', 50.00, true),
('Jane Smith', 'jane@example.com', 'Designer', 60.00, true);
