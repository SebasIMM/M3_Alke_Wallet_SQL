-- crear schema alke_wallet
CREATE SCHEMA alke_wallet 
DEFAULT CHARACTER SET utf8 
COLLATE utf8_spanish2_ci ;

USE alke_wallet;

-- crear tablas usuario, moneda y transaccion
CREATE TABLE IF NOT EXISTS usuario (
id_usuario INT NOT NULL,
nombre VARCHAR(45) NOT NULL,
correo_electronico VARCHAR(50) NOT NULL,
contrasenia VARCHAR(64) NOT NULL,
saldo INT DEFAULT 0,
PRIMARY KEY (id_usuario));

CREATE TABLE IF NOT EXISTS moneda (
id_moneda INT NOT NULL,
moneda_nombre VARCHAR(25) NOT NULL,
moneda_simbolo VARCHAR(3) NOT NULL,
PRIMARY KEY (id_moneda));

CREATE TABLE IF NOT EXISTS transaccion (
id_transaccion INT NOT NULL,
id_usuario_emisor INT NOT NULL,
id_usuario_receptor INT NOT NULL,
id_moneda INT NOT NULL,
importe INT NOT NULL,
fecha_transaccion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
INDEX fk_transaccion_id_emisorx (id_usuario_emisor ASC) VISIBLE,
CONSTRAINT fk_transaccion_emisor
FOREIGN KEY (id_usuario_emisor)
REFERENCES usuario (id_usuario)
ON DELETE NO ACTION
ON UPDATE NO ACTION,
INDEX fk_transaccion_id_receptorx (id_usuario_receptor ASC) VISIBLE, 
CONSTRAINT fk_transaccion_receptor
FOREIGN KEY (id_usuario_receptor)
REFERENCES usuario (id_usuario)
ON DELETE NO ACTION
ON UPDATE NO ACTION,
INDEX fk_transaccion_id_monedax (id_moneda ASC) VISIBLE, 
CONSTRAINT fk_transaccion_moneda
FOREIGN KEY (id_moneda)
REFERENCES moneda (id_moneda)
ON DELETE NO ACTION
ON UPDATE NO ACTION,
PRIMARY KEY (id_transaccion));


-- Poblar tabla usuario
INSERT INTO usuario 
VALUES
(1, 'Juan Pérez', 'juanperez@example.com', 'contraseña123', 100),(2, 'María García', 'mariagarcia@example.com', 'clave456', 200),(3, 'Carlos Rodríguez', 'carlosrodriguez@example.com', 'pwd789', 300),(4, 'Ana Martínez', 'anamartinez@example.com', 'passwordabc', 400),(5, 'Laura López', 'lauralopez@example.com', 'qwerty123', 500),(6, 'Antonio González', 'antoniogonzalez@example.com', 'abc123', 600),(7, 'Isabel Fernández', 'isabelfernandez@example.com', 'xyz789', 700),(8, 'José Ruiz', 'joseruiz@example.com', 'qazwsx123', 800),(9, 'Carmen Sánchez', 'carmensanchez@example.com', 'password123', 900),(10, 'Francisco Martínez', 'franmartinez@example.com', 'abcxyz789', 1000);

-- Poblar tabla moneda
INSERT INTO moneda 
VALUES 
(1, 'Dólar', 'USD'),(2, 'Euro', 'EUR'),(3, 'Libra esterlina', 'GBP'),(4, 'Yen', 'JPY'),(5, 'Peso', 'MXN');

-- Poblar tabla transaccion
SET @id_transaccion := 1;
SET @max_user_id := 10;
SET @max_currency_id := 5;

DELIMITER //

CREATE PROCEDURE PopulateTransactions()
BEGIN
    DECLARE i INT DEFAULT 0;
    DECLARE sender_id INT;
    DECLARE receiver_id INT;
    DECLARE currency_id INT;
    
    WHILE i < 20 DO
        SET sender_id = CEIL(RAND() * @max_user_id);
        SET receiver_id = CEIL(RAND() * @max_user_id);
        SET currency_id = CEIL(RAND() * @max_currency_id);
        
        -- Asegurar que sender_id y receiver_id son distintos
        WHILE sender_id = receiver_id DO
            SET receiver_id = CEIL(RAND() * @max_user_id);
        END WHILE;
        
        INSERT INTO transaccion (id_transaccion, id_usuario_emisor, id_usuario_receptor, id_moneda, importe)
        VALUES (@id_transaccion, sender_id, receiver_id, currency_id, CEIL(RAND() * 1000));
        
        SET @id_transaccion := @id_transaccion + 1;
        SET i := i + 1;
    END WHILE;
END//

CALL PopulateTransactions();


-- Querys solicitadas

-- 1. obtener el nombre de la moneda elegida por un usuario específico
SELECT 
    m.moneda_nombre AS nombre
FROM
    usuario AS u
        LEFT JOIN
    transaccion AS t ON u.id_usuario = t.id_usuario_emisor
        LEFT JOIN
    moneda AS m ON t.id_moneda = m.id_moneda
WHERE
    u.id_usuario = 1

-- 2. Obtener todas las transacciones registradas
SELECT * FROM transaccion;

-- 3. Obtener todas las transacciones realizadas por un usuario específico
SELECT * FROM transaccion AS t 
WHERE id_usuario_emisor = 4;

-- 4. Modificar el campo correo electrónico de un usuario específico
UPDATE usuario
SET correo_electronico = 'nuevo_correo@example.com'
WHERE id_usuario = 8;

SELECT * FROM usuario WHERE id_usuario = 8;

-- 5. Eliminar los datos de una transacción
DELETE FROM transaccion
WHERE id_transaccion = 4;

SELECT * FROM transaccion LIMIT 5;
