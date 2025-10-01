<?php 
    $API = "http://192.168.2.13:3000/";

    session_start();
    if(!isset($_SESSION['loggedin']) || $_SESSION['loggedin'] == false) {
        exit;
    }

    //Check if GET request
    if($_SERVER["REQUEST_METHOD"] == "GET") {
        if(isset($_GET['hanzi'])) {
            //hanzi provided
            $hanzi = $_GET['hanzi'];
            
            //Send GET to web API
            $get = $API . "pinyin/" . rawurlencode($hanzi);
            $res = file_get_contents($get);

            if($res) {
                echo $res;
            }
        }
    }
    
?>