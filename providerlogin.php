<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json");
ini_set('display_errors', 1);
error_reporting(E_ALL);

// Enable error logging
error_log("Provider login request received");

// DB connection
$host = 'localhost';
$db = 'dorkar';
$user = 'root';
$pass = '';
$conn = new mysqli($host, $user, $pass, $db);

// Check connection
if ($conn->connect_error) {
    error_log("Database connection failed: " . $conn->connect_error);
    echo json_encode(['message' => 'error', 'error' => 'Database connection failed']);
    exit();
}

// Get POST values safely
$email = trim($_POST['email'] ?? '');
$password = trim($_POST['password'] ?? '');

error_log("Login attempt for email: $email");

// Basic validation
if (empty($email) || empty($password)) {
    error_log("Empty email or password");
    echo json_encode(['message' => 'error', 'error' => 'Email and password are required']);
    exit();
}

// Validate email format
if (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
    error_log("Invalid email format: $email");
    echo json_encode(['message' => 'error', 'error' => 'Invalid email format']);
    exit();
}

// Query to check if the provider exists
$query = "SELECT * FROM providers WHERE email = ?";
$stmt = $conn->prepare($query);
if (!$stmt) {
    error_log("Prepare statement failed: " . $conn->error);
    echo json_encode(['message' => 'error', 'error' => 'Database error']);
    exit();
}

$stmt->bind_param("s", $email);
$stmt->execute();
$result = $stmt->get_result();

// Check if the provider is found
if ($result->num_rows > 0) {
    $provider = $result->fetch_assoc();

    // Verify the password
    if (password_verify($password, $provider['password'])) {
        error_log("Login successful for email: $email");
        // Password is correct, return provider info
        echo json_encode([
            'message' => 'success',
            'providerInfo' => [
                'id' => $provider['id'],
                'name' => $provider['name'],
                'email' => $provider['email'],
                'phone' => $provider['phone'],
                'service' => $provider['service']
            ]
        ]);
    } else {
        error_log("Invalid password for email: $email");
        echo json_encode(['message' => 'error', 'error' => 'Invalid password']);
    }
} else {
    error_log("Provider not found with email: $email");
    echo json_encode(['message' => 'error', 'error' => 'Provider not found']);
}

$stmt->close();
$conn->close();
?> 