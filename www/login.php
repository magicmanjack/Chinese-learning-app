<?php
    //Begin session and check to see if user is already logged in.
    session_start();

    if(isset($_SESSION["loggedin"]) && $_SESSION["loggedin"] == true) {
        //redirect user to main page.
        header("location: home.php");
        exit;
    }

    //Connect to database.
    require_once "connect_db.php";

    $username = $password = "";
    $userError = "";

    if($_SERVER["REQUEST_METHOD"] == "POST") {
        //Form submitted.

        $username = trim($_POST["username"]);

        if(empty($username)) {
            $userError = "Please enter a username";
        }

        $password = trim($_POST["password"]);

        if(empty($password)) {
            if(empty($userError)) {
                $userError = "Please enter a password";
            }
        }

        //validate

        if(empty($userError)) {
            $sql = "SELECT id, username, password FROM users WHERE username = '" . $username . "';";
            $statement = $pdo->query($sql);
            if($statement) {
                if($statement->rowCount() == 1) {
                    //Username exists. Check password.
                    $row = $statement->fetch();
                    $id = $row["id"];
                    $password_hash = $row["password"];
                    if(password_verify($password, $password_hash)) {
                        //Password matches. Store data in session variables.
                        $_SESSION["loggedin"] = true;
                        $_SESSION["id"] = $id;
                        $_SESSION["username"] = $username;

                        //Redirect to main page.
                        header("location: home.php");
                    } else {
                        $userError = "Invalid username or password.";
                    }
                } else {
                    $userError = "Invalid username or password.";
                }
            } else {
                $userError = "There was a problem when trying to validate your credentials.\nPlease try again later.";
            }
        }
    }


?>

<!DOCTYPE html>
<html lang="en">
    <head>
        <title>Sign in</title>
        <link rel="stylesheet" href = "style.css">
    </head>
    <body>
    
        <h2>Sign in</h2>
        <?php echo "<p class='error'>" . ((!empty($userError)) ? $userError : '') . "</p>"; ?>
        <form action="/login.php" method="post">
            <div>
                <div>
                    <label>Username</label>
                </div>
                <input type="text" name="username">
            </div>
            <div>
                <div>
                    <label>Password</label>
                </div>
                <input type="password" name="password">
            </div>
            <div>
                <input type="submit" value="Submit">
            </div>
        </form>
        <p>Don't have an account? <a href="register.php">Register here</a></p>
    </body>
</html>