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
CREATE TABLE IF NOT EXISTS usuarios (
    id              SERIAL PRIMARY KEY,
    nombre          VARCHAR(100) NOT NULL,
    email           VARCHAR(100) UNIQUE NOT NULL,
    contrasena_hash TEXT NOT NULL,
    rol             VARCHAR(20) DEFAULT 'planificador',
    fecha_creacion  TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ================================================================
-- 2. TABLA: zonas_urbanas (POLYGON 4326)
-- ================================================================
CREATE TABLE IF NOT EXISTS zonas_urbanas (
    id         SERIAL PRIMARY KEY,
    nombre     VARCHAR(100) NOT NULL,
    tipo_zona  VARCHAR(50) NOT NULL CHECK (
                    tipo_zona IN ('Residencial', 'Comercial', 'Industrial', 'Mixta')
               ),
    -- OJO: "coordenadas" en texto no aporta al SIG, se mantiene por compatibilidad
    coordenadas TEXT,

    -- Se mantiene, pero la densidad REAL la calcularemos con ST_Area(geom::geography)
    area_km2   NUMERIC(10,2) CHECK (area_km2 IS NULL OR area_km2 >= 0),

    geom       geometry(POLYGON, 4326)
);

-- Índices (incluye GIST obligatorio en geometría)
CREATE INDEX IF NOT EXISTS idx_zonas_nombre ON zonas_urbanas(nombre);
CREATE INDEX IF NOT EXISTS idx_zonas_geom   ON zonas_urbanas USING GIST (geom);

-- ================================================================
-- 3. TABLA: puntos_interes (POINT 4326)
-- ================================================================
CREATE TABLE IF NOT EXISTS puntos_interes (
    id       SERIAL PRIMARY KEY,
    nombre   VARCHAR(100) NOT NULL,
    tipo     VARCHAR(50) NOT NULL CHECK (
                  tipo IN ('Escuela', 'Hospital', 'Parque', 'Otro')
             ),
    geom     geometry(POINT, 4326),
    id_zona  INT REFERENCES zonas_urbanas(id) ON DELETE CASCADE
);

CREATE INDEX IF NOT EXISTS idx_puntos_tipo ON puntos_interes(tipo);
CREATE INDEX IF NOT EXISTS idx_puntos_zona ON puntos_interes(id_zona);
CREATE INDEX IF NOT EXISTS idx_puntos_geom ON puntos_interes USING GIST (geom); -- GIST obligatorio

-- ================================================================
-- 4. TABLA: datos_demograficos
-- ================================================================
CREATE TABLE IF NOT EXISTS datos_demograficos (
    id            SERIAL PRIMARY KEY,
    id_zona       INT NOT NULL REFERENCES zonas_urbanas(id) ON DELETE CASCADE,
    anio          INT NOT NULL CHECK (anio > 0),
    poblacion     INT CHECK (poblacion IS NULL OR poblacion >= 0),
    densidad      NUMERIC(10,2) CHECK (densidad IS NULL OR densidad >= 0),
    edad_promedio NUMERIC(5,2) CHECK (edad_promedio IS NULL OR edad_promedio >= 0)
);

CREATE INDEX IF NOT EXISTS idx_datos_zona ON datos_demograficos(id_zona);
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint WHERE conname = 'uq_datos_zona_anio'
    ) THEN
        ALTER TABLE datos_demograficos
        ADD CONSTRAINT uq_datos_zona_anio UNIQUE (id_zona, anio);
    END IF;
END $$;

-- ================================================================
-- 5. TABLA: proyectos_urbanos (POLYGON 4326)
-- ================================================================
CREATE TABLE IF NOT EXISTS proyectos_urbanos (
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

CREATE INDEX IF NOT EXISTS idx_proyectos_estado  ON proyectos_urbanos(estado);
CREATE INDEX IF NOT EXISTS idx_proyectos_zona    ON proyectos_urbanos(id_zona);
CREATE INDEX IF NOT EXISTS idx_proyectos_usuario ON proyectos_urbanos(id_usuario);
CREATE INDEX IF NOT EXISTS idx_proyectos_geom    ON proyectos_urbanos USING GIST (geom); -- GIST obligatorio

-- ================================================================
-- 6. FUNCIÓN: validar_fechas_proyecto() [OK]
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
DROP TRIGGER IF EXISTS trg_validar_fechas_proyecto ON proyectos_urbanos;
CREATE TRIGGER trg_validar_fechas_proyecto
BEFORE INSERT OR UPDATE ON proyectos_urbanos
FOR EACH ROW
EXECUTE FUNCTION validar_fechas_proyecto();

-- ================================================================
-- 8. PROCEDIMIENTO: simular_crecimiento_poblacion() [OK]
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
    -- 1. Obtener el área de la zona (usa campo area_km2 si está, si no, cae a cálculo real)
    SELECT
        COALESCE(
            area_km2,
            ROUND((ST_Area(geom::geography) / 1000000.0)::numeric, 2)
        )
    INTO area_zona
    FROM zonas_urbanas
    WHERE id = id_z;

    -- 2. Validar que existe y tiene área
    IF area_zona IS NULL OR area_zona = 0 THEN
        RAISE EXCEPTION 'La zona % no tiene un área válida', id_z;
    END IF;

    -- 3. Actualizar población y recalcular densidad
    UPDATE datos_demograficos
    SET
        poblacion = poblacion + (nuevas_viviendas * 3),
        densidad  = ROUND((poblacion + (nuevas_viviendas * 3))::numeric / area_zona, 2)
    WHERE id_zona = id_z
      AND anio = (SELECT MAX(anio) FROM datos_demograficos WHERE id_zona = id_z);

    IF NOT FOUND THEN
        RAISE EXCEPTION 'No hay datos demográficos para la zona %', id_z;
    END IF;
END;
$$;

-- ================================================================
-- 9. PROCEDIMIENTO: actualizar_proyectos_retrasados() [OK]
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
-- 10. VISTA MATERIALIZADA: vista_cobertura_infraestructura [OK]
-- ================================================================
DROP MATERIALIZED VIEW IF EXISTS vista_cobertura_infraestructura;
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
-- 11. VISTA MATERIALIZADA: vista_resumen_proyectos_estado_zona [OK]
-- ================================================================
DROP MATERIALIZED VIEW IF EXISTS vista_resumen_proyectos_estado_zona;
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
-- 12. TRIGGER TOPOLÓGICO: validar_punto_en_zona  (ST_Contains) [CORREGIDO + TRIGGER]
--      Requisito: evitar insertar POINT fuera del POLYGON válido
-- ================================================================
CREATE OR REPLACE FUNCTION validar_punto_en_zona()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.geom IS NOT NULL AND NEW.id_zona IS NOT NULL THEN
       IF NOT EXISTS (
            SELECT 1
            FROM zonas_urbanas z
            WHERE z.id = NEW.id_zona
              AND z.geom IS NOT NULL
              AND ST_Contains(z.geom, NEW.geom)
       ) THEN
            RAISE EXCEPTION 'El punto de interés debe estar dentro de la zona urbana asignada';
       END IF;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_validar_punto_en_zona ON puntos_interes;
CREATE TRIGGER trg_validar_punto_en_zona
BEFORE INSERT OR UPDATE ON puntos_interes
FOR EACH ROW
EXECUTE FUNCTION validar_punto_en_zona();

-- ================================================================
-- 13. (EXTRA RECOMENDADO) TRIGGER TOPOLÓGICO para proyectos_urbanos dentro de su zona
--     No te lo piden explícito, pero es coherente con el requisito de validación.
-- ================================================================
CREATE OR REPLACE FUNCTION validar_proyecto_en_zona()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.geom IS NOT NULL AND NEW.id_zona IS NOT NULL THEN
       IF NOT EXISTS (
            SELECT 1
            FROM zonas_urbanas z
            WHERE z.id = NEW.id_zona
              AND z.geom IS NOT NULL
              AND ST_Contains(z.geom, NEW.geom)
       ) THEN
            RAISE EXCEPTION 'El polígono del proyecto debe estar dentro de la zona urbana asignada';
       END IF;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_validar_proyecto_en_zona ON proyectos_urbanos;
CREATE TRIGGER trg_validar_proyecto_en_zona
BEFORE INSERT OR UPDATE ON proyectos_urbanos
FOR EACH ROW
EXECUTE FUNCTION validar_proyecto_en_zona();

-- ================================================================
-- 14. CONSULTAS ESPACIALES OBLIGATORIAS (ENUNCIADO 2) COMO VISTAS
--     (para usarlas directo desde backend con SQL nativo)
-- ================================================================

-- 14.1 Cálculo de Densidad Real
-- densidad_real = poblacion / (ST_Area(geom::geography)/1e6)
CREATE OR REPLACE VIEW v_densidad_real AS
SELECT
    z.id AS id_zona,
    z.nombre AS nombre_zona,
    d.anio,
    d.poblacion,
    ROUND((ST_Area(z.geom::geography) / 1000000.0)::numeric, 4) AS area_real_km2,
    CASE
        WHEN z.geom IS NULL OR ST_Area(z.geom::geography) = 0 OR d.poblacion IS NULL THEN NULL
        ELSE ROUND((d.poblacion::numeric) / ((ST_Area(z.geom::geography)/1000000.0)::numeric), 2)
    END AS densidad_real_hab_km2
FROM zonas_urbanas z
JOIN datos_demograficos d ON d.id_zona = z.id;

-- 14.2 Análisis de Proximidad
-- Escuelas a menos de 500m de un proyecto "En Curso" (ST_DWithin)
CREATE OR REPLACE VIEW v_escuelas_cerca_proyectos_en_curso AS
SELECT
    pr.id AS id_proyecto,
    pr.nombre AS nombre_proyecto,
    pi.id AS id_escuela,
    pi.nombre AS nombre_escuela,
    -- Distancia real en metros (geography)
    ROUND(ST_Distance(pi.geom::geography, pr.geom::geography)::numeric, 2) AS distancia_m
FROM proyectos_urbanos pr
JOIN puntos_interes pi
  ON pi.tipo = 'Escuela'
WHERE pr.estado = 'En Curso'
  AND pr.geom IS NOT NULL
  AND pi.geom IS NOT NULL
  AND ST_DWithin(pi.geom::geography, pr.geom::geography, 500);

-- 14.3 Superposición de Proyectos (ST_Intersects + ST_Intersection)
-- pares (a,b) con a<b para no duplicar
CREATE OR REPLACE VIEW v_proyectos_superpuestos AS
SELECT
    p1.id AS proyecto_a,
    p2.id AS proyecto_b,
    p1.nombre AS nombre_a,
    p2.nombre AS nombre_b,
    ROUND(
        ST_Area(
            ST_Intersection(p1.geom, p2.geom)::geography
        )::numeric
    , 2) AS area_conflicto_m2
FROM proyectos_urbanos p1
JOIN proyectos_urbanos p2
  ON p1.id < p2.id
WHERE p1.geom IS NOT NULL
  AND p2.geom IS NOT NULL
  AND ST_Intersects(p1.geom, p2.geom);

-- 14.4 Cobertura de Servicios (CORREGIDA)
-- % del área de la zona cubierta por buffer 1km de hospitales
-- Nota: ST_Union trabaja con geometry, no con geography.

CREATE OR REPLACE VIEW v_cobertura_servicios_hospitales AS
WITH hospitales_buffer AS (
    SELECT
        id_zona,
        -- 1) buffer en metros usando geography
        -- 2) convertimos a geometry (para poder usar ST_Union)
        ST_Union( (ST_Buffer(geom::geography, 1000))::geometry ) AS buffer_geom
    FROM puntos_interes
    WHERE tipo = 'Hospital'
      AND geom IS NOT NULL
      AND id_zona IS NOT NULL
    GROUP BY id_zona
)
SELECT
    z.id AS id_zona,
    z.nombre AS nombre_zona,
    ROUND((ST_Area(z.geom::geography))::numeric, 2) AS area_zona_m2,

    ROUND(
        COALESCE(
            ST_Area(
                ST_Intersection(
                    z.geom::geography,
                    hb.buffer_geom::geography
                )
            )::numeric,
            0
        )
    , 2) AS area_cubierta_m2,

    ROUND(
        CASE
            WHEN z.geom IS NULL OR ST_Area(z.geom::geography) = 0 THEN NULL
            ELSE
                (
                  COALESCE(
                    ST_Area(
                      ST_Intersection(z.geom::geography, hb.buffer_geom::geography)
                    ),
                    0
                  )
                  / ST_Area(z.geom::geography) * 100
                )::numeric
        END
    , 2) AS porcentaje_cobertura
FROM zonas_urbanas z
LEFT JOIN hospitales_buffer hb
  ON hb.id_zona = z.id
WHERE z.geom IS NOT NULL;


-- ================================================================
-- FIN DEL ARCHIVO
-- ================================================================
