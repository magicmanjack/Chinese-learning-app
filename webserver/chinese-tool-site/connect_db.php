    <?php
    
        //Attempt to connect to db server
        $dbServer = getenv("DB_HOSTNAME");
        $dbUsername = getenv("DB_USERNAME");
        $dbPassword = getenv("DB_PASSWORD");
        $dbName = getenv("DB_NAME");

        try {
            $pdo = new PDO("mysql:host=" . $dbServer . ";dbname=" . $dbName, $dbUsername, $dbPassword);
            $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

        } catch(PDOException $e) {
            // Failed connecting to db.
            die("ERROR: could not connect to the database. " . $e->getMessage());
        }
    ?>