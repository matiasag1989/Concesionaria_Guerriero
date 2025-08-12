-- Entrega 1
-- Creación de base de datos
CREATE DATABASE concesionaria;
USE concesionaria;

-- ========================
-- TABLAS
-- ========================

-- Tabla Cliente
CREATE TABLE Cliente (
    id_cliente INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100) NOT NULL,
    direccion VARCHAR(150)
);

-- Tabla Modelo
CREATE TABLE Modelo (
    id_modelo INT PRIMARY KEY AUTO_INCREMENT,
    nombre_modelo VARCHAR(50) NOT NULL
);

-- Tabla Versión
CREATE TABLE Version (
    id_version INT PRIMARY KEY AUTO_INCREMENT,
    nombre_version VARCHAR(50) NOT NULL,
    id_modelo INT NOT NULL,
    FOREIGN KEY (id_modelo) REFERENCES Modelo(id_modelo)
);

-- Tabla Plan
CREATE TABLE Plan (
    id_plan INT PRIMARY KEY AUTO_INCREMENT,
    nombre_plan VARCHAR(50) NOT NULL,
    descripcion VARCHAR(150)
);

-- Tabla Usado
CREATE TABLE Usado (
    id_usado INT PRIMARY KEY AUTO_INCREMENT,
    valor_usado DECIMAL(10,2) NOT NULL
);

-- Tabla Venta
CREATE TABLE Venta (
    id_venta INT PRIMARY KEY AUTO_INCREMENT,
    id_cliente INT NOT NULL,
    id_modelo INT NOT NULL,
    id_version INT NOT NULL,
    id_plan INT NOT NULL,
    id_usado INT NULL,
    FOREIGN KEY (id_cliente) REFERENCES Cliente(id_cliente),
    FOREIGN KEY (id_modelo) REFERENCES Modelo(id_modelo),
    FOREIGN KEY (id_version) REFERENCES Version(id_version),
    FOREIGN KEY (id_plan) REFERENCES Plan(id_plan),
    FOREIGN KEY (id_usado) REFERENCES Usado(id_usado)
);

-- ========================
-- INSERTS DE EJEMPLO
-- ========================

-- Modelos
INSERT INTO Modelo (nombre_modelo) VALUES
('Peugeot 208'),
('Peugeot 2008');

-- Versiones
INSERT INTO Version (nombre_version, id_modelo) VALUES
('Allure', 1),
('GT', 1),
('Active', 1),
('Allure', 2),
('GT', 2);

-- Planes
INSERT INTO Plan (nombre_plan, descripcion) VALUES
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

-- Usados (solo para 5 clientes)
INSERT INTO Usado (valor_usado) VALUES
(3000000.00), -- Juan
(2500000.00), -- Luis
(2800000.00), -- Carlos
(2200000.00), -- Pedro
(3100000.00); -- Miguel

-- Ventas
INSERT INTO Venta (id_cliente, id_modelo, id_version, id_plan, id_usado) VALUES
(1, 1, 2, 1, 1),   -- Juan: 208 GT, 70/30, usado
(2, 2, 5, 2, NULL),-- María: 2008 GT, 60/40, sin usado
(3, 1, 1, 3, 2),   -- Luis: 208 Allure, 50/50, usado
(4, 2, 4, 1, NULL),-- Ana: 2008 Allure, 70/30, sin usado
(5, 1, 3, 2, 3),   -- Carlos: 208 Active, 60/40, usado
(6, 1, 1, 1, NULL),-- Lucía: 208 Allure, 70/30, sin usado
(7, 2, 4, 3, 4),   -- Pedro: 2008 Allure, 50/50, usado
(8, 2, 5, 1, NULL),-- Sofía: 2008 GT, 70/30, sin usado
(9, 1, 2, 2, 5),   -- Miguel: 208 GT, 60/40, usado
(10, 2, 4, 3, NULL);-- Valentina: 2008 Allure, 50/50, sin usado