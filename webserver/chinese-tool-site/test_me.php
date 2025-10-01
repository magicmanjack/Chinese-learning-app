<?php 
session_start();

if(!isset($_SESSION['loggedin']) || $_SESSION['loggedin'] != true) {
    //user not logged in
    header("location: login.php");
    exit;
}

$userMessage = "";
if($_SERVER['REQUEST_METHOD'] == "POST") {
    $userMessage = "success";
}

?>


<!DOCTYPE html>
<html>
    <head>
        <link rel="stylesheet" href="style.css">
        <title>Test me</title>
        <script src="test_me.js"></script>
    </head>
    <body>
        <h5>Practice</h5>
        <div id="content-area">
            <button type="button" onclick="startPractice()" id="start-button"> Start </button>
        </div>
    </body>
</html>