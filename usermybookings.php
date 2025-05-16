<?php
error_reporting(E_ALL);
ini_set('display_errors', 1);
header('Content-Type: application/json');

$host = "localhost";
$username = "root";
$password = "";
$database = "dorkar";

try {
    $conn = new mysqli($host, $username, $password, $database);

    if ($conn->connect_error) {
        throw new Exception('Database connection failed: ' . $conn->connect_error);
    }

    $conn->set_charset("utf8");

    if ($_SERVER["REQUEST_METHOD"] == "GET") {
        $user_id = $_GET['uid'] ?? '';

        if (empty($user_id)) {
            echo json_encode([
                'message' => 'error',
                'error' => 'User ID is required'
            ]);
            exit();
        }

        // First check if user exists
        $check_user = "SELECT id FROM users WHERE id = ?";
        $stmt = $conn->prepare($check_user);
        if (!$stmt) {
            throw new Exception('Failed to prepare user check statement: ' . $conn->error);
        }
        
        $stmt->bind_param("i", $user_id);
        $stmt->execute();
        $user_result = $stmt->get_result();
        
        if ($user_result->num_rows === 0) {
            echo json_encode([
                'message' => 'error',
                'error' => 'User not found'
            ]);
            exit();
        }
        $stmt->close();

        // Fetch bookings with all required information
        $sql = "SELECT 
                b.id, b.user_id, b.provider_id, b.service_id, 
                b.booking_date, b.booking_time, b.status,
                b.username, b.phone_no,
                s.name as service_name,
                s.price as service_price,
                s.duration as service_duration,
                p.name as provider_name,
                p.phone as provider_phone,
                p.service as provider_service
                FROM bookings b 
                LEFT JOIN services s ON b.service_id = s.id 
                LEFT JOIN providers p ON s.provider_id = p.id 
                WHERE b.user_id = ?
                ORDER BY b.booking_date DESC, b.booking_time DESC";

        $stmt = $conn->prepare($sql);
        if (!$stmt) {
            throw new Exception('Failed to prepare bookings statement: ' . $conn->error);
        }

        $stmt->bind_param("i", $user_id);
        if (!$stmt->execute()) {
            throw new Exception('Failed to execute query: ' . $stmt->error);
        }
        
        $result = $stmt->get_result();
        if (!$result) {
            throw new Exception('Failed to get result: ' . $stmt->error);
        }

        $bookings = array();

        if ($result->num_rows > 0) {
            while ($row = $result->fetch_assoc()) {
                // Map database status to app status
                $status = $row['status'];
                switch ($status) {
                    case 'pending':
                        $status = 'requested';
                        break;
                    case 'confirmed':
                        $status = 'accepted';
                        break;
                    case 'cancelled':
                        $status = 'rejected';
                        break;
                    case 'completed':
                        $status = 'completed';
                        break;
                    case 'paid':
                        $status = 'paid';
                        break;
                }

                $booking = array(
                    'id' => $row['id'],
                    'user_id' => $row['user_id'],
                    'provider_id' => $row['provider_id'],
                    'service_id' => $row['service_id'],
                    'booking_date' => $row['booking_date'],
                    'booking_time' => $row['booking_time'],
                    'status' => $status,
                    'username' => $row['username'],
                    'phone_no' => $row['phone_no'],
                    'service_name' => $row['service_name'] ?? '',
                    'provider_name' => $row['provider_name'] ?? '',
                    'service_price' => $row['service_price'] ?? '0',
                    'service_duration' => $row['service_duration'] ?? '0',
                    'provider_phone' => $row['provider_phone'] ?? '',
                    'provider_service' => $row['provider_service'] ?? ''
                );
                array_push($bookings, $booking);
            }
            echo json_encode($bookings);
        } else {
            echo json_encode([]);
        }

        $stmt->close();
    } else {
        echo json_encode([
            'message' => 'error',
            'error' => 'Invalid request method'
        ]);
    }

} catch (Exception $e) {
    echo json_encode([
        'message' => 'error',
        'error' => $e->getMessage()
    ]);
} finally {
    if (isset($stmt)) {
        $stmt->close();
    }
    if (isset($conn)) {
        $conn->close();
    }
}
?> 