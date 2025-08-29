    <?php
    
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
    ?>