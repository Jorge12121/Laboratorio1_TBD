-- ================================================================
-- PROYECTO: Plataforma de Urbanismo y Planificación de Ciudades
-- BASE DE DATOS: PostgreSQL (sin PostGIS)
-- CONTENIDO: Creación de base, tablas, índices, triggers,
--            procedimientos almacenados y vistas materializadas
-- ================================================================

-- ================================================================
-- 1. TABLA: usuarios
-- Almacena los datos de los planificadores y administradores del sistema
-- ================================================================
CREATE TABLE usuarios (
    id              SERIAL PRIMARY KEY,
    nombre          VARCHAR(100) NOT NULL,
    email           VARCHAR(100) UNIQUE NOT NULL,
    contrasena_hash TEXT NOT NULL,              -- Contraseña en formato hash
    rol             VARCHAR(20) DEFAULT 'planificador', -- 'planificador', 'admin', etc.
    fecha_creacion  TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ================================================================
-- 2. TABLA: zonas_urbanas
-- Contiene los sectores o barrios de la ciudad
-- (Sin PostGIS: se usan coordenadas/geom como texto)
-- ================================================================
CREATE TABLE zonas_urbanas (
    id         SERIAL PRIMARY KEY,
    nombre     VARCHAR(100) NOT NULL,
    tipo_zona  VARCHAR(50) NOT NULL CHECK (
                    tipo_zona IN ('Residencial', 'Comercial', 'Industrial', 'Mixta')
               ),
    coordenadas TEXT,                           -- Coordenadas o descripción del límite de la zona
    area_km2   NUMERIC(10,2) CHECK (area_km2 IS NULL OR area_km2 >= 0)
);

-- Índice para búsquedas por nombre de zona
CREATE INDEX idx_zonas_nombre ON zonas_urbanas(nombre);

-- ================================================================
-- 3. TABLA: puntos_interes
-- Representa lugares relevantes dentro de una zona
-- (escuelas, hospitales, parques, etc.)
-- ================================================================
CREATE TABLE puntos_interes (
    id       SERIAL PRIMARY KEY,
    nombre   VARCHAR(100) NOT NULL,
    tipo     VARCHAR(50) NOT NULL CHECK (
                  tipo IN ('Escuela', 'Hospital', 'Parque', 'Otro')
             ),
    latitud  NUMERIC(9,6),                       -- Coordenadas geográficas (latitud)
    longitud NUMERIC(9,6),                       -- Coordenadas geográficas (longitud)
    id_zona  INT REFERENCES zonas_urbanas(id) ON DELETE CASCADE
);

-- Índice para acelerar filtros por tipo
CREATE INDEX idx_puntos_tipo ON puntos_interes(tipo);

-- Índice para acelerar filtros por zona
CREATE INDEX idx_puntos_zona ON puntos_interes(id_zona);

-- ================================================================
-- 4. TABLA: datos_demograficos
-- Almacena estadísticas demográficas por zona y año
-- ================================================================
CREATE TABLE datos_demograficos (
    id            SERIAL PRIMARY KEY,
    id_zona       INT NOT NULL REFERENCES zonas_urbanas(id) ON DELETE CASCADE,
    anio          INT NOT NULL CHECK (anio > 0),
    poblacion     INT CHECK (poblacion IS NULL OR poblacion >= 0),       -- Número de habitantes
    densidad      NUMERIC(10,2) CHECK (densidad IS NULL OR densidad >= 0),   -- Hab/km²
    edad_promedio NUMERIC(5,2) CHECK (edad_promedio IS NULL OR edad_promedio >= 0)
);

-- Índice por zona (para joins y consultas frecuentes)
CREATE INDEX idx_datos_zona ON datos_demograficos(id_zona);

-- Evitar duplicar registros de un mismo año por zona
ALTER TABLE datos_demograficos
ADD CONSTRAINT uq_datos_zona_anio UNIQUE (id_zona, anio);

-- ================================================================
-- 5. TABLA: proyectos_urbanos
-- Guarda los proyectos de desarrollo o planificación
-- ================================================================
CREATE TABLE proyectos_urbanos (
    id           SERIAL PRIMARY KEY,
    nombre       VARCHAR(150) NOT NULL,
    descripcion  TEXT,
    fecha_inicio DATE NOT NULL,
    fecha_fin    DATE, -- Puede ser NULL si aún no se define
    estado       VARCHAR(20) NOT NULL CHECK (
                     estado IN ('Planeado', 'En Curso', 'Completado', 'Retrasado')
                 ),
    id_zona      INT REFERENCES zonas_urbanas(id) ON DELETE SET NULL,
    id_usuario   INT REFERENCES usuarios(id) ON DELETE SET NULL,
    ubicacion    TEXT,                             -- Descripción o coordenadas textuales del proyecto
    latitud      NUMERIC(9,6),                     -- Coordenadas geográficas (latitud del proyecto)
    longitud     NUMERIC(9,6)                      -- Coordenadas geográficas (longitud del proyecto)
);

-- Índices para optimizar consultas por estado y relaciones
CREATE INDEX idx_proyectos_estado  ON proyectos_urbanos(estado);
CREATE INDEX idx_proyectos_zona    ON proyectos_urbanos(id_zona);
CREATE INDEX idx_proyectos_usuario ON proyectos_urbanos(id_usuario);

-- ================================================================
-- 6. FUNCIÓN: validar_fechas_proyecto()
-- Verifica que la fecha de término no sea anterior a la fecha de inicio
-- ================================================================
CREATE OR REPLACE FUNCTION validar_fechas_proyecto()
RETURNS TRIGGER AS $$
BEGIN
    -- Si ambas fechas NO son nulas, se valida el orden
    IF NEW.fecha_inicio IS NOT NULL
       AND NEW.fecha_fin IS NOT NULL
       AND NEW.fecha_fin < NEW.fecha_inicio THEN
        RAISE EXCEPTION 'La fecha de termino no puede ser anterior a la fecha de inicio.';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- ================================================================
-- 7. TRIGGER: trg_validar_fechas_proyecto
-- Ejecuta la función anterior antes de cada inserción o actualización
-- en la tabla proyectos_urbanos
-- ================================================================
CREATE TRIGGER trg_validar_fechas_proyecto
BEFORE INSERT OR UPDATE ON proyectos_urbanos
FOR EACH ROW
EXECUTE FUNCTION validar_fechas_proyecto();

-- ================================================================
-- 8. PROCEDIMIENTO: simular_crecimiento_poblacion()
-- Incrementa la población de una zona según la cantidad de nuevas viviendas
-- (Se estima 3 personas por vivienda)
-- ================================================================
CREATE OR REPLACE PROCEDURE simular_crecimiento_poblacion(
    IN id_z INT,
    IN nuevas_viviendas INT
)
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE datos_demograficos
    SET poblacion = COALESCE(poblacion, 0) + (nuevas_viviendas * 3)
    WHERE id_zona = id_z;
END;
$$;

-- ================================================================
-- 9. PROCEDIMIENTO: actualizar_proyectos_retrasados()
-- Dado un ID de usuario, actualiza el estado de todos los proyectos
-- creados por ese usuario que han pasado su fecha límite y no están
-- completados, marcándolos como 'Retrasado'.
-- ================================================================
CREATE OR REPLACE PROCEDURE actualizar_proyectos_retrasados(
    IN p_id_usuario INT
)
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE proyectos_urbanos
    SET estado = 'Retrasado'
    WHERE id_usuario = p_id_usuario
      AND fecha_fin IS NOT NULL
      AND fecha_fin < CURRENT_DATE
      AND estado <> 'Completado';
END;
$$;

-- ================================================================
-- Consulta 5. VISTA MATERIALIZADA: vista_cobertura_infraestructura
-- Resume la cantidad de parques, escuelas y hospitales por zona
-- ================================================================
CREATE MATERIALIZED VIEW vista_cobertura_infraestructura AS
SELECT
    z.id     AS id_zona,
    z.nombre AS nombre_zona,
    COUNT(*) FILTER (WHERE p.tipo = 'Parque')   AS parques,
    COUNT(*) FILTER (WHERE p.tipo = 'Escuela')  AS escuelas,
    COUNT(*) FILTER (WHERE p.tipo = 'Hospital') AS hospitales
FROM zonas_urbanas z
LEFT JOIN puntos_interes p ON z.id = p.id_zona
GROUP BY z.id, z.nombre;

-- Función para refrescar la vista de cobertura de infraestructura
CREATE OR REPLACE FUNCTION refrescar_vista_cobertura()
RETURNS VOID AS $$
BEGIN
    REFRESH MATERIALIZED VIEW vista_cobertura_infraestructura;
END;
$$ LANGUAGE plpgsql;

-- ================================================================
-- 11. VISTA MATERIALIZADA:
--     vista_resumen_proyectos_estado_zona
-- Resume la cantidad de proyectos por estado y por tipo de zona urbana
-- ================================================================
CREATE MATERIALIZED VIEW vista_resumen_proyectos_estado_zona AS
SELECT
    z.tipo_zona,
    p.estado,
    COUNT(*) AS total_proyectos
FROM proyectos_urbanos p
LEFT JOIN zonas_urbanas z ON p.id_zona = z.id
GROUP BY z.tipo_zona, p.estado;

-- Función para refrescar la vista de resumen de proyectos
CREATE OR REPLACE FUNCTION refrescar_vista_resumen_proyectos()
RETURNS VOID AS $$
BEGIN
    REFRESH MATERIALIZED VIEW vista_resumen_proyectos_estado_zona;
END;
$$ LANGUAGE plpgsql;

-- ================================================================
-- FIN DEL ARCHIVO
-- ================================================================
