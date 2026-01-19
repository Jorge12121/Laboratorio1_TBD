package com.example.bda.Repository;

import com.example.bda.Model.proyectos_urbanos;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.RowMapper;
import org.springframework.stereotype.Repository;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.List;
import java.util.Map;

@Repository
public class ProyectoRepository {

    @Autowired
    private JdbcTemplate jdbcTemplate;

    private RowMapper<proyectos_urbanos> rowMapper = new RowMapper<proyectos_urbanos>() {
        @Override
        public proyectos_urbanos mapRow(ResultSet rs, int rowNum) throws SQLException {
            proyectos_urbanos proyecto = new proyectos_urbanos();
            proyecto.setId_proyectos(rs.getInt("id"));
            proyecto.setNombre(rs.getString("nombre"));
            proyecto.setDescripcion(rs.getString("descripcion"));
            proyecto.setFecha_inicio(rs.getDate("fecha_inicio") != null ? rs.getDate("fecha_inicio").toLocalDate() : null);
            proyecto.setFecha_fin(rs.getDate("fecha_fin") != null ? rs.getDate("fecha_fin").toLocalDate() : null);
            proyecto.setEstado(rs.getString("estado"));
            
            // Manejar id_zona nullable
            int idZona = rs.getInt("id_zona");
            proyecto.setId_zona(rs.wasNull() ? null : idZona);
            
            // Manejar id_usuario nullable
            int idUsuario = rs.getInt("id_usuario");
            proyecto.setId_usuario(rs.wasNull() ? null : idUsuario);
            
            proyecto.setUbicacion(rs.getString("ubicacion"));
            
            // La tabla usa 'geom' (geometry), no latitud/longitud individuales
            // Si necesitas extraer coordenadas, usa ST_AsText(geom) en la query
            String geom = rs.getString("geom");
            if (geom != null && !geom.isEmpty()) {
                // Puedes procesar la geometría aquí si es necesario
                // Por ahora, simplemente la guardamos como ubicación si está vacía
                if (proyecto.getUbicacion() == null || proyecto.getUbicacion().isEmpty()) {
                    proyecto.setUbicacion(geom);
                }
            }
            
            return proyecto;
        }
    };

    // CREATE
    public int create(proyectos_urbanos proyecto) {
        String sql;
        
        // Si ubicacion contiene WKT (empieza con POINT, POLYGON, etc.)
        if (proyecto.getUbicacion() != null && 
            (proyecto.getUbicacion().startsWith("POINT") || 
             proyecto.getUbicacion().startsWith("POLYGON") || 
             proyecto.getUbicacion().startsWith("LINESTRING"))) {
            
            sql = "INSERT INTO proyectos_urbanos (nombre, descripcion, fecha_inicio, fecha_fin, estado, id_zona, id_usuario, ubicacion, geom) " +
                  "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ST_GeomFromText(?, 4326)) RETURNING id";
            return jdbcTemplate.queryForObject(sql, Integer.class, 
                proyecto.getNombre(), proyecto.getDescripcion(), proyecto.getFecha_inicio(), 
                proyecto.getFecha_fin(), proyecto.getEstado(), proyecto.getId_zona(),
                proyecto.getId_usuario(), proyecto.getUbicacion(), proyecto.getUbicacion());
        }
        else if (proyecto.getLatitud() != null && proyecto.getLongitud() != null) {
            sql = "INSERT INTO proyectos_urbanos (nombre, descripcion, fecha_inicio, fecha_fin, estado, id_zona, id_usuario, ubicacion, geom) " +
                  "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ST_SetSRID(ST_MakePoint(?, ?), 4326)) RETURNING id";
            return jdbcTemplate.queryForObject(sql, Integer.class, 
                proyecto.getNombre(), proyecto.getDescripcion(), proyecto.getFecha_inicio(), 
                proyecto.getFecha_fin(), proyecto.getEstado(), proyecto.getId_zona(),
                proyecto.getId_usuario(), proyecto.getUbicacion(),
                proyecto.getLongitud(), proyecto.getLatitud());
        } else {
            sql = "INSERT INTO proyectos_urbanos (nombre, descripcion, fecha_inicio, fecha_fin, estado, id_zona, id_usuario, ubicacion) " +
                  "VALUES (?, ?, ?, ?, ?, ?, ?, ?) RETURNING id";
            return jdbcTemplate.queryForObject(sql, Integer.class, 
                proyecto.getNombre(), proyecto.getDescripcion(), proyecto.getFecha_inicio(), 
                proyecto.getFecha_fin(), proyecto.getEstado(), proyecto.getId_zona(),
                proyecto.getId_usuario(), proyecto.getUbicacion());
        }
    }

    // READ - Obtener todos
    public List<proyectos_urbanos> findAll() {
        String sql = "SELECT * FROM proyectos_urbanos ORDER BY id";
        return jdbcTemplate.query(sql, rowMapper);
    }

    // READ - Obtener con paginación
    public List<proyectos_urbanos> findAllPaginated(int page, int size) {
        int offset = page * size;
        String sql = "SELECT * FROM proyectos_urbanos ORDER BY id LIMIT ? OFFSET ?";
        return jdbcTemplate.query(sql, rowMapper, size, offset);
    }

    // READ - Contar total
    public int count() {
        String sql = "SELECT COUNT(*) FROM proyectos_urbanos";
        return jdbcTemplate.queryForObject(sql, Integer.class);
    }

    // READ - Obtener por ID
    public proyectos_urbanos findById(int id) {
        String sql = "SELECT * FROM proyectos_urbanos WHERE id = ?";
        List<proyectos_urbanos> results = jdbcTemplate.query(sql, rowMapper, id);
        return results.isEmpty() ? null : results.get(0);
    }

    // UPDATE
    public int update(int id, proyectos_urbanos proyecto) {
        String sql;
        
        // Si ubicacion contiene WKT
        if (proyecto.getUbicacion() != null && 
            (proyecto.getUbicacion().startsWith("POINT") || 
             proyecto.getUbicacion().startsWith("POLYGON") || 
             proyecto.getUbicacion().startsWith("LINESTRING"))) {
            
            sql = "UPDATE proyectos_urbanos SET nombre = ?, descripcion = ?, fecha_inicio = ?, fecha_fin = ?, " +
                  "estado = ?, id_zona = ?, id_usuario = ?, ubicacion = ?, geom = ST_GeomFromText(?, 4326) WHERE id = ?";
            return jdbcTemplate.update(sql, proyecto.getNombre(), proyecto.getDescripcion(), 
                proyecto.getFecha_inicio(), proyecto.getFecha_fin(), proyecto.getEstado(),
                proyecto.getId_zona(), proyecto.getId_usuario(), proyecto.getUbicacion(), 
                proyecto.getUbicacion(), id);
        } else {
            sql = "UPDATE proyectos_urbanos SET nombre = ?, descripcion = ?, fecha_inicio = ?, fecha_fin = ?, " +
                  "estado = ?, id_zona = ?, id_usuario = ?, ubicacion = ? WHERE id = ?";
            return jdbcTemplate.update(sql, proyecto.getNombre(), proyecto.getDescripcion(), 
                proyecto.getFecha_inicio(), proyecto.getFecha_fin(), proyecto.getEstado(),
                proyecto.getId_zona(), proyecto.getId_usuario(), proyecto.getUbicacion(), id);
        }
    }

    // DELETE
    public int delete(int id) {
        String sql = "DELETE FROM proyectos_urbanos WHERE id = ?";
        return jdbcTemplate.update(sql, id);
    }

    // QUERIES SIMPLES
    // Buscar por estado
    public List<proyectos_urbanos> findByEstado(String estado) {
        String sql = "SELECT * FROM proyectos_urbanos WHERE estado = ? ORDER BY fecha_inicio";
        return jdbcTemplate.query(sql, rowMapper, estado);
    }

    // Buscar por zona
    public List<proyectos_urbanos> findByZona(int idZona) {
        String sql = "SELECT * FROM proyectos_urbanos WHERE id_zona = ? ORDER BY fecha_inicio";
        return jdbcTemplate.query(sql, rowMapper, idZona);
    }

    // Buscar por usuario
    public List<proyectos_urbanos> findByUsuario(int idUsuario) {
        String sql = "SELECT * FROM proyectos_urbanos WHERE id_usuario = ? ORDER BY fecha_inicio DESC";
        return jdbcTemplate.query(sql, rowMapper, idUsuario);
    }

    // Buscar por nombre (búsqueda parcial)
    public List<proyectos_urbanos> findByNombre(String nombre) {
        String sql = "SELECT * FROM proyectos_urbanos WHERE nombre ILIKE ? ORDER BY nombre";
        return jdbcTemplate.query(sql, rowMapper, "%" + nombre + "%");
    }

    // MÉTODOS EXISTENTES
    public List<Map<String, Object>> findAllAsMap() {
        // Seleccionamos todos los proyectos
        String sql = "SELECT * FROM proyectos_urbanos";
        return jdbcTemplate.queryForList(sql);
    }

    public List<Map<String, Object>> obtenerProyectosSuperpuestos() {
        String sql = """
            SELECT 
                p1.nombre AS proyecto_a,
                p2.nombre AS proyecto_b,
                ROUND(CAST(ST_Area(ST_Intersection(p1.geom, p2.geom)::geography) AS numeric), 2) AS area_m2
            FROM 
                proyectos_urbanos p1
            JOIN 
                proyectos_urbanos p2 ON p1.id < p2.id
            WHERE 
                ST_Intersects(p1.geom, p2.geom)
        """;
        return jdbcTemplate.queryForList(sql);
    }

    public void actualizarEstadoProyecto(int id_usuario){
        jdbcTemplate.update("CALL actualizar_proyectos_retrasados(?)",
                id_usuario);
    }

}
