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
}
