<?php
ini_set('display_errors', 0);
ini_set('log_errors', 1);
ini_set('error_log', 'php_errors.log');
header("Content-Type: application/json");

// Enable error logging
error_log("Update user request received");

$host = "localhost";
$username = "root";
$password = "";
$database = "dorkar";

try {
    $conn = new mysqli($host, $username, $password, $database);
    if ($conn->connect_error) {
        error_log("Database connection failed: " . $conn->connect_error);
        throw new Exception('DB connection failed: ' . $conn->connect_error);
    }

    // Log received data
    error_log("Received POST data: " . print_r($_POST, true));

    $id = $_POST['id'] ?? '';
    $username = $_POST['username'] ?? '';
    $email = $_POST['email'] ?? '';
    $phone_no = $_POST['phone_no'] ?? '';
    $address = $_POST['address'] ?? '';

    if (empty($id) || empty($username) || empty($email) || empty($phone_no) || empty($address)) {
        error_log("Missing required fields. ID: $id, Username: $username, Email: $email, Phone: $phone_no, Address: $address");
        throw new Exception('Missing required fields');
    }

    $sql = "UPDATE users SET 
                username = ?, 
                email = ?, 
                phone_no = ?, 
                address = ? 
            WHERE id = ?";

    $stmt = $conn->prepare($sql);
    if (!$stmt) {
        error_log("Prepare statement failed: " . $conn->error);
        throw new Exception('Prepare failed: ' . $conn->error);
    }

    $stmt->bind_param("sssss", $username, $email, $phone_no, $address, $id);

    if (!$stmt->execute()) {
        error_log("Execute failed: " . $stmt->error);
        throw new Exception('Execute failed: ' . $stmt->error);
    }

    if ($stmt->affected_rows > 0) {
        error_log("Update successful for user ID: $id");
        echo json_encode(['message' => 'success']);
    } else {
        error_log("No rows updated for user ID: $id");
        echo json_encode(['message' => 'error', 'error' => 'No rows updated']);
    }

    $stmt->close();
    $conn->close();

} catch (Exception $e) {
    error_log("Exception occurred: " . $e->getMessage());
    echo json_encode(['message' => 'error', 'error' => $e->getMessage()]);
}
?> 