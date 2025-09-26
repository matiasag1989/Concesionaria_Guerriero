-- ENTREGA FINAL: PROYECTO CONCESIONARIA
-- CONSULTAS AD-HOC
-- AUTOR: MATIAS GUERRIERO
-- ================================================

USE concesionaria;

SET autocommit = 0;
START TRANSACTION;

SELECT 'BD actual' AS info, DATABASE() AS db;

-- 1) TABLAS BASE:

SET @prev_safe := @@SQL_SAFE_UPDATES;
SET SQL_SAFE_UPDATES = 0;

SET FOREIGN_KEY_CHECKS = 0;
DELETE FROM Venta;
DELETE FROM Usado;
DELETE FROM `Version`;
DELETE FROM Modelo;
DELETE FROM `Plan`;
DELETE FROM Cliente;
SET FOREIGN_KEY_CHECKS = 1;

SET SQL_SAFE_UPDATES = @prev_safe;

-- Modelos
INSERT INTO Modelo (nombre_modelo)
VALUES ('Peugeot 208'), ('Peugeot 2008');

SET @id_mod_208  := (SELECT id_modelo FROM Modelo WHERE nombre_modelo = 'Peugeot 208'  ORDER BY id_modelo DESC LIMIT 1);
SET @id_mod_2008 := (SELECT id_modelo FROM Modelo WHERE nombre_modelo = 'Peugeot 2008' ORDER BY id_modelo DESC LIMIT 1);

-- Versiones
INSERT INTO `Version` (nombre_version, id_modelo)
VALUES
('Allure', @id_mod_208),
('GT',     @id_mod_208),
('Allure', @id_mod_2008),
('GT',     @id_mod_2008);

SET @ver_208_gt   := (SELECT id_version FROM `Version` WHERE nombre_version = 'GT'    AND id_modelo = @id_mod_208  ORDER BY id_version DESC LIMIT 1);
SET @ver_2008_gt  := (SELECT id_version FROM `Version` WHERE nombre_version = 'GT'    AND id_modelo = @id_mod_2008 ORDER BY id_version DESC LIMIT 1);

-- Planes
INSERT INTO `Plan` (nombre_plan, descripcion)
VALUES
('70/30', '70% en cuotas, 30% al final'),
('60/40', '60% en cuotas, 40% al final'),
('50/50', '50% en cuotas, 50% al final');

SET @plan_70_30 := (SELECT id_plan FROM `Plan` WHERE nombre_plan = '70/30' ORDER BY id_plan DESC LIMIT 1);
SET @plan_60_40 := (SELECT id_plan FROM `Plan` WHERE nombre_plan = '60/40' ORDER BY id_plan DESC LIMIT 1);

-- Clientes (prueba trigger trg_cliente_trim_nombre y no-delete)
INSERT INTO Cliente (nombre, direccion) VALUES
('  Juan Pérez  ', 'Av. Siempre Viva 123'),
('María Gómez', 'Calle Falsa 456');

-- Verificar trim del BEFORE INSERT (Cliente)
SELECT 'After trim nombre (Cliente)' AS _check, id_cliente, nombre, direccion
  FROM Cliente
 ORDER BY id_cliente;

-- Usados
INSERT INTO Usado (valor_usado) VALUES (3000000.00), (2500000.00);

-- 2) FUNCIONES:

SELECT 'fn_tiene_usado(NULL) => 0' AS _desc, fn_tiene_usado(NULL) AS resultado;
SELECT 'fn_tiene_usado(1)    => 1' AS _desc, fn_tiene_usado(1)    AS resultado;

SELECT 'fn_valor_usado_por_id(NULL) => 0.00' AS _desc, fn_valor_usado_por_id(NULL) AS resultado;
SELECT 'fn_valor_usado_por_id(1)    => 3000000.00' AS _desc, fn_valor_usado_por_id(1) AS resultado_aprox;

SELECT 'fn_porcentaje(2, 10) => 20.00' AS _desc, fn_porcentaje(2,10) AS resultado;
SELECT 'fn_porcentaje(1, 0)  => 0.00 (protege división por cero)' AS _desc, fn_porcentaje(1,0) AS resultado;

-- 3) PROCEDIMIENTO PRINCIPAL: sp_registrar_venta
--    Valida: cliente/modelo/version/plan existen,
--            usado no repetido, inserta en Venta.

SET @cli_juan  := (
  SELECT id_cliente FROM Cliente
  WHERE TRIM(nombre) = 'Juan Pérez'
  ORDER BY id_cliente DESC LIMIT 1
);
SET @cli_maria := (
  SELECT id_cliente FROM Cliente
  WHERE nombre = 'María Gómez'
  ORDER BY id_cliente DESC LIMIT 1
);

SELECT @cli_juan  AS id_juan, @cli_maria AS id_maria;

-- Modelos y versiones
SET @id_mod_208  := (SELECT id_modelo  FROM Modelo   WHERE nombre_modelo = 'Peugeot 208'  ORDER BY id_modelo  DESC LIMIT 1);
SET @id_mod_2008 := (SELECT id_modelo  FROM Modelo   WHERE nombre_modelo = 'Peugeot 2008' ORDER BY id_modelo  DESC LIMIT 1);
SET @ver_208_gt  := (SELECT id_version FROM `Version` WHERE nombre_version = 'GT' AND id_modelo = @id_mod_208  ORDER BY id_version DESC LIMIT 1);
SET @ver_2008_gt := (SELECT id_version FROM `Version` WHERE nombre_version = 'GT' AND id_modelo = @id_mod_2008 ORDER BY id_version DESC LIMIT 1);

-- Planes
SET @plan_70_30 := (SELECT id_plan FROM `Plan` WHERE nombre_plan = '70/30' ORDER BY id_plan DESC LIMIT 1);
SET @plan_60_40 := (SELECT id_plan FROM `Plan` WHERE nombre_plan = '60/40' ORDER BY id_plan DESC LIMIT 1);

-- Usados
SET @usado1 := (SELECT id_usado FROM Usado ORDER BY id_usado ASC LIMIT 1);

-- Venta SIN usado (Juan + 208 GT)
CALL sp_registrar_venta(@cli_juan,  @id_mod_208,  @ver_208_gt,  @plan_70_30, NULL);

-- Venta CON usado (María + 2008 GT)
CALL sp_registrar_venta(@cli_maria, @id_mod_2008, @ver_2008_gt, @plan_60_40, @usado1);

-- Comprobar inserciones
SELECT 'Ventas cargadas' AS _info;
SELECT * FROM Venta ORDER BY id_venta;

-- 4) TRIGGER: trg_venta_usado_unico (no debe permitir reutilizar usado)

SET @error := NULL;

SELECT 'Reutilizar usado (espera ERROR por trigger)' AS _desc, @error AS resultado_esperado;

-- 5) VISTAS: v_ventas_detalle / v_ventas_con_usado / v_ventas_sin_usado
--            v_ranking_modelos / v_ranking_planes

SELECT 'v_ventas_detalle (muestra flags y valor_usado vía funciones)' AS _info;
SELECT * FROM v_ventas_detalle ORDER BY id_venta;

SELECT 'v_ventas_con_usado' AS _info;
SELECT * FROM v_ventas_con_usado;

SELECT 'v_ventas_sin_usado' AS _info;
SELECT * FROM v_ventas_sin_usado;

SELECT 'v_ranking_modelos' AS _info;
SELECT * FROM v_ranking_modelos;

SELECT 'v_ranking_planes' AS _info;
SELECT * FROM v_ranking_planes;

-- 6) PROCEDIMIENTOS DE CONSULTA: sp_ventas_por_cliente / sp_resumen_ventas

CALL sp_ventas_por_cliente(1);  -- trae ventas del cliente 1
CALL sp_resumen_ventas();       -- ranking modelos + ranking planes (dos SELECTs)

-- 7) TRIGGER: trg_cliente_con_ventas_no_delete (bloquea borrar clientes con ventas)

-- Reutilizar usado (DEBE FALLAR si el trigger funciona)
INSERT INTO Venta (id_cliente, id_modelo, id_version, id_plan, id_usado)
VALUES (@cli_juan, @id_mod_208, @ver_208_gt, @plan_70_30, @usado1);

-- Borrar cliente con ventas (DEBE FALLAR si el trigger funciona)
DELETE FROM Cliente WHERE id_cliente = @cli_juan;

SELECT 'Borrar cliente con ventas (espera ERROR por trigger)' AS _desc, @err_del AS resultado_esperado;

-- Intentar borrar cliente sin ventas (crear uno nuevo y borrar)
INSERT INTO Cliente (nombre, direccion) VALUES ('  Cliente Sin Ventas  ', 'Test 123');
SET @id_sin_ventas := LAST_INSERT_ID();

-- Probar el trim también en este insert
SELECT 'Cliente creado para borrado' AS _info, @id_sin_ventas AS id_creado;
SELECT id_cliente, nombre FROM Cliente WHERE id_cliente = @id_sin_ventas;

DELETE FROM Cliente WHERE id_cliente = @id_sin_ventas;
SELECT 'Borrado de cliente sin ventas OK' AS _info;

DELIMITER $$

DROP PROCEDURE IF EXISTS _test_reutilizar_usado $$
CREATE PROCEDURE _test_reutilizar_usado()
BEGIN
  DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
  BEGIN
    SELECT 'ERROR_OK: el trigger bloqueó el usado repetido' AS resultado;
  END;

  -- Intento que DEBERÍA FALLAR (mismo @usado1 otra vez)
  INSERT INTO Venta (id_cliente, id_modelo, id_version, id_plan, id_usado)
  VALUES (@cli_juan, @id_mod_208, @ver_208_gt, @plan_70_30, @usado1);

  -- Si llegás acá, NO falló (revisar trigger)
  SELECT 'PASÓ sin error (revisar trigger)' AS resultado;
END $$
CALL _test_reutilizar_usado() $$
DROP PROCEDURE IF EXISTS _test_reutilizar_usado $$

DELIMITER ;

-- ===== Test: borrar cliente con ventas (debe bloquear) =====
DELIMITER $$

DROP PROCEDURE IF EXISTS _test_borrar_cliente $$
CREATE PROCEDURE _test_borrar_cliente()
BEGIN
  DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
  BEGIN
    SELECT 'ERROR_OK: el trigger impidió borrar cliente con ventas' AS resultado;
  END;

  DELETE FROM Cliente WHERE id_cliente = @cli_juan;

  SELECT 'PASÓ sin error (revisar trigger)' AS resultado;
END $$
CALL _test_borrar_cliente() $$
DROP PROCEDURE IF EXISTS _test_borrar_cliente $$

DELIMITER ;

-- FIN: revertimos por defecto

ROLLBACK;