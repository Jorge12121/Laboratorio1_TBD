package com.example.bda.Repository;

import com.example.bda.Model.datos_demograficos;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.RowMapper;
import org.springframework.stereotype.Repository;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.List;

@Repository
public class DatosDemograficosRepository {

    @Autowired
    private JdbcTemplate jdbcTemplate;

    private RowMapper<datos_demograficos> rowMapper = new RowMapper<datos_demograficos>() {
        @Override
        public datos_demograficos mapRow(ResultSet rs, int rowNum) throws SQLException {
            datos_demograficos dato = new datos_demograficos();
            dato.setId_datos(rs.getInt("id"));
            dato.setId_zona(rs.getInt("id_zona"));
            dato.setAnio(rs.getInt("anio"));
            dato.setPoblacion(rs.getInt("poblacion"));
            dato.setDensidad(rs.getFloat("densidad"));
            dato.setEdad_promedio(rs.getFloat("edad_promedio"));
            return dato;
        }
    };

    // CREATE
    public int create(datos_demograficos dato) {
        String sql = "INSERT INTO datos_demograficos (id_zona, anio, poblacion, densidad, edad_promedio) VALUES (?, ?, ?, ?, ?) RETURNING id";
        return jdbcTemplate.queryForObject(sql, Integer.class, dato.getId_zona(), dato.getAnio(), 
                dato.getPoblacion(), dato.getDensidad(), dato.getEdad_promedio());
    }

    // READ - Obtener todos
    public List<datos_demograficos> findAll() {
        String sql = "SELECT * FROM datos_demograficos ORDER BY id";
        return jdbcTemplate.query(sql, rowMapper);
    }

    // READ - Obtener con paginación
    public List<datos_demograficos> findAllPaginated(int page, int size) {
        int offset = page * size;
        String sql = "SELECT * FROM datos_demograficos ORDER BY id LIMIT ? OFFSET ?";
        return jdbcTemplate.query(sql, rowMapper, size, offset);
    }

    // READ - Contar total
    public int count() {
        String sql = "SELECT COUNT(*) FROM datos_demograficos";
        return jdbcTemplate.queryForObject(sql, Integer.class);
    }

    // READ - Obtener por ID
    public datos_demograficos findById(int id) {
        String sql = "SELECT * FROM datos_demograficos WHERE id = ?";
        List<datos_demograficos> results = jdbcTemplate.query(sql, rowMapper, id);
        return results.isEmpty() ? null : results.get(0);
    }

    // UPDATE
    public int update(int id, datos_demograficos dato) {
        String sql = "UPDATE datos_demograficos SET id_zona = ?, anio = ?, poblacion = ?, densidad = ?, edad_promedio = ? WHERE id = ?";
        return jdbcTemplate.update(sql, dato.getId_zona(), dato.getAnio(), dato.getPoblacion(), 
                dato.getDensidad(), dato.getEdad_promedio(), id);
    }

    // DELETE
    public int delete(int id) {
        String sql = "DELETE FROM datos_demograficos WHERE id = ?";
        return jdbcTemplate.update(sql, id);
    }

    // QUERIES SIMPLES
    // Buscar por zona
    public List<datos_demograficos> findByZona(int idZona) {
        String sql = "SELECT * FROM datos_demograficos WHERE id_zona = ? ORDER BY anio";
        return jdbcTemplate.query(sql, rowMapper, idZona);
    }

    // Buscar por año
    public List<datos_demograficos> findByAnio(int anio) {
        String sql = "SELECT * FROM datos_demograficos WHERE anio = ? ORDER BY id_zona";
        return jdbcTemplate.query(sql, rowMapper, anio);
    }

    // Buscar por rango de población
    public List<datos_demograficos> findByPoblacionRange(int min, int max) {
        String sql = "SELECT * FROM datos_demograficos WHERE poblacion BETWEEN ? AND ? ORDER BY poblacion DESC";
        return jdbcTemplate.query(sql, rowMapper, min, max);
    }

    // MÉTODO EXISTENTE
    public void simularCrecimiento(int id_zona, int casas){
        jdbcTemplate.update("CALL simular_crecimiento_poblacion(?, ?)",
                id_zona,
                casas);
    }


}
