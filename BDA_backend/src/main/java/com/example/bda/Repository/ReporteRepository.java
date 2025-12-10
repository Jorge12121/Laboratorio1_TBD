package com.example.bda.Repository;

import com.example.bda.DTO.ZonaEscazesServicioDTO;
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

    //Voy agregar la respuesta de la 2 acá también
    public List<ZonaEscazesServicioDTO> obtenerZonaEscazes() {
        //SQL
        String sql =
                "SELECT z.nombre, d.poblacion, COUNT(p.id) AS hospitales " +
                "FROM zonas_urbanas z " +
                "JOIN datos_demograficos d ON d.id_zona = z.id " +
                "LEFT JOIN puntos_interes p ON z.id = p.id_zona AND p.tipo = 'Hospital' " +
                "GROUP BY z.id, z.nombre, d.poblacion " +
                "ORDER BY d.poblacion DESC, hospitales ASC " +
                "LIMIT 5";


        return jdbcTemplate.query(sql, (rs, rowNum) ->
                new ZonaEscazesServicioDTO(
                        rs.getString("nombre"),
                        rs.getInt("poblacion"),
                        rs.getInt("hospitales")
                ));
    }
}