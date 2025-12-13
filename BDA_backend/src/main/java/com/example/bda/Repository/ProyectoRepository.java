package com.example.bda.Repository;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Repository;
import java.util.List;
import java.util.Map;

@Repository
public class ProyectoRepository {

    @Autowired
    private JdbcTemplate jdbcTemplate;

    public List<Map<String, Object>> findAll() {
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

}
