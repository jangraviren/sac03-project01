<?php
ini_set('display_errors', 1);
ini_set('display_startup_errors', 1);
error_reporting(E_ALL);
// Database configuration
include("config.php");

// Create a new database connection
$mysqli = new mysqli($db_host, $db_user, $db_pass, $db_name);

// Check for connection errors
if ($mysqli->connect_error) {
    die("Connection Error: " . $mysqli->connect_error);
}

// Prepare the SELECT statement
$stmt = $mysqli->prepare("SELECT id, name, address, createdOn FROM $db_table order by id desc");

// Execute the statement
$stmt->execute();

// Bind the result variables
$stmt->bind_result($id, $name, $address, $createdOn);

// Create an array to store the fetched data
$data = array();

// Start building the HTML table
$table_html = "<table border class=\"min-w-full text-center text-sm font-bold\">
                <thead class=\"border-b bg-gray-800 font-medium text-white dark:border-gray-500 dark:bg-gray-900\">
                <tr>
                    <th scope=\"col\" class=\"px-6 py-2\">ID</th>
                    <th scope=\"col\" class=\"px-6 py-2\">Name</th>
                    <th scope=\"col\" class=\"px-6 py-2\">Address</th>
                    <th scope=\"col\" class=\"px-6 py-2\">CreatedOn</th>
                </tr>
                </thead>
                ";

// Fetch the rows and populate the data array
while ($stmt->fetch()) {
    $data[] = array(
        "id" => $id,
        "name" => $name,
        "address" => $address,
        "createdOn" => $address
    );

    $table_html .= "<tr class=\"border\">
                        <td scope=\"col\" class=\"px-6 py-2\">" . $id . "</td>
                        <td scope=\"col\" class=\"text-left px-6 py-2\">" . $name . "</td>
                        <td scope=\"col\" class=\"text-left px-6 py-2\">" . $address . "</td>
                        <td scope=\"col\" class=\"px-6 py-2\">" . $createdOn . "</td>
                    </tr>";
}

if(sizeof($data) === 0) {
    $table_html .= "<tr class=\"border\">
                        <td scope=\"col\" class=\" px-6 py-2\" colspan=4> NO RECORDS FOUND YET.</td>                        
                    </tr>";
}
// Finish building the HTML table
$table_html .= "</table>";

// Close the statement
$stmt->close();

if(isset($_GET["mode"]) && $_GET["mode"] === "api") {
    // Return the data in JSON format
    header("Content-Type: application/json");
    echo json_encode($data);
} else {
    // Output the table HTML
    echo $table_html;    
}

?>