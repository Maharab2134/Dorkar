<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST');
header('Access-Control-Allow-Headers: Content-Type');

// Enable error reporting for debugging
error_reporting(E_ALL);
ini_set('display_errors', 1);

// Function to send JSON response
function sendJsonResponse($message, $status = 'success', $data = null) {
    $response = [
        'message' => $message,
        'status' => $status
    ];
    if ($data !== null) {
        $response['booking'] = $data;
    }
    echo json_encode($response);
    exit;
}

// Check if it's a POST request
if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    sendJsonResponse('Invalid request method. Only POST allowed.', 'error');
}

// Database connection
$conn = new mysqli('localhost', 'root', '', 'dorkar');

if ($conn->connect_error) {
    sendJsonResponse('Database connection failed: ' . $conn->connect_error, 'error');
}

// Get and sanitize input
$id = isset($_POST['id']) ? intval($_POST['id']) : 0;

// Debug log
error_log("Received booking ID: " . $id);

// Validate input
if ($id <= 0) {
    sendJsonResponse('Invalid booking ID', 'error');
}

// First check if the booking exists
$check_sql = "SELECT * FROM bookings WHERE id = ?";
$check_stmt = $conn->prepare($check_sql);
$check_stmt->bind_param('i', $id);
$check_stmt->execute();
$result = $check_stmt->get_result();

if ($result->num_rows === 0) {
    sendJsonResponse('Booking not found', 'error');
}

// Get the current booking status
$booking = $result->fetch_assoc();
error_log("Current booking status: " . $booking['status']);

// Check if the booking is in a valid state for cancellation
if ($booking['status'] !== 'confirmed') {
    sendJsonResponse('Booking cannot be cancelled. Current status: ' . $booking['status'], 'error');
}

// Update the booking status to cancelled
$update_sql = "UPDATE bookings SET status = 'cancelled' WHERE id = ?";
$update_stmt = $conn->prepare($update_sql);
$update_stmt->bind_param('i', $id);

if ($update_stmt->execute()) {
    // Get the updated booking details
    $get_booking_sql = "SELECT b.*, 
        c.name as customer_name, 
        c.phone as customer_phone,
        s.name as service_name,
        s.price as service_price
        FROM bookings b 
        JOIN customers c ON b.customer_id = c.id 
        JOIN services s ON b.service_id = s.id 
        WHERE b.id = ?";
    $get_booking_stmt = $conn->prepare($get_booking_sql);
    $get_booking_stmt->bind_param('i', $id);
    $get_booking_stmt->execute();
    $booking_result = $get_booking_stmt->get_result();
    $booking = $booking_result->fetch_assoc();

    // Debug log
    error_log("Successfully cancelled booking: " . json_encode($booking));
    
    sendJsonResponse('success', 'success', $booking);
} else {
    sendJsonResponse('Failed to cancel booking: ' . $conn->error, 'error');
}

$conn->close();
?> 