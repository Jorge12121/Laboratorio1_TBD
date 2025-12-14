-- ================================================================
-- PROYECTO: Plataforma de Urbanismo y Planificación de Ciudades
-- BASE DE DATOS: PostgreSQL + PostGIS
-- CONTENIDO: Tablas, índices, triggers, procedimientos,
--            vistas materializadas y soporte espacial
-- ================================================================

-- 0. Habilitar PostGIS en esta base (ejecutar una sola vez)
CREATE EXTENSION IF NOT EXISTS postgis;

-- ================================================================
-- 1. TABLA: usuarios
-- ================================================================
CREATE TABLE usuarios (
    id              SERIAL PRIMARY KEY,
    nombre          VARCHAR(100) NOT NULL,
    email           VARCHAR(100) UNIQUE NOT NULL,
    contrasena_hash TEXT NOT NULL,
    rol             VARCHAR(20) DEFAULT 'planificador',
    fecha_creacion  TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ================================================================
-- 2. TABLA: zonas_urbanas
-- ================================================================
CREATE TABLE zonas_urbanas (
    id         SERIAL PRIMARY KEY,
    nombre     VARCHAR(100) NOT NULL,
    tipo_zona  VARCHAR(50) NOT NULL CHECK (
                    tipo_zona IN ('Residencial', 'Comercial', 'Industrial', 'Mixta')
               ),
    coordenadas TEXT,
    area_km2   NUMERIC(10,2) CHECK (area_km2 IS NULL OR area_km2 >= 0),
    geom       geometry(POLYGON, 4326)
);

CREATE INDEX idx_zonas_nombre ON zonas_urbanas(nombre);
CREATE INDEX idx_zonas_geom ON zonas_urbanas USING GIST (geom);

-- ================================================================
-- 3. TABLA: puntos_interes
-- ================================================================
CREATE TABLE puntos_interes (
    id       SERIAL PRIMARY KEY,
    nombre   VARCHAR(100) NOT NULL,
    tipo     VARCHAR(50) NOT NULL CHECK (
                  tipo IN ('Escuela', 'Hospital', 'Parque', 'Otro')
             ),
    geom     geometry(POINT, 4326),
    id_zona  INT REFERENCES zonas_urbanas(id) ON DELETE CASCADE
);

CREATE INDEX idx_puntos_tipo ON puntos_interes(tipo);
CREATE INDEX idx_puntos_zona ON puntos_interes(id_zona);
CREATE INDEX idx_puntos_geom ON puntos_interes USING GIST (geom);

-- ================================================================
-- 4. TABLA: datos_demograficos
-- ================================================================
CREATE TABLE datos_demograficos (
    id            SERIAL PRIMARY KEY,
    id_zona       INT NOT NULL REFERENCES zonas_urbanas(id) ON DELETE CASCADE,
    anio          INT NOT NULL CHECK (anio > 0),
    poblacion     INT CHECK (poblacion IS NULL OR poblacion >= 0),
    densidad      NUMERIC(10,2) CHECK (densidad IS NULL OR densidad >= 0),
    edad_promedio NUMERIC(5,2) CHECK (edad_promedio IS NULL OR edad_promedio >= 0)
);

CREATE INDEX idx_datos_zona ON datos_demograficos(id_zona);
ALTER TABLE datos_demograficos ADD CONSTRAINT uq_datos_zona_anio UNIQUE (id_zona, anio);

-- ================================================================
-- 5. TABLA: proyectos_urbanos
-- ================================================================
CREATE TABLE proyectos_urbanos (
    id           SERIAL PRIMARY KEY,
    nombre       VARCHAR(200) NOT NULL,
    descripcion  TEXT,
    fecha_inicio DATE,
    fecha_fin    DATE,
    estado       VARCHAR(50) CHECK (estado IN ('Planeado', 'En Curso', 'Completado', 'Retrasado')),
    id_zona      INT REFERENCES zonas_urbanas(id) ON DELETE SET NULL,
    id_usuario   INT REFERENCES usuarios(id) ON DELETE SET NULL,
    ubicacion    TEXT,
    geom         geometry(POLYGON, 4326)
);

CREATE INDEX idx_proyectos_estado  ON proyectos_urbanos(estado);
CREATE INDEX idx_proyectos_zona    ON proyectos_urbanos(id_zona);
CREATE INDEX idx_proyectos_usuario ON proyectos_urbanos(id_usuario);
CREATE INDEX idx_proyectos_geom    ON proyectos_urbanos USING GIST (geom);

-- ================================================================
-- 6. FUNCIÓN: validar_fechas_proyecto() [CORREGIDA]
-- ================================================================
CREATE OR REPLACE FUNCTION validar_fechas_proyecto()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.fecha_inicio IS NOT NULL AND NEW.fecha_fin IS NOT NULL THEN
        IF NEW.fecha_fin < NEW.fecha_inicio THEN
            RAISE EXCEPTION 'La fecha de término no puede ser anterior a la fecha de inicio';
        END IF;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- ================================================================
-- 7. TRIGGER: trg_validar_fechas_proyecto
-- ================================================================
CREATE TRIGGER trg_validar_fechas_proyecto
BEFORE INSERT OR UPDATE ON proyectos_urbanos
FOR EACH ROW
EXECUTE FUNCTION validar_fechas_proyecto();

-- ================================================================
-- 8. PROCEDIMIENTO: simular_crecimiento_poblacion() [CORREGIDO]
-- ================================================================
CREATE OR REPLACE PROCEDURE simular_crecimiento_poblacion(
    IN id_z INT,
    IN nuevas_viviendas INT
)
LANGUAGE plpgsql
AS $$
DECLARE
    area_zona NUMERIC(10,2);
BEGIN
    -- 1. Obtener el área de la zona
    SELECT area_km2 INTO area_zona
    FROM zonas_urbanas
    WHERE id = id_z;

    -- 2. Validar que existe y tiene área
    IF area_zona IS NULL OR area_zona = 0 THEN
        RAISE EXCEPTION 'La zona % no tiene un área válida', id_z;
    END IF;

    -- 3. Actualizar población Y recalcular densidad
    UPDATE datos_demograficos
    SET 
        poblacion = poblacion + (nuevas_viviendas * 3),
        densidad = ROUND((poblacion + (nuevas_viviendas * 3))::numeric / area_zona, 2)
    WHERE id_zona = id_z
      AND anio = (SELECT MAX(anio) FROM datos_demograficos WHERE id_zona = id_z);

    -- 4. Verificar que se actualizó algo
    IF NOT FOUND THEN
        RAISE EXCEPTION 'No hay datos demográficos para la zona %', id_z;
    END IF;
END;
$$;

-- ================================================================
-- 9. PROCEDIMIENTO: actualizar_proyectos_retrasados() [CORREGIDO]
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
      AND fecha_fin < CURRENT_DATE
      AND estado != 'Completado';
END;
$$;

-- ================================================================
-- 10. VISTA MATERIALIZADA: vista_cobertura_infraestructura [CORREGIDA]
-- ================================================================
CREATE MATERIALIZED VIEW vista_cobertura_infraestructura AS
SELECT
    z.id     AS id_zona,
    z.nombre AS nombre_zona,
    COUNT(*) FILTER (WHERE p.tipo = 'Hospital') AS hospitales,
    COUNT(*) FILTER (WHERE p.tipo = 'Escuela')  AS escuelas,
    COUNT(*) FILTER (WHERE p.tipo = 'Parque')   AS parques
FROM zonas_urbanas z
LEFT JOIN puntos_interes p ON z.id = p.id_zona
GROUP BY z.id, z.nombre;

CREATE OR REPLACE FUNCTION refrescar_vista_cobertura()
RETURNS VOID AS $$
BEGIN
    REFRESH MATERIALIZED VIEW vista_cobertura_infraestructura;
END;
$$ LANGUAGE plpgsql;

-- ================================================================
-- 11. VISTA MATERIALIZADA: vista_resumen_proyectos_estado_zona [CORREGIDA]
-- ================================================================
CREATE MATERIALIZED VIEW vista_resumen_proyectos_estado_zona AS
SELECT
    COALESCE(z.tipo_zona, 'Sin Zona') AS tipo_zona,
    p.estado,
    COUNT(*) AS total_proyectos
FROM proyectos_urbanos p
LEFT JOIN zonas_urbanas z ON p.id_zona = z.id
GROUP BY z.tipo_zona, p.estado;

CREATE UNIQUE INDEX IF NOT EXISTS uq_mv_resumen_proyectos
ON vista_resumen_proyectos_estado_zona (tipo_zona, estado);

CREATE OR REPLACE FUNCTION refrescar_vista_resumen_proyectos()
RETURNS VOID AS $$
BEGIN
    REFRESH MATERIALIZED VIEW CONCURRENTLY vista_resumen_proyectos_estado_zona;
END;
$$ LANGUAGE plpgsql;

-- ================================================================
-- FIN DEL ARCHIVO
-- ================================================================
