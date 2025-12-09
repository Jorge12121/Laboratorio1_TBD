package com.example.bda.Repository;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Repository;
import java.util.List;
import java.util.Map;

@Repository
public class ReporteRepository {

    @Autowired
    private JdbcTemplate jdbcTemplate;

    //CONSULTA 1: Cálculo de Densidad
    public List<Map<String, Object>> obtenerDensidad() {
        // Consulta SQL
        String sql = "SELECT z.nombre, d.densidad " +
                "FROM datos_demograficos d " +
                "JOIN zonas_urbanas z ON d.id_zona = z.id " +
                "WHERE d.anio = 2025 " +
                "ORDER BY d.densidad DESC";

        // devuelve una lista de objetos tipo JSON
        // Ejemplo: [{"nombre": "Barrio Norte", "densidad": 9375.00}, ...]
        return jdbcTemplate.queryForList(sql);
    }
}