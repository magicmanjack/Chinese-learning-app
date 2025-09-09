<?php 

session_start();

if(!isset($_SESSION["loggedin"]) || $_SESSION["loggedin"] == false) {
    //If user is not logged in. Redirect.
    header("location: login.php");
    exit;
}

$userMessage = "";

if($_SERVER["REQUEST_METHOD"] == "POST") {

    require "connect_db.php";
    //Form submission to insert new words into database.
    $hanzi = trim($_POST["hanzi"]);
    $pinyin = trim($_POST["pinyin"]);
    $english = trim($_POST["english"]);

    $sql = "INSERT INTO words (owner_id, hanzi, pinyin, english) VALUES (:owner_id, :hanzi, :pinyin, :english);";
    $statement = $pdo->prepare($sql);
    $statement->bindParam(":owner_id", $_SESSION["id"], PDO::PARAM_INT);
    $statement->bindParam(":hanzi", $hanzi, PDO::PARAM_STR);
    $statement->bindParam(":pinyin", $pinyin, PDO::PARAM_STR);
    $statement->bindParam(":english", $english, PDO::PARAM_STR);

    if(!$statement->execute()) {
        $userMessage = "<span class='error'>There was a problem when trying to add to the collection.</span>";
    } else {
        $userMessage = "<span class='success'>Added to collection.</span>";
    }
}

?>

<!DOCTYPE html>
<html lan="en">
    <head>
        <title>Add words</title>
        <link rel="stylesheet" href="style.css">
        <script src="get_pinyin.js"></script>
    </head>
    <body>
        <h3>Add new words</h3>
        <p>Add some newly learned words to your collection. You can enter the hànzì, pīnyīn, and english meaning.
        <p>It is a good idea to enter all three, in order to get the best out of this practice tool. 
        
        <style>
            div.side-by-side {
                width: 80vw;
            }
            div.side-by-side > div {
                padding: 0 0;
                width:33%;
                height:10vw;
                float:left;
            }
            div.add-words-label {
                height:3vw;
            }

          
        </style>
        <form action="/add_words.php" method="post">
            <div class="side-by-side">
                <div>
                    <div class="add-words-label">
                        <lable for="hanzi">hànzì</lable>
                    </div>
                    <input type="text" id="hanzi" name="hanzi">
                </div>
                <div>
                    <div class="add-words-label">
                        <lable for="pinyin">pīnyīn</lable>
                        <input type="button" id="auto-fill-button" value="Auto fill" onclick="get_pinyin()">
                    </div>
                    <input type="text" id="pinyin" name="pinyin">
                </div>
                <div>
                    <div class="add-words-label">
                        <lable for="english">english</lable>
                    </div>
                    <input type="text" id="english" name="english">
                </div>
            </div>
            <input type="submit" value="Add"></input>
        </form>
        <?php echo $userMessage?>
        <p><a href="edit_words.php">Done</a></p>
    </body>
</html>