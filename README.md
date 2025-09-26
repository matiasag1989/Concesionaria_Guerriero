**Matias Guerriero**
# 📌 Entrega 1 - Base de Datos - Concesionaria

## 📄 Descripción del proyecto
Este proyecto corresponde a la **Entrega 1** del curso de Lenguaje SQL.  
La base de datos modela una concesionaria de autos **Peugeot** que ofrece planes de cuotas para la compra de vehículos 0 km.

Incluye:
- Modelos disponibles: 208 y 2008.
- Versiones: Allure, GT (y otras según disponibilidad).
- Planes de pago (ejemplo: 70/30).
- Opción de entrega de usado como parte de pago.
- Registro de clientes y sus compras.

===============================================================================

# 📌 Entrega 2 - Base de Datos - Concesionaria

## 📄 Descripción del proyecto
Este proyecto corresponde a la segunda entrega del final de Base de Datos.
Incluye creación de Vistas, Funciones, Stored Procedures y Triggers sobre el modelo de concesionaria presentado en la primera entrega.

===============================================================================

# 📌 Entrega Final - Base de Datos - Concesionaria

Proyecto SQL de **Concesionaria Peugeot** que integra la Entrega 1 (modelo y DDL) y la Entrega 2 (lógica y consultas), más casos de prueba para validar el comportamiento end-to-end.

Incluye:
- Esquema relacional (clientes, modelos/versiones, planes, usados, ventas) y carga mínima de datos.
- Funciones: p. ej. `fn_tiene_usado`, `fn_valor_usado_por_id`, `fn_porcentaje`.
- Procedimientos: p. ej. `sp_registrar_venta`, `sp_ventas_por_cliente`, `sp_resumen_ventas`.
- Triggers: trim de nombre en cliente, bloqueo de usado repetido en ventas y no borrado de cliente con ventas.
- Vistas: detalle de ventas, con/sin usado, y rankings por modelo/plan.
- Casos de prueba (`casos_prueba.sql`): ejecuta inserts/calls/selects para verificar funciones, procedimientos, triggers y vistas.
