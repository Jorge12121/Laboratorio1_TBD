package com.example.bda.Repository;

import com.example.bda.Model.zonas_urbanas;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.RowMapper;
import org.springframework.stereotype.Repository;

import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.List;
import java.util.Map;

@Repository
public class ZonaRepository {

    @Autowired
    private JdbcTemplate jdbcTemplate;

    private RowMapper<zonas_urbanas> rowMapper = new RowMapper<zonas_urbanas>() {
        @Override
        public zonas_urbanas mapRow(ResultSet rs, int rowNum) throws SQLException {
            zonas_urbanas zona = new zonas_urbanas();
            zona.setId_zona(rs.getInt("id"));
            zona.setNombre(rs.getString("nombre"));
            zona.setTipo_zona(rs.getString("tipo_zona"));
            zona.setCoordenadas(rs.getString("coordenadas"));
            zona.setArea_km2(rs.getFloat("area_km2"));
            
            // Extraer centro y radio desde geom si existe
            String geomWkt = rs.getString("geom_wkt");
            if (geomWkt != null && !geomWkt.isEmpty()) {
                zona.setGeom(geomWkt);
            }
            
            return zona;
        }
    };

    // CREATE
    public int create(zonas_urbanas zona) {
        // Construir la geometría POLYGON desde el array de coordenadas
        StringBuilder wktPolygon = new StringBuilder("POLYGON((");
        
        if (zona.getPoligono() != null && !zona.getPoligono().isEmpty()) {
            for (int i = 0; i < zona.getPoligono().size(); i++) {
                double[] point = zona.getPoligono().get(i);
                if (i > 0) wktPolygon.append(", ");
                wktPolygon.append(point[1]).append(" ").append(point[0]); // lng lat (PostGIS format)
            }
        }
        wktPolygon.append("))");
        
        String sql = "INSERT INTO zonas_urbanas (nombre, tipo_zona, coordenadas, area_km2, geom) " +
                     "VALUES (?, ?, ?, ?, ST_SetSRID(ST_GeomFromText(?), 4326)) RETURNING id";
        
        return jdbcTemplate.queryForObject(sql, Integer.class, 
            zona.getNombre(), 
            zona.getTipo_zona(), 
            zona.getCoordenadas(), 
            zona.getArea_km2(),
            wktPolygon.toString()
        );
    }

    // READ - Obtener todos
    public List<zonas_urbanas> findAll() {
        String sql = "SELECT id, nombre, tipo_zona, coordenadas, area_km2, " +
                     "ST_AsText(geom) as geom_wkt FROM zonas_urbanas ORDER BY id";
        return jdbcTemplate.query(sql, rowMapper);
    }

    // READ - Obtener con paginación
    public List<zonas_urbanas> findAllPaginated(int page, int size) {
        int offset = page * size;
        String sql = "SELECT id, nombre, tipo_zona, coordenadas, area_km2, " +
                     "ST_AsText(geom) as geom_wkt FROM zonas_urbanas ORDER BY id LIMIT ? OFFSET ?";
        return jdbcTemplate.query(sql, rowMapper, size, offset);
    }

    // READ - Contar total
    public int count() {
        String sql = "SELECT COUNT(*) FROM zonas_urbanas";
        return jdbcTemplate.queryForObject(sql, Integer.class);
    }

    // READ - Obtener por ID
    public zonas_urbanas findById(int id) {
        String sql = "SELECT id, nombre, tipo_zona, coordenadas, area_km2, " +
                     "ST_AsText(geom) as geom_wkt FROM zonas_urbanas WHERE id = ?";
        List<zonas_urbanas> results = jdbcTemplate.query(sql, rowMapper, id);
        return results.isEmpty() ? null : results.get(0);
    }

    // UPDATE
    public int update(int id, zonas_urbanas zona) {
        // Construir la geometría POLYGON desde el array de coordenadas
        StringBuilder wktPolygon = new StringBuilder("POLYGON((");
        
        if (zona.getPoligono() != null && !zona.getPoligono().isEmpty()) {
            for (int i = 0; i < zona.getPoligono().size(); i++) {
                double[] point = zona.getPoligono().get(i);
                if (i > 0) wktPolygon.append(", ");
                wktPolygon.append(point[1]).append(" ").append(point[0]); // lng lat (PostGIS format)
            }
        }
        wktPolygon.append("))");
        
        String sql = "UPDATE zonas_urbanas SET nombre = ?, tipo_zona = ?, coordenadas = ?, area_km2 = ?, " +
                     "geom = ST_SetSRID(ST_GeomFromText(?), 4326) WHERE id = ?";
        
        return jdbcTemplate.update(sql, 
            zona.getNombre(), 
            zona.getTipo_zona(), 
            zona.getCoordenadas(), 
            zona.getArea_km2(), 
            wktPolygon.toString(),
            id
        );
    }

    // DELETE
    public int delete(int id) {
        String sql = "DELETE FROM zonas_urbanas WHERE id = ?";
        return jdbcTemplate.update(sql, id);
    }

    // QUERIES SIMPLES
    // Buscar por tipo de zona
    public List<zonas_urbanas> findByTipo(String tipoZona) {
        String sql = "SELECT * FROM zonas_urbanas WHERE tipo_zona = ? ORDER BY nombre";
        return jdbcTemplate.query(sql, rowMapper, tipoZona);
    }

    // Buscar por nombre (búsqueda parcial)
    public List<zonas_urbanas> findByNombre(String nombre) {
        String sql = "SELECT * FROM zonas_urbanas WHERE nombre ILIKE ? ORDER BY nombre";
        return jdbcTemplate.query(sql, rowMapper, "%" + nombre + "%");
    }

    // Buscar por rango de área
    public List<zonas_urbanas> findByAreaRange(float minArea, float maxArea) {
        String sql = "SELECT * FROM zonas_urbanas WHERE area_km2 BETWEEN ? AND ? ORDER BY area_km2 DESC";
        return jdbcTemplate.query(sql, rowMapper, minArea, maxArea);
    }

    // MÉTODO EXISTENTE
    // 8. ZONA SIN PLANIFICACIÓN
    public List<Map<String, Object>> obtenerZonasSinPlanificacion() {
        String sql = """
            SELECT 
                z.nombre AS nombre_zona,
                COALESCE(TO_CHAR(MAX(p.fecha_inicio), 'YYYY-MM-DD'), 'Ninguno') AS ultima_fecha
            FROM 
                zonas_urbanas z
            LEFT JOIN 
                proyectos_urbanos p ON z.id = p.id_zona
            GROUP BY 
                z.id, z.nombre
            HAVING 
                MAX(p.fecha_inicio) < CURRENT_DATE - INTERVAL '2 years' 
                OR 
                MAX(p.fecha_inicio) IS NULL
        """;
        // Ejecutamos la consulta y Spring mapea automáticamente las columnas a un Map
        return jdbcTemplate.queryForList(sql);
    }
}