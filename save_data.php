<?php
ini_set("display_errors", 1);
ini_set("display_startup_errors", 1);
error_reporting(E_ALL);
// Database configuration
include("config.php");

// Create a new database connection
$mysqli = new mysqli($db_host, $db_user, $db_pass, $db_name);

// Check for connection errors
if ($mysqli->connect_error) {
    die("Connection Error: " . $mysqli->connect_error);
}

try {
    // Check if the form was submitted
    if ($_SERVER["REQUEST_METHOD"] === "POST") {
        // Retrieve the data from the POST request
        $name = $_POST["name"];
        $address = $_POST["address"];

        // Prepare the INSERT statement
        $stmt = $mysqli->prepare("INSERT INTO $db_table (name, address) VALUES (?, ?)");
        $stmt->bind_param("ss", $name, $address);

        // Execute the statement
        header("Content-Type: application/json");
        if ($stmt->execute()) {
            echo "Data added successfully.";
        } else {
            echo "Error adding data.";
        }

        // Close the statement
        $stmt->close();
    }

    // Close the database connection
    $mysqli->close();
} catch (\Throwable $th) {
    throw $th;
}

?>
