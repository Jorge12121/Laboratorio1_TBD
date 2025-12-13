package com.example.bda.Repository;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Map;

@Repository
public class ZonaRepository {

    @Autowired
    private JdbcTemplate jdbcTemplate;

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