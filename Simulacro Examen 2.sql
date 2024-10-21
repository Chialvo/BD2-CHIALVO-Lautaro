USE VIVERO_FENIX;

/*
1) Crea una vista llamada customer_purchase_summary que proporcione un resumen de las compras de los clientes.
La vista debe incluir las siguientes columnas: id del cliente, nombre del cliente, cantidad total de compras realizadas,
total gastado en compras, categoría de planta más comprada y la cantidad de plantas en cada categoría que el cliente ha comprado.
Utiliza funciones de agregación y GROUP_CONCAT según sea necesario.

2) Crea un procedimiento almacenado con un parámetro de salida que genere una lista de clientes activos en una cierta localidad.
El procedimiento debe aceptar el nombre de la localidad como entrada y devolver una lista de nombres y apellidos de clientes separados por ";".
Utiliza un cursor para recorrer los resultados y garantiza que solo se incluyan clientes de la localidad especificada en la lista.

3) Agrega una nueva columna llamada lastModification a la tabla PLANTAS y emplea triggers para garantizar que esta columna refleje
la fecha y hora de las operaciones de inserción y actualización. Además, implementa una columna lastModifier User y sus respectivos
triggers para rastrear qué usuario de MySQL realizó la última modificación en la fila, considerando la posibilidad de múltiples usuarios además de root. 
*/

-- 1

DROP VIEW customer_purchase_summary;

CREATE VIEW customer_purchase_summary AS
SELECT c.COD_CLIENTE, CONCAT(c.NOMBRE, ' ', c.APELLIDO) AS 'Nombre', 
(SELECT COUNT(f.NRO_FACTURA) FROM FACTURAS f WHERE f.COD_CLIENTE = c.COD_CLIENTE) AS 'Cantidad de compras', -- Cuenta la cantidad de facturas del cliente
(SELECT SUM(p.PRECIO * df.CANTIDAD)FROM DETALLES_FACTURAS df INNER JOIN FACTURAS f USING (NRO_FACTURA) INNER JOIN PLANTAS p USING (COD_PLANTA) WHERE f.COD_CLIENTE = c.COD_CLIENTE) AS 'Total Gastado', -- suma los productos entre el precio de la planta y la cantidad de plantas compradas
(SELECT NOMBRE FROM DETALLES_FACTURAS INNER JOIN FACTURAS F USING(NRO_FACTURA) INNER JOIN PLANTAS P USING(COD_PLANTA) INNER JOIN TIPOS_PLANTAS TP USING(COD_TIPO_PLANTA) WHERE F.COD_CLIENTE=c.COD_CLIENTE GROUP BY COD_TIPO_PLANTA ORDER BY SUM(CANTIDAD) DESC LIMIT 1) AS CATEGORIAMASCOMPRADA, -- Saca las categorias que mas se repiten, ordenan los nombres de las categorias de en una lista de forma que la que mas se repite queda primera y recorta la lista para que solo muestre el primer elemento

(SELECT GROUP_CONCAT(CANT SEPARATOR "; ") FROM (SELECT CONCAT(NOMBRE,": ",SUM(CANTIDAD)) AS CANT FROM DETALLES_FACTURAS INNER JOIN FACTURAS F USING(NRO_FACTURA) INNER JOIN PLANTAS P USING(COD_PLANTA) INNER JOIN TIPOS_PLANTAS TP USING(COD_TIPO_PLANTA) WHERE F.COD_CLIENTE=c.COD_CLIENTE GROUP BY COD_TIPO_PLANTA) AS CANTXCAT) AS CANTIDADXCATEGORIA
FROM CLIENTES c;

SELECT * FROM customer_purchase_summary;

-- 2

DROP PROCEDURE clientesActivosLocalidad;

DELIMITER //
CREATE PROCEDURE clientesActivosLocalidad(IN LOCALIDAD VARCHAR(255), OUT LISTA TEXT)
BEGIN
	DECLARE CLIENTE_NOMBRE VARCHAR(255);
    DECLARE FINISHED BOOLEAN;
    DECLARE LISTA_CLIENTES CURSOR FOR SELECT CONCAT(C.NOMBRE, ' ', C.APELLIDO) FROM CLIENTES C INNER JOIN LOCALIDADES L USING (COD_LOCALIDAD) WHERE L.NOMBRE = LOCALIDAD;
    
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET FINISHED = 1;
    
	SET LISTA = '';
	OPEN LISTA_CLIENTES;
    
    BucleMagico: LOOP
		FETCH LISTA_CLIENTES INTO CLIENTE_NOMBRE; #for cliente_nombre in lista_clientes
			IF FINISHED THEN #if FINISHED == TRUE
				LEAVE BucleMagico;
			END IF;
            
            IF LISTA = '' THEN
				SET LISTA = CLIENTE_NOMBRE;
			ELSE
				SET LISTA = CONCAT(CLIENTE_NOMBRE, '; ', LISTA);
			END IF;
	END LOOP BucleMagico;
    CLOSE LISTA_CLIENTES;
END //

DELIMITER ;

call clientesActivosLocalidad("CORDOBA",@LISTA);
SELECT @LISTA;

-- 3

ALTER TABLE PLANTAS ADD COLUMN LASTMODIFICATION DATETIME;
ALTER TABLE PLANTAS ADD COLUMN LASTMODIFIERUSER VARCHAR(255);
SELECT * FROM PLANTAS;

DELIMITER //
CREATE TRIGGER before_update_plantas BEFORE UPDATE ON PLANTAS FOR EACH ROW
    BEGIN
		SET NEW.LASTMODIFICATION = NOW();
        SET NEW.LASTMODIFIERUSER = USER();
	END //
DELIMITER ;

DELIMITER //
CREATE TRIGGER before_insert_plantas BEFORE INSERT ON PLANTAS FOR EACH ROW
    BEGIN
		SET NEW.LASTMODIFICATION = NOW();
        SET NEW.LASTMODIFIERUSER = USER();
	END //
DELIMITER ;


INSERT INTO PLANTAS (COD_PLANTA, DESCRIPCION, COD_TIPO_PLANTA, PRECIO, STOCK) 
VALUES (24, 'PLANTAFACHERA', 1, 45.32, 32);

UPDATE PLANTAS SET PRECIO = 50.00 WHERE COD_PLANTA = 1;  
SELECT * FROM PLANTAS;
SHOW TRIGGERS LIKE 'PLANTAS';