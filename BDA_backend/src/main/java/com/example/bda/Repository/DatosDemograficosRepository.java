package com.example.bda.Repository;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Repository;

@Repository
public class DatosDemograficosRepository {

    @Autowired
    private JdbcTemplate jdbcTemplate;

    public void simularCrecimiento(int id_zona, int casas){
        jdbcTemplate.update("CALL simular_crecimiento_poblacion(?, ?)",
                id_zona,
                casas);
    }


}
