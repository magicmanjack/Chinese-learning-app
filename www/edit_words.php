<?php
    //TODO - display list from data base of users added words.
    //3 sections, Chinese word, PINYIN, english meaning.
    //Add and delete word button.

    session_start();

    if(!isset($_SESSION["loggedin"]) || $_SESSION["loggedin"] == false) {
       //User is not logged in, redirect them to login.
       header("location: login.php");
       exit;
    }

    require_once "connect_db.php";

    $id = $_SESSION["id"];

?>

<!DOCTYPE html>
<html>
    <head>
        <title>Edit words</title>
        <link rel="stylesheet" href="style.css">

    </head>
    <body>

        <h3>Edit words</h3>
        <table>
            <style>
                table, th, tr,td {
                    border: 1px solid black;
                }
            </style>
        
            <tr>
                <th>Hanzi</th>
                <th>Pinyin</th>
                <th>In English</th>
            </tr>
            <?php 
                $sql = "SELECT * FROM words WHERE owner_id=".$id.";";
                $statement = $pdo->query($sql);
                if($statement) {
                    
                    while($row = $statement->fetch()) {
                        echo "<tr><td>".$row["hanzi"]."</td><td>".$row["pinyin"]."</td><td>".$row["english"]."</td></tr>";
                    }
                }

            ?>
        </table>

        <p><a href="add_words.php">Add words</a></p>
        <p><a href="home.php">Return home</a></p>
    </body>
</html>