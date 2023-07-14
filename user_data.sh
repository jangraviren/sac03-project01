#!/bin/bash
sudo su
apt-get update -y
apt-get install -y apache2 php8.1 php8.1-mysql

# Start and enable Apache2
systemctl start apache2
systemctl enable apache2

# Allow incoming HTTP traffic on port 80
firewall-cmd --zone=public --permanent --add-service=http
firewall-cmd --reload

# Create a PHP info file
echo "<?php phpinfo(); ?>" > /var/www/html/info.php

# Create a database config file
echo '<?php
// Database configuration
$db_host = "database-1.cxspraprlfyf.us-east-1.rds.amazonaws.com";
$db_name = "project01";
$db_user = "admin";
$db_pass = "Simplilearn$123";
$db_table = "employees";
?>' > /var/www/html/config.php

# Create a get_data.php file to fetch data from database table
echo '<?php

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

?>' > /var/www/html/get_data.php

# Create a save_data.php script file to store data in database
echo '<?php
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

?>' > /var/www/html/save_data.php



# Create a index.html file to submit and preview the submitted data
echo '<!DOCTYPE html>
<html>
<head>
  <title>Project 01</title>
  <link href="https://cdn.jsdelivr.net/npm/tailwindcss@2.2.19/dist/tailwind.min.css" rel="stylesheet">
  <style>
    .container {
      max-width: 640px;
      margin: 0 auto;
    }
  </style>
</head>
<body>
  <div class="container">
    <h1 class="text-2xl font-bold mt-4 mb-8">Add Your Data:</h1>

    <form id="dataForm" class="flex items-end justify-center gap-4">
      <div>
        <label for="name" class="block">Name:</label>
        <input type="text" id="name" name="name" required class="border border-gray-300 rounded px-4 py-2">
      </div>

      <div>
        <label for="address" class="block">Address:</label>
        <input type="text" id="address" name="address" required class="border border-gray-300 rounded px-4 py-2">
      </div>

      <button type="submit" class="bg-blue-500 hover:bg-blue-700 text-white font-bold py-2 px-4 rounded">Add Data</button>
    </form>
    <hr class="my-8">
    <h2 class="text-xl font-bold mt-4">Employees Data:</h2>
    <div id="dataTable"></div>
  </div>

  <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.6.0/jquery.min.js"></script>
  <script>
    $(document).ready(function() {
        var baseURL = "";
      // Function to handle form submission
      $("#dataForm").submit(function(event) {
        event.preventDefault();

        var name = $("#name").val();
        var address = $("#address").val();
        
        // AJAX request to save data to the database
        $.ajax({
          url: baseURL + "save_data.php",
          type: "POST",
          data: {
            name: name,
            address: address
          },          
          complete: function (response) {
            // Clear the form inputs
            $("#name").val("");
            $("#address").val("");
            alert(response.responseText);
            // Refresh the data table
            loadData();
          }
        });
      });

      // Function to load data from the database
      function loadData() {
        $.ajax({
          url: baseURL + "get_data.php",
          type: "GET",
          success: function(response) {
            $("#dataTable").html(response);
          }
        });
      }

      // Load initial data on page load
      loadData();
    });
  </script>
</body>
</html>' > /var/www/html/index.php

chown -R ubuntu:www-data /var/www
find /var/www -type d -exec chmod 2750 {} \+
find /var/www -type f -exec chmod 640 {} \+

# Restart Apache2 to apply changes
systemctl restart apache2
