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
-- IMPORTANTE: Ahora usamos círculos (center + radius) en vez de polígonos complejos
-- coordenadas almacena JSON: {"center": [lat, lng], "radius": km}
-- geom se calcula con ST_Buffer para crear el círculo
-- ================================================================
INSERT INTO zonas_urbanas (nombre, tipo_zona, coordenadas, area_km2, geom) VALUES
('Centro Historico', 'Comercial', '{"center": [-33.445, -70.665], "radius": 0.89}', 2.50,
 ST_Buffer(ST_SetSRID(ST_MakePoint(-70.665, -33.445), 4326)::geography, 890)::geometry(POLYGON, 4326)
),
('Barrio Norte', 'Residencial', '{"center": [-33.425, -70.640], "radius": 1.24}', 4.80,
 ST_Buffer(ST_SetSRID(ST_MakePoint(-70.640, -33.425), 4326)::geography, 1240)::geometry(POLYGON, 4326)
),
('Sector Industrial Oeste', 'Industrial', '{"center": [-33.465, -70.700], "radius": 1.51}', 7.20,
 ST_Buffer(ST_SetSRID(ST_MakePoint(-70.700, -33.465), 4326)::geography, 1510)::geometry(POLYGON, 4326)
),
('Zona Universitaria', 'Mixta', '{"center": [-33.425, -70.655], "radius": 0.99}', 3.10,
 ST_Buffer(ST_SetSRID(ST_MakePoint(-70.655, -33.425), 4326)::geography, 990)::geometry(POLYGON, 4326)
),
('Las Flores', 'Residencial', '{"center": [-33.445, -70.670], "radius": 0.69}', 1.50,
 ST_Buffer(ST_SetSRID(ST_MakePoint(-70.670, -33.445), 4326)::geography, 690)::geometry(POLYGON, 4326)
),
('Distrito Financiero', 'Comercial', '{"center": [-33.450, -70.660], "radius": 0.59}', 1.10,
 ST_Buffer(ST_SetSRID(ST_MakePoint(-70.660, -33.450), 4326)::geography, 590)::geometry(POLYGON, 4326)
),
('Parque Central', 'Residencial', '{"center": [-33.470, -70.620], "radius": 1.11}', 3.90,
 ST_Buffer(ST_SetSRID(ST_MakePoint(-70.620, -33.470), 4326)::geography, 1110)::geometry(POLYGON, 4326)
),
('Villa Sur', 'Residencial', '{"center": [-33.465, -70.650], "radius": 1.38}', 6.00,
 ST_Buffer(ST_SetSRID(ST_MakePoint(-70.650, -33.465), 4326)::geography, 1380)::geometry(POLYGON, 4326)
),
('Puerto Nuevo', 'Industrial', '{"center": [-33.480, -70.695], "radius": 1.32}', 5.50,
 ST_Buffer(ST_SetSRID(ST_MakePoint(-70.695, -33.480), 4326)::geography, 1320)::geometry(POLYGON, 4326)
),
('Valle Escondido', 'Residencial', '{"center": [-33.465, -70.680], "radius": 0.80}', 2.00,
 ST_Buffer(ST_SetSRID(ST_MakePoint(-70.680, -33.465), 4326)::geography, 800)::geometry(POLYGON, 4326)
),
('Zona de Expansion', 'Mixta', '{"center": [-33.485, -70.675], "radius": 1.60}', 8.00,
 ST_Buffer(ST_SetSRID(ST_MakePoint(-70.675, -33.485), 4326)::geography, 1600)::geometry(POLYGON, 4326)
),
('Bosques del Este', 'Residencial', '{"center": [-33.490, -70.710], "radius": 1.05}', 3.50,
 ST_Buffer(ST_SetSRID(ST_MakePoint(-70.710, -33.490), 4326)::geography, 1050)::geometry(POLYGON, 4326)
),
('Sector Logistico', 'Industrial', '{"center": [-33.500, -70.715], "radius": 1.13}', 4.00,
 ST_Buffer(ST_SetSRID(ST_MakePoint(-70.715, -33.500), 4326)::geography, 1130)::geometry(POLYGON, 4326)
),
('Alameda Vieja', 'Comercial', '{"center": [-33.445, -70.685], "radius": 0.76}', 1.80,
 ST_Buffer(ST_SetSRID(ST_MakePoint(-70.685, -33.445), 4326)::geography, 760)::geometry(POLYGON, 4326)
),
('Puente Alto', 'Residencial', '{"center": [-33.570, -70.570], "radius": 1.71}', 9.20,
 ST_Buffer(ST_SetSRID(ST_MakePoint(-70.570, -33.570), 4326)::geography, 1710)::geometry(POLYGON, 4326)
),
('Tech Park', 'Comercial', '{"center": [-33.415, -70.605], "radius": 0.85}', 2.27,
 ST_Buffer(ST_SetSRID(ST_MakePoint(-70.605, -33.415), 4326)::geography, 850)::geometry(POLYGON, 4326)
),
('Colina Verde', 'Residencial', '{"center": [-33.395, -70.595], "radius": 1.00}', 3.14,
 ST_Buffer(ST_SetSRID(ST_MakePoint(-70.595, -33.395), 4326)::geography, 1000)::geometry(POLYGON, 4326)
),
('Centro Deportivo', 'Mixta', '{"center": [-33.455, -70.635], "radius": 0.65}', 1.33,
 ST_Buffer(ST_SetSRID(ST_MakePoint(-70.635, -33.455), 4326)::geography, 650)::geometry(POLYGON, 4326)
),
('Barrio Industrial Sur', 'Industrial', '{"center": [-33.510, -70.660], "radius": 1.25}', 4.91,
 ST_Buffer(ST_SetSRID(ST_MakePoint(-70.660, -33.510), 4326)::geography, 1250)::geometry(POLYGON, 4326)
),
('Villa Esperanza', 'Residencial', '{"center": [-33.435, -70.625], "radius": 0.92}', 2.66,
 ST_Buffer(ST_SetSRID(ST_MakePoint(-70.625, -33.435), 4326)::geography, 920)::geometry(POLYGON, 4326)
);

-- ================================================================
-- 3) PUNTOS DE INTERÉS
-- IMPORTANTE: los puntos quedan dentro del círculo de su id_zona
-- Agregamos más puntos para probar todas las funcionalidades
-- ================================================================
INSERT INTO puntos_interes (nombre, tipo, geom, id_zona) VALUES
-- Zona 1: Centro Historico
('Hospital Central',        'Hospital', ST_SetSRID(ST_MakePoint(-70.665, -33.445), 4326), 1),
('Museo Histórico',         'Otro',     ST_SetSRID(ST_MakePoint(-70.666, -33.446), 4326), 1),
('Escuela Santa Marta',     'Escuela',  ST_SetSRID(ST_MakePoint(-70.664, -33.444), 4326), 1),

-- Zona 2: Barrio Norte
('Escuela Primaria 1',      'Escuela',  ST_SetSRID(ST_MakePoint(-70.640, -33.425), 4326), 2),
('Clinica del Norte',       'Hospital', ST_SetSRID(ST_MakePoint(-70.641, -33.426), 4326), 2),
('Parque Los Cedros',       'Parque',   ST_SetSRID(ST_MakePoint(-70.639, -33.424), 4326), 2),
('Centro Comercial Norte',  'Otro',     ST_SetSRID(ST_MakePoint(-70.642, -33.427), 4326), 2),

-- Zona 3: Sector Industrial Oeste
('Supermercado Lider',      'Otro',     ST_SetSRID(ST_MakePoint(-70.700, -33.465), 4326), 3),
('Comisaria Industrial',    'Otro',     ST_SetSRID(ST_MakePoint(-70.701, -33.466), 4326), 3),
('Escuela Técnica',         'Escuela',  ST_SetSRID(ST_MakePoint(-70.699, -33.464), 4326), 3),

-- Zona 4: Zona Universitaria
('Universidad Mayor',       'Otro',     ST_SetSRID(ST_MakePoint(-70.655, -33.425), 4326), 4),
('Parque Metropolitano',    'Parque',   ST_SetSRID(ST_MakePoint(-70.656, -33.426), 4326), 4),
('Biblioteca Central',      'Otro',     ST_SetSRID(ST_MakePoint(-70.654, -33.424), 4326), 4),
('Escuela de Artes',        'Escuela',  ST_SetSRID(ST_MakePoint(-70.657, -33.427), 4326), 4),

-- Zona 5: Las Flores
('Jardin Infantil 2',       'Escuela',  ST_SetSRID(ST_MakePoint(-70.670, -33.445), 4326), 5),
('Plaza Las Flores',        'Parque',   ST_SetSRID(ST_MakePoint(-70.671, -33.446), 4326), 5),
('Centro de Salud',         'Hospital', ST_SetSRID(ST_MakePoint(-70.669, -33.444), 4326), 5),

-- Zona 6: Distrito Financiero
('Torre Empresarial A',     'Otro',     ST_SetSRID(ST_MakePoint(-70.660, -33.450), 4326), 6),
('Banco Central',           'Otro',     ST_SetSRID(ST_MakePoint(-70.661, -33.451), 4326), 6),

-- Zona 7: Parque Central
('Parque Central Urbano',   'Parque',   ST_SetSRID(ST_MakePoint(-70.620, -33.470), 4326), 7),
('Escuela Pública 10',      'Escuela',  ST_SetSRID(ST_MakePoint(-70.621, -33.471), 4326), 7),
('Centro Comunitario',      'Otro',     ST_SetSRID(ST_MakePoint(-70.619, -33.469), 4326), 7),

-- Zona 8: Villa Sur
('Centro de Salud Familiar','Hospital', ST_SetSRID(ST_MakePoint(-70.650, -33.465), 4326), 8),
('Hospital Sur',            'Hospital', ST_SetSRID(ST_MakePoint(-70.651, -33.466), 4326), 8),
('Escuela Villa Sur',       'Escuela',  ST_SetSRID(ST_MakePoint(-70.649, -33.464), 4326), 8),
('Plaza de Juegos',         'Parque',   ST_SetSRID(ST_MakePoint(-70.652, -33.467), 4326), 8),

-- Zona 9: Puerto Nuevo
('Terminal Logístico',      'Otro',     ST_SetSRID(ST_MakePoint(-70.695, -33.480), 4326), 9),
('Bodega Central',          'Otro',     ST_SetSRID(ST_MakePoint(-70.696, -33.481), 4326), 9),

-- Zona 10: Valle Escondido
('Parque Los Valles',       'Parque',   ST_SetSRID(ST_MakePoint(-70.680, -33.465), 4326), 10),
('Escuela Valle',           'Escuela',  ST_SetSRID(ST_MakePoint(-70.681, -33.466), 4326), 10),

-- Zona 11: Zona de Expansion
('Centro Futuro',           'Otro',     ST_SetSRID(ST_MakePoint(-70.675, -33.485), 4326), 11),
('Parque Nuevo',            'Parque',   ST_SetSRID(ST_MakePoint(-70.676, -33.486), 4326), 11),

-- Zona 12: Bosques del Este
('Escuela Bosques',         'Escuela',  ST_SetSRID(ST_MakePoint(-70.710, -33.490), 4326), 12),
('Parque Ecológico',        'Parque',   ST_SetSRID(ST_MakePoint(-70.711, -33.491), 4326), 12),

-- Zona 13: Sector Logistico
('Centro Distribución',     'Otro',     ST_SetSRID(ST_MakePoint(-70.715, -33.500), 4326), 13),

-- Zona 14: Alameda Vieja
('Hospital Metropolitano',  'Hospital', ST_SetSRID(ST_MakePoint(-70.685, -33.445), 4326), 14),
('Mercado Tradicional',     'Otro',     ST_SetSRID(ST_MakePoint(-70.686, -33.446), 4326), 14),

-- Zona 15: Puente Alto
('Hospital del Sur',        'Hospital', ST_SetSRID(ST_MakePoint(-70.570, -33.570), 4326), 15),
('Parque El Sendero',       'Parque',   ST_SetSRID(ST_MakePoint(-70.571, -33.571), 4326), 15),
('Escuela N300',            'Escuela',  ST_SetSRID(ST_MakePoint(-70.569, -33.569), 4326), 15),
('Mall Puente Alto',        'Otro',     ST_SetSRID(ST_MakePoint(-70.572, -33.572), 4326), 15),

-- Zona 16: Tech Park
('Incubadora Tech',         'Otro',     ST_SetSRID(ST_MakePoint(-70.605, -33.415), 4326), 16),
('Centro Innovación',       'Otro',     ST_SetSRID(ST_MakePoint(-70.606, -33.416), 4326), 16),

-- Zona 17: Colina Verde
('Escuela Colina',          'Escuela',  ST_SetSRID(ST_MakePoint(-70.595, -33.395), 4326), 17),
('Parque Colina',           'Parque',   ST_SetSRID(ST_MakePoint(-70.596, -33.396), 4326), 17),

-- Zona 18: Centro Deportivo
('Estadio Municipal',       'Otro',     ST_SetSRID(ST_MakePoint(-70.635, -33.455), 4326), 18),
('Gimnasio Público',        'Otro',     ST_SetSRID(ST_MakePoint(-70.636, -33.456), 4326), 18),

-- Zona 19: Barrio Industrial Sur
('Planta Industrial 1',     'Otro',     ST_SetSRID(ST_MakePoint(-70.660, -33.510), 4326), 19),

-- Zona 20: Villa Esperanza
('Escuela Esperanza',       'Escuela',  ST_SetSRID(ST_MakePoint(-70.625, -33.435), 4326), 20),
('Centro Salud Esperanza',  'Hospital', ST_SetSRID(ST_MakePoint(-70.626, -33.436), 4326), 20),
('Parque Familiar',         'Parque',   ST_SetSRID(ST_MakePoint(-70.624, -33.434), 4326), 20);

-- ================================================================
-- 4) DATOS DEMOGRÁFICOS
-- Agregamos más datos históricos y proyecciones para análisis temporal
-- ================================================================
INSERT INTO datos_demograficos (id_zona, anio, poblacion, densidad, edad_promedio) VALUES
-- Datos 2025 (actual)
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
(16,2025, 18000,  7925.93, 28.3),
(17,2025, 28000,  8917.20, 32.1),
(18,2025, 12000,  9022.56, 27.5),
(19,2025,  6000,  1222.04, 44.2),
(20,2025, 22000,  8270.68, 31.8),

-- Datos 2024
(1, 2024, 24500,  9800.00, 35.2),
(2, 2024, 43000,  8958.33, 29.8),
(5, 2024, 17000, 11333.33, 32.0),
(8, 2024, 62000, 10333.33, 30.8),
(15,2024, 92000, 10000.00, 30.2),
(16,2024, 16000,  7045.70, 27.8),
(17,2024, 26000,  8280.25, 31.5),

-- Datos 2023
(1, 2023, 24000,  9600.00, 34.8),
(2, 2023, 41000,  8541.67, 29.5),
(5, 2023, 16000, 10666.67, 31.5),
(8, 2023, 60000, 10000.00, 30.5),
(11,2023,  9000,  1125.00, 37.5),
(15,2023, 90000,  9782.61, 30.0),

-- Datos 2022
(1, 2022, 23500,  9400.00, 34.5),
(2, 2022, 40000,  8333.33, 29.0),
(8, 2022, 58000,  9666.67, 30.2),
(15,2022, 88000,  9565.22, 29.8),

-- Datos 2021
(1, 2021, 23000,  9200.00, 34.0),
(2, 2021, 39000,  8125.00, 28.8),
(15,2021, 86000,  9347.83, 29.5);

-- ================================================================
-- 5) PROYECTOS URBANOS
-- IMPORTANTE: Proyectos ahora usan WKT POLYGON en 'ubicacion' y geom calculado
-- Los estados son: "Planeado", "En Curso", "Completado", "Retrasado"
-- Agregamos mas proyectos para probar filtros, busquedas y superposiciones
-- ================================================================
INSERT INTO proyectos_urbanos
(nombre, descripcion, fecha_inicio, fecha_fin, estado, id_zona, id_usuario, ubicacion, geom)
VALUES
-- Zona 1: Centro Historico
('Nuevo Hospital Zonal',
 'Construccion de hospital de mediana complejidad.',
 '2023-01-15', '2026-06-30', 'En Curso', 1, 1, 
 'POLYGON((-70.66476 -33.44477, -70.66521 -33.44477, -70.66521 -33.44523, -70.66476 -33.44523, -70.66476 -33.44477))',
 ST_GeomFromText('POLYGON((-70.66476 -33.44477, -70.66521 -33.44477, -70.66521 -33.44523, -70.66476 -33.44523, -70.66476 -33.44477))', 4326)
),
('Tunel de Conexion',
 'Obra civil mayor de transporte subterraneo.',
 '2025-09-01', '2027-09-01', 'Planeado', 1, 10, 
 'POLYGON((-70.66476 -33.44577, -70.66521 -33.44577, -70.66521 -33.44623, -70.66476 -33.44623, -70.66476 -33.44577))',
 ST_GeomFromText('POLYGON((-70.66476 -33.44577, -70.66521 -33.44577, -70.66521 -33.44623, -70.66476 -33.44623, -70.66476 -33.44577))', 4326)
),
('Renovacion Museo',
 'Restauracion del museo historico.',
 '2024-03-01', '2025-03-01', 'En Curso', 1, 3,
 'POLYGON((-70.66576 -33.44477, -70.66621 -33.44477, -70.66621 -33.44523, -70.66576 -33.44523, -70.66576 -33.44477))',
 ST_GeomFromText('POLYGON((-70.66576 -33.44477, -70.66621 -33.44477, -70.66621 -33.44523, -70.66576 -33.44523, -70.66576 -33.44477))', 4326)
),

-- Zona 2: Barrio Norte
('Parque Lineal Norte',
 'Creacion de un parque en zona residencial.',
 '2025-05-20', '2025-10-20', 'Planeado', 2, 4, 
 'POLYGON((-70.63976 -33.42477, -70.64021 -33.42477, -70.64021 -33.42523, -70.63976 -33.42523, -70.63976 -33.42477))',
 ST_GeomFromText('POLYGON((-70.63976 -33.42477, -70.64021 -33.42477, -70.64021 -33.42523, -70.63976 -33.42523, -70.63976 -33.42477))', 4326)
),
('Centro Comunitario Norte',
 'Construccion de centro para vecinos.',
 '2024-06-01', '2025-06-01', 'En Curso', 2, 3, 
 'POLYGON((-70.64076 -33.42577, -70.64121 -33.42577, -70.64121 -33.42623, -70.64076 -33.42623, -70.64076 -33.42577))',
 ST_GeomFromText('POLYGON((-70.64076 -33.42577, -70.64121 -33.42577, -70.64121 -33.42623, -70.64076 -33.42623, -70.64076 -33.42577))', 4326)
),
('Mejoramiento Veredas Norte',
 'Renovacion de aceras principales.',
 '2023-08-01', '2024-02-28', 'Completado', 2, 2,
 'POLYGON((-70.64176 -33.42477, -70.64221 -33.42477, -70.64221 -33.42523, -70.64176 -33.42523, -70.64176 -33.42477))',
 ST_GeomFromText('POLYGON((-70.64176 -33.42477, -70.64221 -33.42477, -70.64221 -33.42523, -70.64176 -33.42523, -70.64176 -33.42477))', 4326)
),

-- Zona 3: Sector Industrial Oeste
('Bodega Logistica 1',
 'Construccion de nueva bodega industrial.',
 '2025-02-01', '2026-02-01', 'En Curso', 3, 5, 
 'POLYGON((-70.69976 -33.46477, -70.70021 -33.46477, -70.70021 -33.46523, -70.69976 -33.46523, -70.69976 -33.46477))',
 ST_GeomFromText('POLYGON((-70.69976 -33.46477, -70.70021 -33.46477, -70.70021 -33.46523, -70.69976 -33.46523, -70.69976 -33.46477))', 4326)
),
('Planta Tratamiento Residuos',
 'Nueva planta de procesamiento.',
 '2024-01-15', '2025-12-31', 'Retrasado', 3, 5,
 'POLYGON((-70.70076 -33.46577, -70.70121 -33.46577, -70.70121 -33.46623, -70.70076 -33.46623, -70.70076 -33.46577))',
 ST_GeomFromText('POLYGON((-70.70076 -33.46577, -70.70121 -33.46577, -70.70121 -33.46623, -70.70076 -33.46623, -70.70076 -33.46577))', 4326)
),

-- Zona 4: Zona Universitaria
('Ciclovia Universitaria',
 'Implementacion de ciclovias para estudiantes.',
 '2024-01-01', '2024-12-01', 'Completado', 4, 2, 
 'POLYGON((-70.65476 -33.42477, -70.65521 -33.42477, -70.65521 -33.42523, -70.65476 -33.42523, -70.65476 -33.42477))',
 ST_GeomFromText('POLYGON((-70.65476 -33.42477, -70.65521 -33.42477, -70.65521 -33.42523, -70.65476 -33.42523, -70.65476 -33.42477))', 4326)
),
('Estacion de Bicicletas',
 'Estacionamiento techado para bicis.',
 '2024-02-01', '2024-08-01', 'Completado', 4, 2, 
 'POLYGON((-70.65576 -33.42577, -70.65621 -33.42577, -70.65621 -33.42623, -70.65576 -33.42623, -70.65576 -33.42577))',
 ST_GeomFromText('POLYGON((-70.65576 -33.42577, -70.65621 -33.42577, -70.65621 -33.42623, -70.65576 -33.42623, -70.65576 -33.42577))', 4326)
),
('Nueva Biblioteca Campus',
 'Construccion biblioteca universitaria.',
 '2025-03-01', '2026-12-31', 'Planeado', 4, 4,
 'POLYGON((-70.65676 -33.42477, -70.65721 -33.42477, -70.65721 -33.42523, -70.65676 -33.42523, -70.65676 -33.42477))',
 ST_GeomFromText('POLYGON((-70.65676 -33.42477, -70.65721 -33.42477, -70.65721 -33.42523, -70.65676 -33.42523, -70.65676 -33.42477))', 4326)
),

-- Zona 5: Las Flores
('Remodelacion Plaza',
 'Mejora de la plaza central del barrio.',
 '2023-08-01', '2024-01-30', 'Completado', 5, 3, 
 'POLYGON((-70.66976 -33.44477, -70.67021 -33.44477, -70.67021 -33.44523, -70.66976 -33.44523, -70.66976 -33.44477))',
 ST_GeomFromText('POLYGON((-70.66976 -33.44477, -70.67021 -33.44477, -70.67021 -33.44523, -70.66976 -33.44523, -70.66976 -33.44477))', 4326)
),
('Ampliacion Escuela',
 'Nuevas aulas para jardin infantil.',
 '2025-01-15', '2025-12-31', 'En Curso', 5, 3,
 'POLYGON((-70.67076 -33.44577, -70.67121 -33.44577, -70.67121 -33.44623, -70.67076 -33.44623, -70.67076 -33.44577))',
 ST_GeomFromText('POLYGON((-70.67076 -33.44577, -70.67121 -33.44577, -70.67121 -33.44623, -70.67076 -33.44623, -70.67076 -33.44577))', 4326)
),

-- Zona 6: Distrito Financiero
('Edificio Municipal',
 'Nueva sede administrativa municipal.',
 '2026-03-01', '2027-12-31', 'Planeado', 6, 1, 
 'POLYGON((-70.65976 -33.44977, -70.66021 -33.44977, -70.66021 -33.45023, -70.65976 -33.45023, -70.65976 -33.44977))',
 ST_GeomFromText('POLYGON((-70.65976 -33.44977, -70.66021 -33.44977, -70.66021 -33.45023, -70.65976 -33.45023, -70.65976 -33.44977))', 4326)
),
('Torre Empresarial B',
 'Edificio de oficinas corporativas.',
 '2024-05-01', '2026-05-01', 'En Curso', 6, 1,
 'POLYGON((-70.66076 -33.45077, -70.66121 -33.45077, -70.66121 -33.45123, -70.66076 -33.45123, -70.66076 -33.45077))',
 ST_GeomFromText('POLYGON((-70.66076 -33.45077, -70.66121 -33.45077, -70.66121 -33.45123, -70.66076 -33.45123, -70.66076 -33.45077))', 4326)
),

-- Zona 7: Parque Central
('Kiosco del Parque',
 'Pequeno comercio dentro del parque.',
 '2025-06-01', '2025-12-01', 'Planeado', 7, 4, 
 'POLYGON((-70.61976 -33.46977, -70.62021 -33.46977, -70.62021 -33.47023, -70.61976 -33.47023, -70.61976 -33.46977))',
 ST_GeomFromText('POLYGON((-70.61976 -33.46977, -70.62021 -33.46977, -70.62021 -33.47023, -70.61976 -33.47023, -70.61976 -33.46977))', 4326)
),
('Sendero Ecologico',
 'Camino peatonal con senalizacion.',
 '2024-09-01', '2025-03-31', 'En Curso', 7, 4,
 'POLYGON((-70.62076 -33.47077, -70.62121 -33.47077, -70.62121 -33.47123, -70.62076 -33.47123, -70.62076 -33.47077))',
 ST_GeomFromText('POLYGON((-70.62076 -33.47077, -70.62121 -33.47077, -70.62121 -33.47123, -70.62076 -33.47123, -70.62076 -33.47077))', 4326)
),

-- Zona 8: Villa Sur
('Ampliacion Vial Sur',
 'Ampliacion de via principal.',
 '2024-03-01', '2025-12-31', 'En Curso', 8, 2, 
 'POLYGON((-70.64976 -33.46477, -70.65021 -33.46477, -70.65021 -33.46523, -70.64976 -33.46523, -70.64976 -33.46477))',
 ST_GeomFromText('POLYGON((-70.64976 -33.46477, -70.65021 -33.46477, -70.65021 -33.46523, -70.64976 -33.46523, -70.64976 -33.46477))', 4326)
),
('Instalacion Semaforos',
 'Nuevos semaforos en la ampliacion.',
 '2025-01-10', '2025-06-01', 'Planeado', 8, 2, 
 'POLYGON((-70.65076 -33.46577, -70.65121 -33.46577, -70.65121 -33.46623, -70.65076 -33.46623, -70.65076 -33.46577))',
 ST_GeomFromText('POLYGON((-70.65076 -33.46577, -70.65121 -33.46577, -70.65121 -33.46623, -70.65076 -33.46623, -70.65076 -33.46577))', 4326)
),
('Expansion Urbana Sur',
 'Plan de desarrollo habitacional.',
 '2024-11-01', '2026-11-01', 'En Curso', 8, 4, 
 'POLYGON((-70.65176 -33.46477, -70.65221 -33.46477, -70.65221 -33.46523, -70.65176 -33.46523, -70.65176 -33.46477))',
 ST_GeomFromText('POLYGON((-70.65176 -33.46477, -70.65221 -33.46477, -70.65221 -33.46523, -70.65176 -33.46523, -70.65176 -33.46477))', 4326)
),

-- Zona 10: Valle Escondido
('Mejora Veredas Valle',
 'Mejora de aceras en 5 cuadras.',
 '2024-06-01', '2025-05-15', 'Retrasado', 10, 2, 
 'POLYGON((-70.67976 -33.46477, -70.68021 -33.46477, -70.68021 -33.46523, -70.67976 -33.46523, -70.67976 -33.46477))',
 ST_GeomFromText('POLYGON((-70.67976 -33.46477, -70.68021 -33.46477, -70.68021 -33.46523, -70.67976 -33.46523, -70.67976 -33.46477))', 4326)
),

-- Zona 12: Bosques del Este
('Proyecto Residencia BE',
 'Construccion de 100 viviendas sociales.',
 '2024-05-01', '2026-05-01', 'En Curso', 12, 4, 
 'POLYGON((-70.70976 -33.48977, -70.71021 -33.48977, -70.71021 -33.49023, -70.70976 -33.49023, -70.70976 -33.48977))',
 ST_GeomFromText('POLYGON((-70.70976 -33.48977, -70.71021 -33.48977, -70.71021 -33.49023, -70.70976 -33.49023, -70.70976 -33.48977))', 4326)
),

-- Zona 14: Alameda Vieja
('Rehabilitacion Alameda',
 'Mejora estructural de edificios patrimoniales.',
 '2025-06-01', '2026-06-01', 'Planeado', 14, 9, 
 'POLYGON((-70.68476 -33.44477, -70.68521 -33.44477, -70.68521 -33.44523, -70.68476 -33.44523, -70.68476 -33.44477))',
 ST_GeomFromText('POLYGON((-70.68476 -33.44477, -70.68521 -33.44477, -70.68521 -33.44523, -70.68476 -33.44523, -70.68476 -33.44477))', 4326)
),

-- Zona 15: Puente Alto
('Antiguo Proyecto Visto',
 'Proyecto que termino hace 4 anos.',
 '2021-01-01', '2021-12-31', 'Completado', 15, 8, 
 'POLYGON((-70.56976 -33.56977, -70.57021 -33.56977, -70.57021 -33.57023, -70.56976 -33.57023, -70.56976 -33.56977))',
 ST_GeomFromText('POLYGON((-70.56976 -33.56977, -70.57021 -33.56977, -70.57021 -33.57023, -70.56976 -33.57023, -70.56976 -33.56977))', 4326)
),
('Mall Extension',
 'Ampliacion del centro comercial.',
 '2025-02-01', '2026-08-31', 'Planeado', 15, 8,
 'POLYGON((-70.57076 -33.57077, -70.57121 -33.57077, -70.57121 -33.57123, -70.57076 -33.57123, -70.57076 -33.57077))',
 ST_GeomFromText('POLYGON((-70.57076 -33.57077, -70.57121 -33.57077, -70.57121 -33.57123, -70.57076 -33.57123, -70.57076 -33.57077))', 4326)
),

-- Zona 16: Tech Park
('Centro Datos Tech',
 'Data center para empresas tecnologicas.',
 '2025-04-01', '2026-12-31', 'Planeado', 16, 1,
 'POLYGON((-70.60476 -33.41477, -70.60521 -33.41477, -70.60521 -33.41523, -70.60476 -33.41523, -70.60476 -33.41477))',
 ST_GeomFromText('POLYGON((-70.60476 -33.41477, -70.60521 -33.41477, -70.60521 -33.41523, -70.60476 -33.41523, -70.60476 -33.41477))', 4326)
),

-- Zona 17: Colina Verde
('Parque Ecologico Colina',
 'Area verde con flora nativa.',
 '2024-08-01', '2025-06-30', 'En Curso', 17, 4,
 'POLYGON((-70.59476 -33.39477, -70.59521 -33.39477, -70.59521 -33.39523, -70.59476 -33.39523, -70.59476 -33.39477))',
 ST_GeomFromText('POLYGON((-70.59476 -33.39477, -70.59521 -33.39477, -70.59521 -33.39523, -70.59476 -33.39523, -70.59476 -33.39477))', 4326)
),

-- Zona 18: Centro Deportivo
('Renovacion Estadio',
 'Mejoras en infraestructura deportiva.',
 '2025-07-01', '2026-06-30', 'Planeado', 18, 9,
 'POLYGON((-70.63476 -33.45477, -70.63521 -33.45477, -70.63521 -33.45523, -70.63476 -33.45523, -70.63476 -33.45477))',
 ST_GeomFromText('POLYGON((-70.63476 -33.45477, -70.63521 -33.45477, -70.63521 -33.45523, -70.63476 -33.45523, -70.63476 -33.45477))', 4326)
),

-- Zona 20: Villa Esperanza
('Centro Salud Ampliado',
 'Ampliacion del centro de salud.',
 '2024-04-01', '2025-10-31', 'En Curso', 20, 3,
 'POLYGON((-70.62476 -33.43477, -70.62521 -33.43477, -70.62521 -33.43523, -70.62476 -33.43523, -70.62476 -33.43477))',
 ST_GeomFromText('POLYGON((-70.62476 -33.43477, -70.62521 -33.43477, -70.62521 -33.43523, -70.62476 -33.43523, -70.62476 -33.43477))', 4326)
),

-- Proyectos SUPERPUESTOS para probar deteccion de conflictos
('Anexo Hospital Conflicto',
 'Proyecto que se superpone con Nuevo Hospital Zonal.',
 '2025-01-01', '2026-01-01', 'Planeado', 1, 1, 
 'POLYGON((-70.66480 -33.44480, -70.66520 -33.44480, -70.66520 -33.44520, -70.66480 -33.44520, -70.66480 -33.44480))',
 ST_GeomFromText('POLYGON((-70.66480 -33.44480, -70.66520 -33.44480, -70.66520 -33.44520, -70.66480 -33.44520, -70.66480 -33.44480))', 4326)
),
('Estacionamiento Conflicto',
 'Se superpone con Ampliacion Vial Sur.',
 '2025-03-01', '2025-09-30', 'Planeado', 8, 2,
 'POLYGON((-70.64980 -33.46480, -70.65020 -33.46480, -70.65020 -33.46520, -70.64980 -33.46520, -70.64980 -33.46480))',
 ST_GeomFromText('POLYGON((-70.64980 -33.46480, -70.65020 -33.46480, -70.65020 -33.46520, -70.64980 -33.46520, -70.64980 -33.46480))', 4326)
),

-- Proyecto FUERA DE ZONA (id_zona = NULL) para probar deteccion
('Proyecto Sin Zona',
 'Proyecto ubicado fuera de todas las zonas definidas.',
 '2025-05-01', '2026-05-01', 'Planeado', NULL, 1,
 'POLYGON((-70.80000 -33.60000, -70.80050 -33.60000, -70.80050 -33.60050, -70.80000 -33.60050, -70.80000 -33.60000))',
 ST_GeomFromText('POLYGON((-70.80000 -33.60000, -70.80050 -33.60000, -70.80050 -33.60050, -70.80000 -33.60050, -70.80000 -33.60000))', 4326)
);

-- ================================================================
-- 6) REFRESH DE VISTAS MATERIALIZADAS
-- ================================================================
REFRESH MATERIALIZED VIEW vista_cobertura_infraestructura;
REFRESH MATERIALIZED VIEW vista_resumen_proyectos_estado_zona;

-- ================================================================
-- FIN CARGA DE DATOS DE PRUEBA (MODIFICADO)
-- ================================================================
