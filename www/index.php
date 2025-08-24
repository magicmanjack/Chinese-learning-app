<!DOCTYPE html>
<html>
<h1>Hello world!</h1>

<table border="20">
    <tr><th>Row num</th><th>Sentence</th></tr>
    <?php
        $db_host = '192.168.2.12';
        $db_name = 'test';
        $db_user = 'webuser';
        $db_passwd = 'db_tobechanged';

        $pdo_dsn = "mysql:host=$db_host;dbname=$db_name";

        $pdo = new PDO($pdo_dsn, $db_user, $db_passwd);
        $q = $pdo->query("SELECT * FROM test_table");

        while($row = $q->fetch()) {
            echo "<tr><td>".$row["row_num"]."</td><td>".$row["sentence"]."</td></tr>\n";
        }

    ?>
</table>
</html>