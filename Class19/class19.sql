USE sakila;

-- 1) Create a user data_analyst.

CREATE USER 'data_analyst'@'localhost' IDENTIFIED BY 'password';
-- Uses localhost
CREATE USER 'data_analyst'@'%' IDENTIFIED BY 'password';
-- Uses any host

-- 2) Grant permissions only to SELECT, UPDATE and DELETE to all sakila tables to it.

GRANT SELECT, UPDATE, DELETE ON sakila.* TO 'data_analyst'@'localhost';
SHOW GRANTS FOR data_analyst;

-- 3) Login with this user and try to create a table. Show the result of that operation.

/*
In order to login to this user, I need to insert the following bash command:
mysql -u data_analyst -p
After this, I attempt to create a table using this command:
*/
CREATE TABLE school (
  school_id SMALLINT UNSIGNED NOT NULL AUTO_INCREMENT,
  nombre VARCHAR(50),
  descripcion VARCHAR(255),
  PRIMARY KEY (school_id)
)
/*
ERROR 1142 (42000): CREATE command denied to user 'data_analyst'@'localhost' for table 'school'
*/

-- 4) Try to update a title of a film. Write the update script.

SELECT title FROM film WHERE film_id = 100;
UPDATE film SET title='Jumanji' WHERE film_id = 100;
/*
Query OK, 1 row affected (0,04 sec)
Rows matched: 1  Changed: 1  Warnings: 0
*/

-- 5) With root or any admin user revoke the UPDATE permission. Write the command

REVOKE UPDATE ON sakila.*  FROM 'data_analyst'@'localhost';
FLUSH PRIVILEGES;

-- 6) Login again with data_analyst and try again the update done in step 4. Show the result.

UPDATE film SET title='Sathura' WHERE film_id = 100;
/*
ERROR 1142 (42000): UPDATE command denied to user 'data_analyst'@'localhost' for table 'film'
*/