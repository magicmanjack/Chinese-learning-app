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
    $sql = "SELECT * FROM words WHERE owner_id=:id ORDER BY RAND() LIMIT 1;";
    $statement = $pdo->prepare($sql);
    $statement->bindParam(":id", $id, PDO::PARAM_STR);

    $hanzi = array();
    $pinyin = array();
    $english = array();


    if($statement->execute()) {
        
        while($row = $statement->fetch()) {
            array_push($hanzi, $row['hanzi']);
            array_push($pinyin, $row['pinyin']);
            array_push($english, $row['english']);
        }
        
    } 

    for($i = 0; $i < count($hanzi); $i++) {
        echo "\"".$hanzi[$i]."\"";
        if($i < count($hanzi) - 1) {
            echo ",";
        }
    }

    echo "],\"english\":[";


    for($i = 0; $i < count($english); $i++) {
        echo "\"".$english[$i]."\"";
        if($i < count($english) - 1) {
            echo ",";
        }
    }

    echo "],\"pinyin\":[";

    for($i = 0; $i < count($pinyin); $i++) {
        echo "\"".$pinyin[$i]."\"";
        if($i < count($pinyin) - 1) {
            echo ",";
        }
    }
?>
]}


 
