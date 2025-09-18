<?php 
    session_start();
    if(!isset($_SESSION['loggedin']) || $_SESSION['loggedin'] == false) {
        exit;
    }
    //Pick 3 random words and fill 
    require_once "connect_db.php";
    
    $id = $_SESSION["id"];
    
?>


{"hanzi":[ <?php 
    $sql = "SELECT * FROM words WHERE owner_id=:id ORDER BY RAND() LIMIT 3;";
    $statement = $pdo->prepare($sql);
    $statement->bindParam(":id", $id, PDO::PARAM_STR);

    $words = array();

    if($statement->execute()) {
        
        while($row = $statement->fetch()) {
            array_push($words, $row['hanzi']);
        }
        
    } 

    for($i = 0; $i < count($words); $i++) {
        echo "\"".$words[$i]."\"";
        if($i < count($words) - 1) {
            echo ",";
        }
    }
?>
]}


 
