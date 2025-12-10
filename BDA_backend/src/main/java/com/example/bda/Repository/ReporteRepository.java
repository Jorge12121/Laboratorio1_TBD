package com.example.bda.Repository;

import com.example.bda.DTO.ZonaEscasezServicioDTO;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Repository;
import java.util.List;
import java.util.Map;

@Repository
public class ReporteRepository {

    @Autowired
    private JdbcTemplate jdbcTemplate;

    // 1. DENSIDAD (Ajustado para calcular usando area_km2)
    public List<Map<String, Object>> obtenerDensidad() {
        String sql = "SELECT z.nombre, ROUND((d.poblacion::numeric / z.area_km2::numeric), 2) as densidad " +
                     "FROM datos_demograficos d " +
                     "JOIN zonas_urbanas z ON d.id_zona = z.id " +
                     "WHERE d.anio = 2025 " +
                     "ORDER BY densidad DESC";
        return jdbcTemplate.queryForList(sql);
    }

    // 2. ESCASEZ 
    public List<ZonaEscasezServicioDTO> obtenerZonaEscasez() {
        String sql = "SELECT z.nombre AS nombreZona, d.poblacion, " +
                     "COUNT(p.id) AS hospitales " +
                     "FROM zonas_urbanas z " +
                     "JOIN datos_demograficos d ON d.id_zona = z.id " +
                     "LEFT JOIN puntos_interes p ON z.id = p.id_zona AND p.tipo = 'Hospital' " +
                     "WHERE d.anio = 2025 " +
                     "GROUP BY z.id, z.nombre, d.poblacion " +
                     "ORDER BY d.poblacion DESC, hospitales ASC " +
                     "LIMIT 5";

        return jdbcTemplate.query(sql, (rs, rowNum) ->
                new ZonaEscasezServicioDTO(
                        rs.getString("nombreZona"),
                        rs.getInt("poblacion"),
                        rs.getInt("hospitales")
                ));
    }
    
}