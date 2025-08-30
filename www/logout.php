<?php
    session_start();

    //Depopulate session variables. (Not done automatically by session_destroy().
    $_SESSION = array();

    //If browser is using cookies, set the session id cookie for removal.
    if (ini_get("session.use_cookies")) {
        $params = session_get_cookie_params();
        setcookie(session_name(), '', time() - 42000,
            $params["path"], $params["domain"],
            $params["secure"], $params["httponly"]
        );
    }

    //Destroy all session related data.
    session_destroy();

    //Redirect to login
    header("location: login.php");
    exit;
?>