-- ================================================================
-- PROYECTO: Plataforma de Urbanismo y Planificación de Ciudades
-- BASE DE DATOS: PostgreSQL (sin PostGIS)
-- CONTENIDO: Creación de tablas, índices, triggers, funciones y vistas
-- ================================================================
CREATE DATABASE Urbanismo_ciudades;
-- ================================================================
-- 1. TABLA: usuarios
-- Almacena los datos de los planificadores y administradores del sistema
-- ================================================================
CREATE TABLE usuarios (
    id SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    contrasena_hash TEXT NOT NULL,              -- Contraseña en formato hash (por seguridad)
    rol VARCHAR(20) DEFAULT 'planificador',     -- Tipo de usuario
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ================================================================
-- 2. TABLA: zonas_urbanas
-- Contiene los sectores o barrios de la ciudad
-- (sin PostGIS: se usan coordenadas en texto)
-- ================================================================
CREATE TABLE zonas_urbanas (
    id SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    tipo_zona VARCHAR(50) CHECK (tipo_zona IN ('Residencial', 'Comercial', 'Industrial', 'Mixta')),
    coordenadas TEXT,                           -- Coordenadas o descripción del límite de la zona
    area_km2 NUMERIC(10,2)                      -- Área aproximada en km²
);

-- ================================================================
-- 3. TABLA: puntos_interes
-- Representa lugares relevantes dentro de una zona
-- (escuelas, hospitales, parques, etc.)
-- ================================================================
CREATE TABLE puntos_interes (
    id SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    tipo VARCHAR(50) CHECK (tipo IN ('Escuela', 'Hospital', 'Parque', 'Otro')),
    latitud NUMERIC(9,6),                       -- Coordenadas geográficas (latitud)
    longitud NUMERIC(9,6),                      -- Coordenadas geográficas (longitud)
    id_zona INT REFERENCES zonas_urbanas(id) ON DELETE CASCADE
);

-- ================================================================
-- 4. TABLA: datos_demograficos
-- Almacena estadísticas demográficas por zona y año
-- ================================================================
CREATE TABLE datos_demograficos (
    id SERIAL PRIMARY KEY,
    id_zona INT REFERENCES zonas_urbanas(id) ON DELETE CASCADE,
    anio INT NOT NULL,
    poblacion INT CHECK (poblacion >= 0),       -- Número de habitantes
    densidad NUMERIC(10,2),                     -- Habitantes por km²
    edad_promedio NUMERIC(5,2)                  -- Edad promedio de los habitantes
);

-- ================================================================
-- 5. TABLA: proyectos_urbanos
-- Guarda los proyectos de desarrollo o planificación en curso o finalizados
-- ================================================================
CREATE TABLE proyectos_urbanos (
    id SERIAL PRIMARY KEY,
    nombre VARCHAR(150) NOT NULL,
    descripcion TEXT,
    fecha_inicio DATE,
    fecha_fin DATE,
    estado VARCHAR(20) CHECK (estado IN ('Planeado', 'En Curso', 'Completado', 'Retrasado')),
    id_zona INT REFERENCES zonas_urbanas(id) ON DELETE SET NULL,
    id_usuario INT REFERENCES usuarios(id) ON DELETE SET NULL,
    ubicacion TEXT                              -- Descripción o coordenadas textuales del proyecto
);

-- ================================================================
-- 6. ÍNDICES
-- Mejoran la velocidad de búsqueda y filtrado en las tablas más consultadas
-- ================================================================
CREATE INDEX idx_zonas_nombre ON zonas_urbanas(nombre);
CREATE INDEX idx_puntos_tipo ON puntos_interes(tipo);
CREATE INDEX idx_proyectos_estado ON proyectos_urbanos(estado);
CREATE INDEX idx_datos_zona ON datos_demograficos(id_zona);

-- ================================================================
-- 7. FUNCIÓN: validar_fechas_proyecto()
-- Verifica automáticamente que la fecha de término no sea anterior
-- a la fecha de inicio al insertar o modificar un proyecto
-- ================================================================
CREATE OR REPLACE FUNCTION validar_fechas_proyecto()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.fecha_fin < NEW.fecha_inicio THEN
        RAISE EXCEPTION 'La fecha de término no puede ser anterior a la fecha de inicio.';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- ================================================================
-- 8. TRIGGER: trg_validar_fechas_proyecto
-- Ejecuta la función anterior antes de cada inserción o actualización
-- en la tabla proyectos_urbanos
-- ================================================================
CREATE TRIGGER trg_validar_fechas_proyecto
BEFORE INSERT OR UPDATE ON proyectos_urbanos
FOR EACH ROW
EXECUTE FUNCTION validar_fechas_proyecto();

-- ================================================================
-- 9. PROCEDIMIENTO: simular_crecimiento_poblacion()
-- Incrementa la población de una zona según la cantidad de nuevas viviendas
-- (Se estima 3 personas por vivienda)
-- ================================================================
CREATE OR REPLACE PROCEDURE simular_crecimiento_poblacion(id_z INT, nuevas_viviendas INT)
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE datos_demograficos
    SET poblacion = poblacion + (nuevas_viviendas * 3)
    WHERE id_zona = id_z;
END;
$$;

-- ================================================================
-- 10. VISTA MATERIALIZADA: vista_cobertura_infraestructura
-- Resume la cantidad de parques, escuelas y hospitales por zona
-- ================================================================
CREATE MATERIALIZED VIEW vista_cobertura_infraestructura AS
SELECT
    z.id AS id_zona,
    z.nombre AS nombre_zona,
    COUNT(*) FILTER (WHERE p.tipo = 'Parque') AS parques,
    COUNT(*) FILTER (WHERE p.tipo = 'Escuela') AS escuelas,
    COUNT(*) FILTER (WHERE p.tipo = 'Hospital') AS hospitales
FROM zonas_urbanas z
LEFT JOIN puntos_interes p ON z.id = p.id_zona
GROUP BY z.id, z.nombre;

-- ================================================================
-- 11. FUNCIÓN: refrescar_vista_cobertura()
-- Permite actualizar los datos precalculados de la vista materializada
-- ================================================================
CREATE OR REPLACE FUNCTION refrescar_vista_cobertura()
RETURNS VOID AS $$
BEGIN
    REFRESH MATERIALIZED VIEW vista_cobertura_infraestructura;
END;
$$ LANGUAGE plpgsql;

-- ================================================================
-- FIN DEL ARCHIVO
-- ================================================================
