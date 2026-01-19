package com.example.bda.Repository;

import com.example.bda.Model.puntos_interes;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.RowMapper;
import org.springframework.stereotype.Repository;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.List;

@Repository
public class PuntoInteresRepository {

    @Autowired
    private JdbcTemplate jdbcTemplate;

    private RowMapper<puntos_interes> rowMapper = new RowMapper<puntos_interes>() {
        @Override
        public puntos_interes mapRow(ResultSet rs, int rowNum) throws SQLException {
            puntos_interes punto = new puntos_interes();
            punto.setId_punto(rs.getInt("id"));
            punto.setNombre(rs.getString("nombre"));
            punto.setTipo(rs.getString("tipo"));
            
            // Extraer coordenadas de la geometría PostGIS si existe
            Object geomObj = rs.getObject("geom");
            if (geomObj != null) {
                String geomWkt = geomObj.toString();
                // Parsear POINT(-70.6693 -33.4489) -> longitud, latitud
                if (geomWkt.startsWith("POINT(")) {
                    String coords = geomWkt.substring(6, geomWkt.length() - 1);
                    String[] parts = coords.split(" ");
                    if (parts.length == 2) {
                        punto.setLongitud(Double.parseDouble(parts[0]));
                        punto.setLatitud(Double.parseDouble(parts[1]));
                    }
                }
            }
            
            Object idZonaObj = rs.getObject("id_zona");
            if (idZonaObj != null) {
                punto.setId_zona(rs.getInt("id_zona"));
            }
            return punto;
        }
    };

    // CREATE
    public int create(puntos_interes punto) {
        String sql = "INSERT INTO puntos_interes (nombre, tipo, geom, id_zona) " +
                     "VALUES (?, ?, ST_SetSRID(ST_MakePoint(?, ?), 4326), ?) RETURNING id";
        return jdbcTemplate.queryForObject(sql, Integer.class, 
            punto.getNombre(), 
            punto.getTipo(), 
            punto.getLongitud(), // PostGIS usa longitud primero
            punto.getLatitud(),  // luego latitud
            punto.getId_zona());
    }

    // READ - Obtener todos
    public List<puntos_interes> findAll() {
        String sql = "SELECT * FROM puntos_interes ORDER BY id";
        return jdbcTemplate.query(sql, rowMapper);
    }

    // READ - Obtener con paginación
    public List<puntos_interes> findAllPaginated(int page, int size) {
        int offset = page * size;
        String sql = "SELECT * FROM puntos_interes ORDER BY id LIMIT ? OFFSET ?";
        return jdbcTemplate.query(sql, rowMapper, size, offset);
    }

    // READ - Contar total
    public int count() {
        String sql = "SELECT COUNT(*) FROM puntos_interes";
        return jdbcTemplate.queryForObject(sql, Integer.class);
    }

    // READ - Obtener por ID
    public puntos_interes findById(int id) {
        String sql = "SELECT * FROM puntos_interes WHERE id = ?";
        List<puntos_interes> results = jdbcTemplate.query(sql, rowMapper, id);
        return results.isEmpty() ? null : results.get(0);
    }

    // UPDATE
    public int update(int id, puntos_interes punto) {
        String sql = "UPDATE puntos_interes SET nombre = ?, tipo = ?, " +
                     "geom = ST_SetSRID(ST_MakePoint(?, ?), 4326), id_zona = ? WHERE id = ?";
        return jdbcTemplate.update(sql, 
            punto.getNombre(), 
            punto.getTipo(), 
            punto.getLongitud(), // PostGIS: longitud primero
            punto.getLatitud(),  // latitud segundo
            punto.getId_zona(), 
            id);
    }

    // DELETE
    public int delete(int id) {
        String sql = "DELETE FROM puntos_interes WHERE id = ?";
        return jdbcTemplate.update(sql, id);
    }

    // QUERIES SIMPLES
    // Buscar por tipo
    public List<puntos_interes> findByTipo(String tipo) {
        String sql = "SELECT * FROM puntos_interes WHERE tipo = ? ORDER BY nombre";
        return jdbcTemplate.query(sql, rowMapper, tipo);
    }

    // Buscar por zona
    public List<puntos_interes> findByZona(int idZona) {
        String sql = "SELECT * FROM puntos_interes WHERE id_zona = ? ORDER BY tipo, nombre";
        return jdbcTemplate.query(sql, rowMapper, idZona);
    }

    // Buscar por nombre (búsqueda parcial)
    public List<puntos_interes> findByNombre(String nombre) {
        String sql = "SELECT * FROM puntos_interes WHERE nombre ILIKE ? ORDER BY nombre";
        return jdbcTemplate.query(sql, rowMapper, "%" + nombre + "%");
    }

    // Buscar puntos cercanos a una coordenada
    public List<puntos_interes> findNearby(double latitud, double longitud, double radioKm) {
        String sql = "SELECT * FROM puntos_interes WHERE " +
                     "ST_DWithin(geom::geography, " +
                     "ST_SetSRID(ST_MakePoint(?, ?), 4326)::geography, ?) " +
                     "ORDER BY ST_Distance(geom::geography, " +
                     "ST_SetSRID(ST_MakePoint(?, ?), 4326)::geography)";
        double radioMetros = radioKm * 1000;
        return jdbcTemplate.query(sql, rowMapper, longitud, latitud, radioMetros, longitud, latitud);
    }
}
