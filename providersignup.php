<?php
header('Content-Type: application/json');
ini_set('display_errors', 1);
error_reporting(E_ALL);

$servername = "localhost";
$username = "root";
$password = "";
$dbname = "dorkar";

// Enable error logging
error_log("Provider signup request received");

$conn = new mysqli($servername, $username, $password, $dbname);
if ($conn->connect_error) {
    error_log("Database connection failed: " . $conn->connect_error);
    http_response_code(500);
    echo json_encode(['message' => 'Connection failed']);
    exit();
}

// Create table if not exists
$createTable = "CREATE TABLE IF NOT EXISTS providers (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
    phone VARCHAR(15) NOT NULL UNIQUE,
    service VARCHAR(255) NOT NULL,
    password VARCHAR(255) NOT NULL
)";

if (!$conn->query($createTable)) {
    error_log("Table creation failed: " . $conn->error);
    http_response_code(500);
    echo json_encode(['message' => 'Table creation failed']);
    exit();
}

// Get and sanitize input
$name = trim($_POST['name'] ?? '');
$email = trim($_POST['email'] ?? '');
$phone = trim($_POST['phone'] ?? '');
$service = trim($_POST['service'] ?? '');
$password = trim($_POST['password'] ?? '');

error_log("Received data - Name: $name, Email: $email, Phone: $phone, Service: $service");

// Validate input
if (empty($name) || empty($email) || empty($phone) || empty($service) || empty($password)) {
    error_log("Empty fields detected");
    http_response_code(400);
    echo json_encode(['message' => 'Please fill all the fields']);
    $conn->close();
    exit();
}

if (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
    error_log("Invalid email format: $email");
    http_response_code(400);
    echo json_encode(['message' => 'Invalid email format']);
    $conn->close();
    exit();
}

if (!preg_match('/^\+?\d{7,15}$/', $phone)) {
    error_log("Invalid phone format: $phone");
    http_response_code(400);
    echo json_encode(['message' => 'Invalid phone number']);
    $conn->close();
    exit();
}

// Check if user exists
$checkQuery = "SELECT id FROM providers WHERE email=? OR phone=?";
$stmt = $conn->prepare($checkQuery);
if (!$stmt) {
    error_log("Prepare statement failed: " . $conn->error);
    http_response_code(500);
    echo json_encode(['message' => 'Database error']);
    exit();
}

$stmt->bind_param("ss", $email, $phone);
$stmt->execute();
$stmt->store_result();

if ($stmt->num_rows > 0) {
    error_log("User already exists with email: $email or phone: $phone");
    http_response_code(409);
    echo json_encode(['message' => 'User with this email or phone already exists']);
    $stmt->close();
    $conn->close();
    exit();
}
$stmt->close();

// Hash password
$hashed_password = password_hash($password, PASSWORD_DEFAULT);

// Insert new user
$insertQuery = "INSERT INTO providers (name, email, phone, service, password) VALUES (?, ?, ?, ?, ?)";
$stmt = $conn->prepare($insertQuery);
if (!$stmt) {
    error_log("Prepare statement failed: " . $conn->error);
    http_response_code(500);
    echo json_encode(['message' => 'Database error']);
    exit();
}

$stmt->bind_param("sssss", $name, $email, $phone, $service, $hashed_password);

if ($stmt->execute()) {
    error_log("User successfully created with email: $email");
    http_response_code(200);
    echo json_encode(['message' => 'Success']);
} else {
    error_log("Database insertion failed: " . $stmt->error);
    http_response_code(500);
    echo json_encode(['message' => 'Failed to create account: ' . $stmt->error]);
}

$stmt->close();
$conn->close();
?> 