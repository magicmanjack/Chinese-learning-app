<?php

$userError = "";

if($_SERVER["REQUEST_METHOD"] == "POST") {
    //Form submission should be a post request.

    //Attempt to connect to db server
    $dbServer = "192.168.2.12";
    $dbUsername = "webuser";
    $dbPassword = "aaftwup123!";
    $dbName = "test";

    try {
        $pdo = new PDO("mysql:host=" . $dbServer . ";dbname=" . $dbName, $dbUsername, $dbPassword);
        $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    } catch(PDOException $e) {
        // Failed connecting to db.
        die("ERROR: could not connect to the database. " . $e->getMessage());
    }
    //Validate username
    $usernameEntered = trim($_POST["username"]);

    if(empty($usernameEntered)) {
        $userError = "You must provide a username.";
    } else if(!preg_match('/^[a-zA-Z0-9_]+$/', $usernameEntered)) {
        $userError = "You must only use alphanumeric characters or '_'";
    } else {
        //Password meets rules. Check if already in database.
        //TODO: query database to see if password is unique, if so,
        //upload to data base and redirect user to sign in page.
    }
}

?>

<!DOCTYPE html>
<html lang="en">
    <head>
        <title>Sign Up</title>
        <link rel="stylesheet" href = "style.css">
    </head>
    <body>
        <h2>Sign up</h2>
        <p>
            You must first create an account
        </p>
        <?php echo "<p class='error'>" . ((!empty($userError)) ? $userError : '') . "</p>"; ?>
        <form action="/register.php" method="post">
            <div>
                <div>
                    <label>New username</label>
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
                <div>
                    <label>Confirm password</label>
                </div>
                <input type="password" name="confirm_password">
            </div>
            <div>
                <input type="submit" value="Submit">
            </div>
        </form>
    </body>
</html>