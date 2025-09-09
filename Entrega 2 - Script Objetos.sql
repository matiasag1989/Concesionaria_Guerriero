
-- Entrega 2
-- Script de creación de objetos

USE concesionaria;
DELIMITER $$

/* =========================
   FUNCIONES PERSONALIZADAS
   ========================= */

DROP FUNCTION IF EXISTS fn_tiene_usado $$
CREATE FUNCTION fn_tiene_usado(p_id_usado INT)
RETURNS TINYINT
DETERMINISTIC
NO SQL
BEGIN
    RETURN IF(p_id_usado IS NULL, 0, 1);
END $$

DROP FUNCTION IF EXISTS fn_valor_usado_por_id $$
CREATE FUNCTION fn_valor_usado_por_id(p_id_usado INT)
RETURNS DECIMAL(12,2)
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE v DECIMAL(12,2);
    IF p_id_usado IS NULL THEN
        RETURN 0.00;
    END IF;
    SELECT COALESCE(u.valor_usado, 0.00) INTO v
      FROM Usado u
     WHERE u.id_usado = p_id_usado
     LIMIT 1;
    RETURN COALESCE(v, 0.00);
END $$

DROP FUNCTION IF EXISTS fn_porcentaje $$
CREATE FUNCTION fn_porcentaje(p_parte BIGINT, p_total BIGINT)
RETURNS DECIMAL(7,2)
DETERMINISTIC
NO SQL
BEGIN
    IF p_total IS NULL OR p_total = 0 THEN
        RETURN 0.00;
    END IF;
    RETURN ROUND((p_parte / p_total) * 100, 2);
END $$

/* ==============
   VISTAS (VIEWS)
   ============== */

DROP VIEW IF EXISTS v_ventas_detalle $$
CREATE VIEW v_ventas_detalle AS
SELECT
    v.id_venta,
    c.id_cliente,
    c.nombre        AS nombre_cliente,
    m.id_modelo,
    m.nombre_modelo,
    ver.id_version,
    ver.nombre_version,
    p.id_plan,
    p.nombre_plan,
    v.id_usado,
    fn_tiene_usado(v.id_usado) AS con_usado,
    fn_valor_usado_por_id(v.id_usado) AS valor_usado
FROM Venta v
JOIN Cliente c   ON c.id_cliente  = v.id_cliente
JOIN Modelo  m   ON m.id_modelo   = v.id_modelo
JOIN `Version` ver ON ver.id_version = v.id_version
JOIN `Plan`    p  ON p.id_plan     = v.id_plan
LEFT JOIN Usado u ON u.id_usado    = v.id_usado $$

DROP VIEW IF EXISTS v_ventas_con_usado $$
CREATE VIEW v_ventas_con_usado AS
SELECT * FROM v_ventas_detalle WHERE con_usado = 1 $$

DROP VIEW IF EXISTS v_ventas_sin_usado $$
CREATE VIEW v_ventas_sin_usado AS
SELECT * FROM v_ventas_detalle WHERE con_usado = 0 $$

DROP VIEW IF EXISTS v_ranking_modelos $$
CREATE VIEW v_ranking_modelos AS
SELECT
    m.id_modelo,
    m.nombre_modelo,
    COUNT(*) AS cantidad_ventas
FROM Venta v
JOIN Modelo m ON m.id_modelo = v.id_modelo
GROUP BY m.id_modelo, m.nombre_modelo
ORDER BY cantidad_ventas DESC $$

DROP VIEW IF EXISTS v_ranking_planes $$
CREATE VIEW v_ranking_planes AS
SELECT
    p.id_plan,
    p.nombre_plan,
    COUNT(*) AS cantidad_ventas,
    fn_porcentaje(COUNT(*), (SELECT COUNT(*) FROM Venta)) AS porcentaje_sobre_total
FROM Venta v
JOIN `Plan` p ON p.id_plan = v.id_plan
GROUP BY p.id_plan, p.nombre_plan
ORDER BY cantidad_ventas DESC $$

/* ===================
   STORED PROCEDURES
   =================== */

DROP PROCEDURE IF EXISTS sp_registrar_venta $$
CREATE PROCEDURE sp_registrar_venta(
    IN p_id_cliente INT,
    IN p_id_modelo  INT,
    IN p_id_version INT,
    IN p_id_plan    INT,
    IN p_id_usado   INT
)
BEGIN
    -- Validaciones de existencia
    IF (SELECT COUNT(*) FROM Cliente WHERE id_cliente = p_id_cliente) = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Cliente inexistente';
    END IF;
    IF (SELECT COUNT(*) FROM Modelo WHERE id_modelo = p_id_modelo) = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Modelo inexistente';
    END IF;
    IF (SELECT COUNT(*) FROM `Version` WHERE id_version = p_id_version) = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Versión inexistente';
    END IF;
    IF (SELECT COUNT(*) FROM `Plan` WHERE id_plan = p_id_plan) = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Plan inexistente';
    END IF;

    -- Si trae usado, que no esté ya asociado
    IF p_id_usado IS NOT NULL THEN
        IF (SELECT COUNT(*) FROM Venta WHERE id_usado = p_id_usado) > 0 THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El usado ya fue asociado a otra venta';
        END IF;
    END IF;

    INSERT INTO Venta(id_cliente, id_modelo, id_version, id_plan, id_usado)
    VALUES (p_id_cliente, p_id_modelo, p_id_version, p_id_plan, p_id_usado);
END $$

DROP PROCEDURE IF EXISTS sp_ventas_por_cliente $$
CREATE PROCEDURE sp_ventas_por_cliente(IN p_id_cliente INT)
BEGIN
    SELECT * FROM v_ventas_detalle
     WHERE id_cliente = p_id_cliente
     ORDER BY id_venta DESC;
END $$

DROP PROCEDURE IF EXISTS sp_resumen_ventas $$
CREATE PROCEDURE sp_resumen_ventas()
BEGIN
    SELECT * FROM v_ranking_modelos;
    SELECT * FROM v_ranking_planes;
END $$

/* =========
   TRIGGERS
   ========= */

DROP TRIGGER IF EXISTS trg_venta_usado_unico $$
CREATE TRIGGER trg_venta_usado_unico
BEFORE INSERT ON Venta
FOR EACH ROW
BEGIN
    IF NEW.id_usado IS NOT NULL THEN
        IF (SELECT COUNT(*) FROM Venta WHERE id_usado = NEW.id_usado) > 0 THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No se puede reutilizar el mismo id_usado en otra venta';
        END IF;
    END IF;
END $$

DROP TRIGGER IF EXISTS trg_cliente_con_ventas_no_delete $$
CREATE TRIGGER trg_cliente_con_ventas_no_delete
BEFORE DELETE ON Cliente
FOR EACH ROW
BEGIN
    IF (SELECT COUNT(*) FROM Venta WHERE id_cliente = OLD.id_cliente) > 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No se puede eliminar un cliente con ventas registradas';
    END IF;
END $$

DROP TRIGGER IF EXISTS trg_cliente_trim_nombre $$
CREATE TRIGGER trg_cliente_trim_nombre
BEFORE INSERT ON Cliente
FOR EACH ROW
BEGIN
    SET NEW.nombre = TRIM(NEW.nombre);
END $$

DELIMITER ;
