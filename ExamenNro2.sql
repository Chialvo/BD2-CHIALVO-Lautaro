USE Chinook;


-- 1

DROP VIEW IF EXISTS customer_purchase_summary;
 
CREATE VIEW customer_purchase_summary AS
SELECT c.CustomerId AS 'ID', CONCAT(c.FirstName, ' ', c.LastName) AS 'Nombre',
(SELECT GROUP_CONCAT(Nombre SEPARATOR "; ") FROM (SELECT g.Name AS Nombre FROM InvoiceLine il INNER JOIN Invoice i USING (InvoiceId) INNER JOIN Track T USING (TrackId) INNER JOIN Genre g USING (GenreId) WHERE i.CustomerId=c.CustomerId GROUP BY GenreId)AS Genre) AS Generos,
(SELECT COUNT(i.InvoiceId) FROM Invoice i WHERE i.CustomerId = c.CustomerId) AS 'Cantidad de compras',
(SELECT SUM(il.UnitPrice * il.quantity) FROM InvoiceLine il INNER JOIN Invoice i USING (InvoiceId)WHERE i.CustomerId = c.CustomerId) AS 'Total Gastado'
FROM Customer c;

SELECT * FROM customer_purchase_summary;

-- 2

SELECT * FROM Customer;
SELECT * FROM Artist;

DROP PROCEDURE IF EXISTS artist_list_by_city;

DELIMITER //
CREATE PROCEDURE artist_list_by_city (IN Ciudad VARCHAR(255), OUT  Lista TEXT)
BEGIN
	DECLARE ArtistName VARCHAR(255);
    DECLARE Aux BOOLEAN;
    
    DECLARE ArtistList CURSOR FOR SELECT DISTINCT ar.Name FROM Customer c 
    INNER JOIN Invoice i USING (CustomerId)
    INNER JOIN InvoiceLine li USING (InvoiceId)
    INNER JOIN Track t USING (TrackId)
    INNER JOIN Album a USING (AlbumId)
    INNER JOIN Artist ar USING (ArtistId)
    WHERE c.City = Ciudad;
    
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET Aux = 1;
    
	SET  Lista = '';
	OPEN ArtistList;
    
    BucleMagico: LOOP
		FETCH ArtistList INTO ArtistName;
			IF Aux THEN
				LEAVE BucleMagico;
			END IF;
            
            IF Lista = '' THEN
				SET Lista = ArtistName;
			ELSE
				SET Lista = CONCAT(ArtistName, '; ', Lista);
			END IF;

	END LOOP BucleMagico;
    CLOSE ArtistList;
END //
DELIMITER ;

call artist_list_by_city("Oslo", @LISTA);
SELECT @LISTA;

-- 3
ALTER TABLE Invoice ADD COLUMN LastModification DATETIME;
ALTER TABLE Invoice ADD COLUMN LastModifierUser VARCHAR(255);

SELECT * FROM Invoice;

DELIMITER //
CREATE TRIGGER before_insert_invoice BEFORE INSERT ON Invoice FOR EACH ROW
    BEGIN
		SET NEW.LastModification = NOW();
        SET NEW.LastModifierUser = USER();
        SET NEW.InvoiceDate = NOW();
	END //
DELIMITER ;

DELIMITER //
CREATE TRIGGER before_update_invoice BEFORE UPDATE ON Invoice FOR EACH ROW
    BEGIN
		SET NEW.LastModification = NOW();
        SET NEW.LastModifierUser = USER();
        IF NEW.BillingState = 'SP' THEN
			SET NEW.InvoiceDate = NOW();
		END IF;
	END //
    
DELIMITER ;

UPDATE Invoice SET BillingState = 'SP' WHERE InvoiceId = 1;

-- 4

/*
 Los procedimientos almacenados, al igual que los triggers, son pedazos de codigo SQL almacenados en la base de datos. Se diferencian en que los triggers se disparan cuando se cumple 
una condicion especifica, como la modificacion/insercion/eliminacion de una tabla, y los procedimientos se llaman, es decir que uno tiene que utilizar call para poder ejecutarlo.
Un trigger podria usarse para hacer tareas rutinarias automaticamente, como actualizar la fecha de ultima actualizacion cuando se modifica un campo de cierta tabla. Un procedimiento
podria ser un get especial a clientes que cumplen cierta condicion, esto tambien podria hacerce desde el backend de la app pero los procedimientos tienen la ventaja de que estan
almacenados en la bd, por lo tanto, si la app tiene que hacer una migracion a otro lenguaje o a otra herramienta los metodos que se utilizaban no solo no se borran sino que 
todavia se llaman igual. Tambien a un procedimiento se le pueden pasar parametros que utilice para filtrar datos, al igual que tambien puede devolver una lista de datos.
El cursor en el procedimiento almacena una lista que luego puede ser recorrida por un bucle, un especie de for cliente in lista_clientes, siendo lista_clientes el cursor.

 Un trigger puede actuar BEFORE or AFTER alguna de las operaciones basicas(INSERT, ALTER, DELETE) y pueden modificar los campos de la tabla OLD y de la tabla NEW. 
Por ejemplo puedes hacer que antes(BEFORE) de que el campo 'precio' de algo cambie, que almacene el precio viejo(el de la tabla OLD) en otra tabla que funcione como historial 
de precios.
 
  En un procedimiento puedes declarar variables para identar sobre ellas utilizando bucles y condicionales, estas variables existen solo en el procedimiento y no son persistentes 
 en la bd. Los parametros pueden ser in, out or inout, siendo 'in' los parametros de entrada, 'out' los de salida(un especie de 'return') y los 'inout' funcionan de manera que la variable
 entrante, que es utilizada por el procedure para filtrar, luego cambia su valor a lo que el procedimiento devuelva. Un ejemplo de inout podria ser que le pasas una lista de clientes
 'clients_list', el procedimiento filtra por ciudad, edad y los ordena por id, y luego el valor de 'clients_list' pasa a ser esa lista filtrada.
*/