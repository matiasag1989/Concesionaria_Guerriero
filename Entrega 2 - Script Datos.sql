-- Entrega 2
-- Script de creación de datos

USE concesionaria;

START TRANSACTION;

SET FOREIGN_KEY_CHECKS = 0;
TRUNCATE TABLE Venta;
TRUNCATE TABLE Usado;
TRUNCATE TABLE `Version`;
TRUNCATE TABLE Modelo;
TRUNCATE TABLE `Plan`;
TRUNCATE TABLE Cliente;
SET FOREIGN_KEY_CHECKS = 1;

-- Modelos
INSERT INTO Modelo (nombre_modelo) VALUES
('Peugeot 208'),
('Peugeot 2008');

-- Versiones
INSERT INTO `Version` (nombre_version, id_modelo) VALUES
('Allure', 1),
('GT', 1),
('Active', 1),
('Allure', 2),
('GT', 2);

-- Planes
INSERT INTO `Plan` (nombre_plan, descripcion) VALUES
('70/30', '70% en cuotas, 30% al final'),
('60/40', '60% en cuotas, 40% al final'),
('50/50', '50% en cuotas, 50% al final');

-- Clientes
INSERT INTO Cliente (nombre, direccion) VALUES
('Juan Pérez', 'Av. Siempre Viva 123'),
('María Gómez', 'Calle Falsa 456'),
('Luis Rodríguez', 'Boulevard Central 789'),
('Ana Torres', 'Av. Libertad 1000'),
('Carlos López', 'Calle San Martín 222'),
('Lucía Fernández', 'Ruta 9 Km 45'),
('Pedro Martínez', 'Calle Las Flores 89'),
('Sofía Herrera', 'Pasaje Belgrano 45'),
('Miguel Castro', 'Avenida Mitre 500'),
('Valentina Díaz', 'Calle Córdoba 321');

-- Usados
INSERT INTO Usado (valor_usado) VALUES
(3000000.00),
(2500000.00),
(2800000.00),
(2200000.00),
(3100000.00);

-- Ventas
INSERT INTO Venta (id_cliente, id_modelo, id_version, id_plan, id_usado) VALUES
(1, 1, 2, 1, 1),
(2, 2, 5, 2, NULL),
(3, 1, 1, 3, 2),
(4, 2, 4, 1, NULL),
(5, 1, 3, 2, 3),
(6, 1, 1, 1, NULL),
(7, 2, 4, 3, 4),
(8, 2, 5, 1, NULL),
(9, 1, 2, 2, 5),
(10, 2, 4, 3, NULL);

COMMIT;
