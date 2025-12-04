-- ================================================================
-- Carga de Datos de Prueba
-- ================================================================

-- 1. TABLA: usuarios (10 registros)
INSERT INTO usuarios (nombre, email, contrasena_hash, rol) VALUES
('Admin General', 'admin@ciudad.cl', 'hash_admin_1234', 'admin'),
('Planificador A', 'pa@ciudad.cl', 'hash_plan_a', 'planificador'),
('Planificador B', 'pb@ciudad.cl', 'hash_plan_b', 'planificador'),
('Analista Urbano', 'au@ciudad.cl', 'hash_analista', 'planificador'),
('Gestion Proyectos', 'gp@ciudad.cl', 'hash_gestion', 'planificador'),
('Usuario Prueba 1', 'up1@ciudad.cl', 'hash_up1', 'planificador'),
('Usuario Prueba 2', 'up2@ciudad.cl', 'hash_up2', 'planificador'),
('Jefe de Zona Sur', 'jzs@ciudad.cl', 'hash_jzs', 'admin'),
('Urbanista Senior', 'us@ciudad.cl', 'hash_us', 'planificador'),
('Inspector 1', 'i1@ciudad.cl', 'hash_i1', 'planificador');

-- 2. TABLA: zonas_urbanas (15 registros)
INSERT INTO zonas_urbanas (nombre, tipo_zona, coordenadas, area_km2) VALUES
('Centro Historico', 'Comercial', 'Poligono CH', 2.50),
('Barrio Norte', 'Residencial', 'Poligono BN', 4.80),
('Sector Industrial Oeste', 'Industrial', 'Poligono IO', 7.20),
('Zona Universitaria', 'Mixta', 'Poligono ZU', 3.10),
('Las Flores', 'Residencial', 'Poligono LF', 1.50),
('Distrito Financiero', 'Comercial', 'Poligono DF', 1.10),
('Parque Central', 'Residencial', 'Poligono PC', 3.90),
('Villa Sur', 'Residencial', 'Poligono VS', 6.00),
('Puerto Nuevo', 'Industrial', 'Poligono PN', 5.50),
('Valle Escondido', 'Residencial', 'Poligono VE', 2.00),
('Zona de Expansion', 'Mixta', 'Poligono ZE', 8.00),
('Bosques del Este', 'Residencial', 'Poligono BE', 3.50),
('Sector Logistico', 'Industrial', 'Poligono SL', 4.00),
('Alameda Vieja', 'Comercial', 'Poligono AV', 1.80),
('Puente Alto', 'Residencial', 'Poligono PA', 9.20);

-- 3. TABLA: puntos_interes (20 registros)
INSERT INTO puntos_interes (nombre, tipo, latitud, longitud, id_zona) VALUES
('Hospital Central', 'Hospital', -33.4489, -70.6693, 1),
('Escuela Primaria 1', 'Escuela', -33.4300, -70.6300, 2),
('Parque Metropolitano', 'Parque', -33.4150, -70.6150, 4),
('Clinica del Norte', 'Hospital', -33.4250, -70.6550, 2),
('Jardin Infantil 2', 'Escuela', -33.4350, -70.6600, 5),
('Centro de Salud Familiar', 'Hospital', -33.4600, -70.6700, 8),
('Plaza Las Flores', 'Parque', -33.4400, -70.6800, 5),
('Supermercado Lider', 'Otro', -33.4500, -70.6900, 3),
('Escuela Tecnica', 'Escuela', -33.4550, -70.6050, 7),
('Hospital Sur', 'Hospital', -33.4700, -70.6200, 8),
('Parque Central Urbano', 'Parque', -33.4800, -70.6300, 7),
('Universidad Mayor', 'Otro', -33.4000, -70.6500, 4),
('Escuela Santa Marta', 'Escuela', -33.4450, -70.6750, 1),
('Parque Los Valles', 'Parque', -33.4650, -70.6850, 10),
('Comisaria', 'Otro', -33.4850, -70.6950, 3),
('Escuela de Artes', 'Escuela', -33.4520, -70.6650, 5),
('Hospital del Sur', 'Hospital', -33.5850, -70.5850, 15),
('Parque El Sendero', 'Parque', -33.5700, -70.5600, 15),
('Escuela N300', 'Escuela', -33.5650, -70.5550, 15),
('Hospital Metropolitano', 'Hospital', -33.4400, -70.6800, 14);

-- 4. TABLA: datos_demograficos
INSERT INTO datos_demograficos (id_zona, anio, poblacion, densidad, edad_promedio) VALUES
(1, 2025, 25000, 10000.00, 35.5),
(2, 2025, 45000, 9375.00, 30.2),
(3, 2025, 12000, 1666.67, 40.1),
(4, 2025, 30000, 9677.42, 25.8),
(5, 2025, 18000, 12000.00, 32.5),
(6, 2025, 5000, 4545.45, 45.0),
(7, 2025, 38000, 9743.59, 28.9),
(8, 2025, 65000, 10833.33, 31.1),
(9, 2025, 8000, 1454.55, 42.7),
(10, 2025, 15000, 7500.00, 33.3),
(11, 2025, 10000, 1250.00, 38.0),
(12, 2025, 25000, 7142.86, 29.1),
(13, 2025, 4000, 1000.00, 46.5),
(14, 2025, 22000, 12222.22, 36.8),
(15, 2025, 95000, 10326.09, 30.5),

(2, 2020, 40000, 8333.33, 29.0),
(5, 2020, 16000, 10666.67, 31.0),
(11, 2020, 8500, 1062.50, 37.0),

(1, 2020, 24000, 9600.00, 34.0),
(8, 2020, 60000, 10000.00, 30.0),
(15, 2020, 92000, 10000.00, 30.0);

-- 5. TABLA: proyectos_urbanos
INSERT INTO proyectos_urbanos (nombre, descripcion, fecha_inicio, fecha_fin, estado, id_zona, id_usuario, ubicacion, latitud, longitud) 
VALUES
('Ampliacion Vial Sur', 'Ampliacion de via principal.', '2024-03-01', '2025-12-31', 'En Curso', 8, 2, 'Cerca de Villa Sur', -33.4567, -70.6789),
('Nuevo Hospital Zonal', 'Construccion de hospital de mediana complejidad.', '2023-01-15', '2026-06-30', 'En Curso', 1, 1, 'Centro Sur', -33.4500, -70.6660),
('Parque Lineal Norte', 'Creacion de un parque en zona residencial.', '2025-05-20', '2025-10-20', 'En Curso', 2, 4, 'Borde de Rio', -33.4300, -70.6700),

('Remodelacion Plaza', 'Mejora de la plaza central.', '2023-08-01', '2024-01-30', 'Completado', 5, 3, 'Junto a Plaza', -33.4450, -70.6800),
('Ciclovia Universitaria', 'Implementacion de ciclovias.', '2024-01-01', '2024-12-01', 'Completado', 4, 2, 'Rutas clave', -33.4499, -70.6901),

('Edificio Municipal', 'Nueva sede administrativa.', '2026-03-01', '2027-12-31', 'Planeado', 6, 1, 'Distrito Central', -33.4470, -70.6760),
('Centro Comunitario', 'Construccion de centro para vecinos.', '2026-01-10', '2027-01-10', 'Planeado', 7, 3, 'Sector Poniente', -33.4520, -70.7000),

('Proyecto Olvidado U2', 'Proyecto de infraestructura menor.', '2024-01-01', '2025-01-01', 'En Curso', 9, 2, 'Zona Industrial', -33.4600, -70.7100),
('Mejora Veredas U2', 'Mejora de aceras en 5 cuadras.', '2024-06-01', '2025-05-15', 'En Curso', 10, 2, 'Calles principales', -33.4650, -70.7150),

('Bodega Logistica 1', 'Construccion de nueva bodega.', '2025-02-01', '2026-02-01', 'En Curso', 3, 5, 'Lote 5', -33.4700, -70.7200),
('Proyecto Residencia BE', 'Construccion de 100 viviendas.', '2024-05-01', '2026-05-01', 'En Curso', 12, 4, 'Nuevas calles', -33.4750, -70.7250),
('Antiguo Proyecto Visto', 'Proyecto que termino hace 3 anos.', '2021-01-01', '2021-12-31', 'Completado', 15, 8, 'Antiguo sector', -33.4800, -70.7300),
('Rehabilitacion Alameda', 'Mejora estructural de edificios.', '2025-06-01', '2026-06-01', 'Planeado', 14, 9, 'Frente a Hospital', -33.4850, -70.7350),
('Tunel de Conexion', 'Obra civil mayor de transporte.', '2025-09-01', NULL, 'Planeado', 1, 10, 'Bajo avenida', -33.4900, -70.7400),
('Expansion Urbana Sur', 'Plan de desarrollo habitacional.', '2024-11-01', '2026-11-01', 'En Curso', 8, 4, 'Zona 8 sur', -33.4950, -70.7450);

REFRESH MATERIALIZED VIEW vista_cobertura_infraestructura;
REFRESH MATERIALIZED VIEW vista_resumen_proyectos_estado_zona;

-- ================================================================
-- FIN DE CARGA DE DATOS DE PRUEBA
-- ================================================================
