<?php 
    session_start();
    if(!isset($_SESSION['loggedin']) || $_SESSION['loggedin'] == false) {
        exit;
    }
    //Pick 3 random words and fill 
    require_once "connect_db.php";
    
    $id = $_SESSION["id"];
    
?>

<style>
    div.side-by-side {
        width: 70vw;
        padding: 5vw;
    }

    div.side-by-side * {
        width:40%;
        float:left;
    }
</style>
<p>Enter the corrosponding hànzì</p>
<form>
    
    <?php 
        $sql = "SELECT * FROM words WHERE owner_id=:id ORDER BY RAND() LIMIT 3;";
        $statement = $pdo->prepare($sql);
        $statement->bindParam(":id", $id, PDO::PARAM_STR);

        if($statement->execute()) {
            $inputId = 0;
            while($row = $statement->fetch()) {
                echo "<div class='side-by-side'>";
                echo "<lable for=".$inputId.">".$row['hanzi']."</lable>";
                echo "<input type='text' id=in".$inputId." name=in".$inputId.">";   
                echo "</div>"; 
                $inputId = $inputId + 1;
            }
        } else {
            echo "<p class='error'>There was a problem when trying to connect to the database.</p>";
        }
    ?>
 
</form>