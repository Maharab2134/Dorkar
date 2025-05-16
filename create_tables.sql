-- Create providers table
CREATE TABLE IF NOT EXISTS providers (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    phone VARCHAR(20) NOT NULL,
    email VARCHAR(100),
    service_type VARCHAR(50),
    address TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create services table
CREATE TABLE IF NOT EXISTS services (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    price DECIMAL(10,2) NOT NULL,
    provider_id INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (provider_id) REFERENCES providers(id)
);

-- Create bookings table
CREATE TABLE IF NOT EXISTS bookings (
    id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    provider_id INT NOT NULL,
    service_id INT NOT NULL,
    date_of_booking DATE NOT NULL,
    time_of_booking TIME NOT NULL,
    status ENUM('pending', 'confirmed', 'cancelled', 'completed', 'paid') DEFAULT 'pending',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id),
    FOREIGN KEY (provider_id) REFERENCES providers(id),
    FOREIGN KEY (service_id) REFERENCES services(id)
);

-- Insert sample provider
INSERT INTO providers (name, phone, service_type) VALUES 
('Service Provider', '9876543210', 'Cleaning');

-- Insert sample service
INSERT INTO services (name, description, price, provider_id) VALUES 
('House Cleaning', 'Complete house cleaning service', 50.00, 1);

-- Insert sample booking (assuming user with ID 1 exists)
INSERT INTO bookings (user_id, provider_id, service_id, date_of_booking, time_of_booking, status) VALUES 
(1, 1, 1, CURDATE(), '10:00:00', 'pending'); 