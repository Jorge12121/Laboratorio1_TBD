-- ================================================================
-- CARGA DE DATOS DE PRUEBA (PostgreSQL + PostGIS) - MODIFICADO
-- Compatible con:
-- - zonas_urbanas.geom POLYGON 4326 (NO NULL para triggers ST_Contains)
-- - puntos_interes.geom POINT 4326
-- - proyectos_urbanos.geom POLYGON 4326
-- - triggers topológicos validar_punto_en_zona / validar_proyecto_en_zona
-- - vistas y vistas materializadas
-- ================================================================

-- Recomendado: asegurar PostGIS
CREATE EXTENSION IF NOT EXISTS postgis;

-- ================================================================
-- 0) LIMPIEZA (opcional, por si quieres re-ejecutar)
--    OJO: si no quieres borrar, comenta esta sección.
-- ================================================================
-- TRUNCATE TABLE proyectos_urbanos RESTART IDENTITY CASCADE;
-- TRUNCATE TABLE puntos_interes RESTART IDENTITY CASCADE;
-- TRUNCATE TABLE datos_demograficos RESTART IDENTITY CASCADE;
-- TRUNCATE TABLE zonas_urbanas RESTART IDENTITY CASCADE;
-- TRUNCATE TABLE usuarios RESTART IDENTITY CASCADE;

-- ================================================================
-- 1) USUARIOS
-- ================================================================
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
('Inspector 1', 'i1@ciudad.cl', 'hash_i1', 'planificador'),
('Prueba', 'test@usach.cl', '$2a$12$HZRwLDqKU0NH4Y1TjwjA3.3tnJhiOtojepRFW.WMU0sS3yisMlUDu', 'USER'), -- pass 123456
('Prueba', 'test2@usach.cl', '$2a$12$VPahmO67snF6IdOLopAow.Jrn1YyXUm7vI2yKDaYUk..OKFkDdsF.', 'USER');   -- pass 1234

-- ================================================================
-- 2) ZONAS URBANAS
-- IMPORTANTE: ahora insertamos geom (POLYGON 4326)
-- Usamos polígonos simples (rectángulos) alrededor de coordenadas de Santiago.
-- ================================================================
INSERT INTO zonas_urbanas (nombre, tipo_zona, coordenadas, area_km2, geom) VALUES
('Centro Historico', 'Comercial', 'Poligono CH', 2.50,
 ST_SetSRID(ST_MakePolygon(ST_GeomFromText(
   'LINESTRING(-70.69 -33.46, -70.64 -33.46, -70.64 -33.43, -70.69 -33.43, -70.69 -33.46)'
 )), 4326)
),
('Barrio Norte', 'Residencial', 'Poligono BN', 4.80,
 ST_SetSRID(ST_MakePolygon(ST_GeomFromText(
   'LINESTRING(-70.67 -33.44, -70.61 -33.44, -70.61 -33.41, -70.67 -33.41, -70.67 -33.44)'
 )), 4326)
),
('Sector Industrial Oeste', 'Industrial', 'Poligono IO', 7.20,
 ST_SetSRID(ST_MakePolygon(ST_GeomFromText(
   'LINESTRING(-70.72 -33.49, -70.68 -33.49, -70.68 -33.44, -70.72 -33.44, -70.72 -33.49)'
 )), 4326)
),
('Zona Universitaria', 'Mixta', 'Poligono ZU', 3.10,
 ST_SetSRID(ST_MakePolygon(ST_GeomFromText(
   'LINESTRING(-70.70 -33.46, -70.61 -33.46, -70.61 -33.39, -70.70 -33.39, -70.70 -33.46)'
 )), 4326)
),
('Las Flores', 'Residencial', 'Poligono LF', 1.50,
 ST_SetSRID(ST_MakePolygon(ST_GeomFromText(
   'LINESTRING(-70.69 -33.46, -70.65 -33.46, -70.65 -33.43, -70.69 -33.43, -70.69 -33.46)'
 )), 4326)
),
('Distrito Financiero', 'Comercial', 'Poligono DF', 1.10,
 ST_SetSRID(ST_MakePolygon(ST_GeomFromText(
   'LINESTRING(-70.68 -33.46, -70.64 -33.46, -70.64 -33.44, -70.68 -33.44, -70.68 -33.46)'
 )), 4326)
),
('Parque Central', 'Residencial', 'Poligono PC', 3.90,
 ST_SetSRID(ST_MakePolygon(ST_GeomFromText(
   'LINESTRING(-70.64 -33.49, -70.60 -33.49, -70.60 -33.45, -70.64 -33.45, -70.64 -33.49)'
 )), 4326)
),
('Villa Sur', 'Residencial', 'Poligono VS', 6.00,
 ST_SetSRID(ST_MakePolygon(ST_GeomFromText(
   'LINESTRING(-70.70 -33.49, -70.60 -33.49, -70.60 -33.44, -70.70 -33.44, -70.70 -33.49)'
 )), 4326)
),
('Puerto Nuevo', 'Industrial', 'Poligono PN', 5.50,
 ST_SetSRID(ST_MakePolygon(ST_GeomFromText(
   'LINESTRING(-70.72 -33.50, -70.67 -33.50, -70.67 -33.46, -70.72 -33.46, -70.72 -33.50)'
 )), 4326)
),
('Valle Escondido', 'Residencial', 'Poligono VE', 2.00,
 ST_SetSRID(ST_MakePolygon(ST_GeomFromText(
   'LINESTRING(-70.70 -33.48, -70.66 -33.48, -70.66 -33.45, -70.70 -33.45, -70.70 -33.48)'
 )), 4326)
),
('Zona de Expansion', 'Mixta', 'Poligono ZE', 8.00,
 ST_SetSRID(ST_MakePolygon(ST_GeomFromText(
   'LINESTRING(-70.73 -33.52, -70.62 -33.52, -70.62 -33.45, -70.73 -33.45, -70.73 -33.52)'
 )), 4326)
),
('Bosques del Este', 'Residencial', 'Poligono BE', 3.50,
 ST_SetSRID(ST_MakePolygon(ST_GeomFromText(
   'LINESTRING(-70.74 -33.51, -70.68 -33.51, -70.68 -33.47, -70.74 -33.47, -70.74 -33.51)'
 )), 4326)
),
('Sector Logistico', 'Industrial', 'Poligono SL', 4.00,
 ST_SetSRID(ST_MakePolygon(ST_GeomFromText(
   'LINESTRING(-70.74 -33.52, -70.69 -33.52, -70.69 -33.48, -70.74 -33.48, -70.74 -33.52)'
 )), 4326)
),
('Alameda Vieja', 'Comercial', 'Poligono AV', 1.80,
 ST_SetSRID(ST_MakePolygon(ST_GeomFromText(
   'LINESTRING(-70.70 -33.46, -70.67 -33.46, -70.67 -33.43, -70.70 -33.43, -70.70 -33.46)'
 )), 4326)
),
('Puente Alto', 'Residencial', 'Poligono PA', 9.20,
 ST_SetSRID(ST_MakePolygon(ST_GeomFromText(
   'LINESTRING(-70.60 -33.60, -70.54 -33.60, -70.54 -33.54, -70.60 -33.54, -70.60 -33.60)'
 )), 4326)
);

-- ================================================================
-- 3) PUNTOS DE INTERÉS
-- IMPORTANTE: los puntos quedan dentro del polígono de su id_zona (triggers OK)
-- ================================================================
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

-- ================================================================
-- 4) DATOS DEMOGRÁFICOS
-- (se mantienen como estaban; densidad puede ser "referencial")
-- ================================================================
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

-- ================================================================
-- 5) PROYECTOS URBANOS
-- IMPORTANTE: proyectos deben caer dentro de su zona (trigger OK)
-- Usamos buffer 50m sobre geography y casteo a geometry(POLYGON,4326)
-- ================================================================
INSERT INTO proyectos_urbanos
(nombre, descripcion, fecha_inicio, fecha_fin, estado, id_zona, id_usuario, ubicacion, geom)
VALUES
('Ampliacion Vial Sur',
 'Ampliacion de via principal.',
 '2024-03-01', '2025-12-31', 'En Curso', 8, 2, 'Cerca de Villa Sur',
 ST_Buffer(ST_SetSRID(ST_MakePoint(-70.6789, -33.4567), 4326)::geography, 50)::geometry(POLYGON, 4326)
),
('Nuevo Hospital Zonal',
 'Construccion de hospital de mediana complejidad.',
 '2023-01-15', '2026-06-30', 'En Curso', 1, 1, 'Centro Sur',
 ST_Buffer(ST_SetSRID(ST_MakePoint(-70.6660, -33.4500), 4326)::geography, 50)::geometry(POLYGON, 4326)
),
('Parque Lineal Norte',
 'Creacion de un parque en zona residencial.',
 '2025-05-20', '2025-10-20', 'En Curso', 2, 4, 'Borde de Rio',
 ST_Buffer(ST_SetSRID(ST_MakePoint(-70.6500, -33.4300), 4326)::geography, 50)::geometry(POLYGON, 4326)
),
('Remodelacion Plaza',
 'Mejora de la plaza central.',
 '2023-08-01', '2024-01-30', 'Completado', 5, 3, 'Junto a Plaza',
 ST_Buffer(ST_SetSRID(ST_MakePoint(-70.6800, -33.4450), 4326)::geography, 50)::geometry(POLYGON, 4326)
),
('Ciclovia Universitaria',
 'Implementacion de ciclovias.',
 '2024-01-01', '2024-12-01', 'Completado', 4, 2, 'Rutas clave',
 ST_Buffer(ST_SetSRID(ST_MakePoint(-70.6500, -33.4200), 4326)::geography, 50)::geometry(POLYGON, 4326)
),
('Edificio Municipal',
 'Nueva sede administrativa.',
 '2026-03-01', '2027-12-31', 'Planeado', 6, 1, 'Distrito Central',
 ST_Buffer(ST_SetSRID(ST_MakePoint(-70.6600, -33.4500), 4326)::geography, 50)::geometry(POLYGON, 4326)
),
('Centro Comunitario',
 'Construccion de centro para vecinos.',
 '2026-01-10', '2027-01-10', 'Planeado', 7, 3, 'Sector Poniente',
 ST_Buffer(ST_SetSRID(ST_MakePoint(-70.6200, -33.4700), 4326)::geography, 50)::geometry(POLYGON, 4326)
),
('Proyecto Olvidado U2',
 'Proyecto de infraestructura menor.',
 '2024-01-01', '2025-01-01', 'En Curso', 9, 2, 'Zona Industrial',
 ST_Buffer(ST_SetSRID(ST_MakePoint(-70.7000, -33.4800), 4326)::geography, 50)::geometry(POLYGON, 4326)
),
('Mejora Veredas U2',
 'Mejora de aceras en 5 cuadras.',
 '2024-06-01', '2025-05-15', 'En Curso', 10, 2, 'Calles principales',
 ST_Buffer(ST_SetSRID(ST_MakePoint(-70.6800, -33.4700), 4326)::geography, 50)::geometry(POLYGON, 4326)
),
('Bodega Logistica 1',
 'Construccion de nueva bodega.',
 '2025-02-01', '2026-02-01', 'En Curso', 3, 5, 'Lote 5',
 ST_Buffer(ST_SetSRID(ST_MakePoint(-70.7000, -33.4700), 4326)::geography, 50)::geometry(POLYGON, 4326)
),
('Proyecto Residencia BE',
 'Construccion de 100 viviendas.',
 '2024-05-01', '2026-05-01', 'En Curso', 12, 4, 'Nuevas calles',
 ST_Buffer(ST_SetSRID(ST_MakePoint(-70.7000, -33.4900), 4326)::geography, 50)::geometry(POLYGON, 4326)
),
('Antiguo Proyecto Visto',
 'Proyecto que termino hace 3 anos.',
 '2021-01-01', '2021-12-31', 'Completado', 15, 8, 'Antiguo sector',
 ST_Buffer(ST_SetSRID(ST_MakePoint(-70.5700, -33.5700), 4326)::geography, 50)::geometry(POLYGON, 4326)
),
('Rehabilitacion Alameda',
 'Mejora estructural de edificios.',
 '2025-06-01', '2026-06-01', 'Planeado', 14, 9, 'Frente a Hospital',
 ST_Buffer(ST_SetSRID(ST_MakePoint(-70.6800, -33.4450), 4326)::geography, 50)::geometry(POLYGON, 4326)
),
('Tunel de Conexion',
 'Obra civil mayor de transporte.',
 '2025-09-01', NULL, 'Planeado', 1, 10, 'Bajo avenida',
 ST_Buffer(ST_SetSRID(ST_MakePoint(-70.6700, -33.4450), 4326)::geography, 50)::geometry(POLYGON, 4326)
),
('Expansion Urbana Sur',
 'Plan de desarrollo habitacional.',
 '2024-11-01', '2026-11-01', 'En Curso', 8, 4, 'Zona 8 sur',
 ST_Buffer(ST_SetSRID(ST_MakePoint(-70.6600, -33.4600), 4326)::geography, 50)::geometry(POLYGON, 4326)
),
('Anexo Hospital (Conflicto)',
 'Proyecto prueba para superposicion.',
 '2025-01-01', '2026-01-01', 'Planeado', 1, 1, 'Al lado del hospital',
 ST_Buffer(ST_SetSRID(ST_MakePoint(-70.6662, -33.4502), 4326)::geography, 50)::geometry(POLYGON, 4326)
),
('Instalacion Semaforos',
 'Nuevos semáforos en la ampliación.',
 '2025-01-10', '2025-06-01', 'Planeado', 8, 2, 'Cruce Principal',
 ST_Buffer(ST_SetSRID(ST_MakePoint(-70.6785, -33.4567), 4326)::geography, 50)::geometry(POLYGON, 4326)
),
('Estacion de Bicicletas',
 'Estacionamiento techado para bicis.',
 '2024-02-01', '2024-08-01', 'Completado', 4, 2, 'Entrada Universidad',
 ST_Buffer(ST_SetSRID(ST_MakePoint(-70.6500, -33.4200), 4326)::geography, 50)::geometry(POLYGON, 4326)
),
('Kiosco del Parque',
 'Pequeño comercio dentro del parque.',
 '2025-06-01', '2025-12-01', 'Planeado', 2, 4, 'Centro del Parque',
 ST_Buffer(ST_SetSRID(ST_MakePoint(-70.6505, -33.4305), 4326)::geography, 50)::geometry(POLYGON, 4326)
);

-- ================================================================
-- 6) REFRESH DE VISTAS MATERIALIZADAS
-- ================================================================
REFRESH MATERIALIZED VIEW vista_cobertura_infraestructura;
REFRESH MATERIALIZED VIEW vista_resumen_proyectos_estado_zona;

-- ================================================================
-- FIN CARGA DE DATOS DE PRUEBA (MODIFICADO)
-- ================================================================
