-- ================================================================
-- Carga de Datos de Prueba (versión PostGIS, sin lat/long)
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
-- Nota: por ahora dejamos geom = NULL (se puede poblar después con polígonos reales)
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
-- Convertimos lat/long a geom POINT (lon, lat)
INSERT INTO puntos_interes (nombre, tipo, geom, id_zona) VALUES
('Hospital Central',        'Hospital', ST_SetSRID(ST_MakePoint(-70.6693, -33.4489), 4326), 1),
('Escuela Primaria 1',      'Escuela',  ST_SetSRID(ST_MakePoint(-70.6300, -33.4300), 4326), 2),
('Parque Metropolitano',    'Parque',   ST_SetSRID(ST_MakePoint(-70.6150, -33.4150), 4326), 4),
('Clinica del Norte',       'Hospital', ST_SetSRID(ST_MakePoint(-70.6550, -33.4250), 4326), 2),
('Jardin Infantil 2',       'Escuela',  ST_SetSRID(ST_MakePoint(-70.6600, -33.4350), 4326), 5),
('Centro de Salud Familiar','Hospital', ST_SetSRID(ST_MakePoint(-70.6700, -33.4600), 4326), 8),
('Plaza Las Flores',        'Parque',   ST_SetSRID(ST_MakePoint(-70.6800, -33.4400), 4326), 5),
('Supermercado Lider',      'Otro',     ST_SetSRID(ST_MakePoint(-70.6900, -33.4500), 4326), 3),
('Escuela Tecnica',         'Escuela',  ST_SetSRID(ST_MakePoint(-70.6050, -33.4550), 4326), 7),
('Hospital Sur',            'Hospital', ST_SetSRID(ST_MakePoint(-70.6200, -33.4700), 4326), 8),
('Parque Central Urbano',   'Parque',   ST_SetSRID(ST_MakePoint(-70.6300, -33.4800), 4326), 7),
('Universidad Mayor',       'Otro',     ST_SetSRID(ST_MakePoint(-70.6500, -33.4000), 4326), 4),
('Escuela Santa Marta',     'Escuela',  ST_SetSRID(ST_MakePoint(-70.6750, -33.4450), 4326), 1),
('Parque Los Valles',       'Parque',   ST_SetSRID(ST_MakePoint(-70.6850, -33.4650), 4326), 10),
('Comisaria',               'Otro',     ST_SetSRID(ST_MakePoint(-70.6950, -33.4850), 4326), 3),
('Escuela de Artes',        'Escuela',  ST_SetSRID(ST_MakePoint(-70.6650, -33.4520), 4326), 5),
('Hospital del Sur',        'Hospital', ST_SetSRID(ST_MakePoint(-70.5850, -33.5850), 4326), 15),
('Parque El Sendero',       'Parque',   ST_SetSRID(ST_MakePoint(-70.5600, -33.5700), 4326), 15),
('Escuela N300',            'Escuela',  ST_SetSRID(ST_MakePoint(-70.5550, -33.5650), 4326), 15),
('Hospital Metropolitano',  'Hospital', ST_SetSRID(ST_MakePoint(-70.6800, -33.4400), 4326), 14);

-- 4. TABLA: datos_demograficos
INSERT INTO datos_demograficos (id_zona, anio, poblacion, densidad, edad_promedio) VALUES
(1, 2025, 25000, 10000.00, 35.5),
(2, 2025, 45000,  9375.00, 30.2),
(3, 2025, 12000,  1666.67, 40.1),
(4, 2025, 30000,  9677.42, 25.8),
(5, 2025, 18000, 12000.00, 32.5),
(6, 2025,  5000,  4545.45, 45.0),
(7, 2025, 38000,  9743.59, 28.9),
(8, 2025, 65000, 10833.33, 31.1),
(9, 2025,  8000,  1454.55, 42.7),
(10,2025, 15000,  7500.00, 33.3),
(11,2025, 10000,  1250.00, 38.0),
(12,2025, 25000,  7142.86, 29.1),
(13,2025,  4000,  1000.00, 46.5),
(14,2025, 22000, 12222.22, 36.8),
(15,2025, 95000, 10326.09, 30.5),

(2, 2020, 40000,  8333.33, 29.0),
(5, 2020, 16000, 10666.67, 31.0),
(11,2020,  8500,  1062.50, 37.0),

(1, 2020, 24000,  9600.00, 34.0),
(8, 2020, 60000, 10000.00, 30.0),
(15,2020, 92000, 10000.00, 30.0);

-- 5. TABLA: proyectos_urbanos
-- Como ahora geom es POLYGON, usamos un buffer de 50 m alrededor del punto original
-- para generar un área aproximada del proyecto.
INSERT INTO proyectos_urbanos
(nombre, descripcion, fecha_inicio, fecha_fin, estado, id_zona, id_usuario, ubicacion, geom)
VALUES
('Ampliacion Vial Sur',
 'Ampliacion de via principal.',
 '2024-03-01', '2025-12-31', 'En Curso', 8, 2, 'Cerca de Villa Sur',
 ST_Buffer(
   ST_SetSRID(ST_MakePoint(-70.6789, -33.4567), 4326)::geography,
   50
 )::geometry(POLYGON, 4326)
),
('Nuevo Hospital Zonal',
 'Construccion de hospital de mediana complejidad.',
 '2023-01-15', '2026-06-30', 'En Curso', 1, 1, 'Centro Sur',
 ST_Buffer(
   ST_SetSRID(ST_MakePoint(-70.6660, -33.4500), 4326)::geography,
   50
 )::geometry(POLYGON, 4326)
),
('Parque Lineal Norte',
 'Creacion de un parque en zona residencial.',
 '2025-05-20', '2025-10-20', 'En Curso', 2, 4, 'Borde de Rio',
 ST_Buffer(
   ST_SetSRID(ST_MakePoint(-70.6700, -33.4300), 4326)::geography,
   50
 )::geometry(POLYGON, 4326)
),

('Remodelacion Plaza',
 'Mejora de la plaza central.',
 '2023-08-01', '2024-01-30', 'Completado', 5, 3, 'Junto a Plaza',
 ST_Buffer(
   ST_SetSRID(ST_MakePoint(-70.6800, -33.4450), 4326)::geography,
   50
 )::geometry(POLYGON, 4326)
),
('Ciclovia Universitaria',
 'Implementacion de ciclovias.',
 '2024-01-01', '2024-12-01', 'Completado', 4, 2, 'Rutas clave',
 ST_Buffer(
   ST_SetSRID(ST_MakePoint(-70.6901, -33.4499), 4326)::geography,
   50
 )::geometry(POLYGON, 4326)
),

('Edificio Municipal',
 'Nueva sede administrativa.',
 '2026-03-01', '2027-12-31', 'Planeado', 6, 1, 'Distrito Central',
 ST_Buffer(
   ST_SetSRID(ST_MakePoint(-70.6760, -33.4470), 4326)::geography,
   50
 )::geometry(POLYGON, 4326)
),
('Centro Comunitario',
 'Construccion de centro para vecinos.',
 '2026-01-10', '2027-01-10', 'Planeado', 7, 3, 'Sector Poniente',
 ST_Buffer(
   ST_SetSRID(ST_MakePoint(-70.7000, -33.4520), 4326)::geography,
   50
 )::geometry(POLYGON, 4326)
),

('Proyecto Olvidado U2',
 'Proyecto de infraestructura menor.',
 '2024-01-01', '2025-01-01', 'En Curso', 9, 2, 'Zona Industrial',
 ST_Buffer(
   ST_SetSRID(ST_MakePoint(-70.7100, -33.4600), 4326)::geography,
   50
 )::geometry(POLYGON, 4326)
),
('Mejora Veredas U2',
 'Mejora de aceras en 5 cuadras.',
 '2024-06-01', '2025-05-15', 'En Curso', 10, 2, 'Calles principales',
 ST_Buffer(
   ST_SetSRID(ST_MakePoint(-70.7150, -33.4650), 4326)::geography,
   50
 )::geometry(POLYGON, 4326)
),

('Bodega Logistica 1',
 'Construccion de nueva bodega.',
 '2025-02-01', '2026-02-01', 'En Curso', 3, 5, 'Lote 5',
 ST_Buffer(
   ST_SetSRID(ST_MakePoint(-70.7200, -33.4700), 4326)::geography,
   50
 )::geometry(POLYGON, 4326)
),
('Proyecto Residencia BE',
 'Construccion de 100 viviendas.',
 '2024-05-01', '2026-05-01', 'En Curso', 12, 4, 'Nuevas calles',
 ST_Buffer(
   ST_SetSRID(ST_MakePoint(-70.7250, -33.4750), 4326)::geography,
   50
 )::geometry(POLYGON, 4326)
),
('Antiguo Proyecto Visto',
 'Proyecto que termino hace 3 anos.',
 '2021-01-01', '2021-12-31', 'Completado', 15, 8, 'Antiguo sector',
 ST_Buffer(
   ST_SetSRID(ST_MakePoint(-70.7300, -33.4800), 4326)::geography,
   50
 )::geometry(POLYGON, 4326)
),
('Rehabilitacion Alameda',
 'Mejora estructural de edificios.',
 '2025-06-01', '2026-06-01', 'Planeado', 14, 9, 'Frente a Hospital',
 ST_Buffer(
   ST_SetSRID(ST_MakePoint(-70.7350, -33.4850), 4326)::geography,
   50
 )::geometry(POLYGON, 4326)
),
('Tunel de Conexion',
 'Obra civil mayor de transporte.',
 '2025-09-01', NULL, 'Planeado', 1, 10, 'Bajo avenida',
 ST_Buffer(
   ST_SetSRID(ST_MakePoint(-70.7400, -33.4900), 4326)::geography,
   50
 )::geometry(POLYGON, 4326)
),
('Expansion Urbana Sur',
 'Plan de desarrollo habitacional.',
 '2024-11-01', '2026-11-01', 'En Curso', 8, 4, 'Zona 8 sur',
 ST_Buffer(
   ST_SetSRID(ST_MakePoint(-70.7450, -33.4950), 4326)::geography,
   50
 )::geometry(POLYGON, 4326)
);

REFRESH MATERIALIZED VIEW vista_cobertura_infraestructura;
REFRESH MATERIALIZED VIEW vista_resumen_proyectos_estado_zona;

-- ================================================================
-- FIN DE CARGA DE DATOS DE PRUEBA
-- ================================================================
    