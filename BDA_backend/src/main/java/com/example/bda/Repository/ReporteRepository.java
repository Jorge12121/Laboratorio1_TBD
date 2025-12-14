package com.example.bda.Repository;

import com.example.bda.DTO.CercaProyectoUrbanoDTO;
import com.example.bda.DTO.ZonaEscasezServicioDTO;
import com.example.bda.DTO.ZonasRapidoCrecimientoDTO;
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

    // 3. ESCUELAS CERCA
    public List<CercaProyectoUrbanoDTO> obtenerCercaProyectoUrbano() {
        String sql = "SELECT pi.nombre AS escuela, pu.nombre AS proyecto, " +
                "ST_Distance(pi.geom, pu.geom) AS distancia " +
                "FROM puntos_interes pi " +
                "JOIN proyectos_urbanos pu ON pu.estado = 'En Curso' " +
                "WHERE pi.tipo = 'Escuela' " +
                "AND ST_Distance(pi.geom, pu.geom) < 500";

        return jdbcTemplate.query(sql, (rs, rowNum) ->
                new CercaProyectoUrbanoDTO(
                        rs.getString("escuela"),
                        rs.getString("proyecto"),
                        rs.getDouble("distancia")
                ));
    }

    // 4. Zona de Rápido Crecimiento
    public List<ZonasRapidoCrecimientoDTO> obtenerZonasRapidoCrecimiento() {
        //dd es datos_demograficos despues, los más recientes y da es datos_demograficos antes
        String sql = "SELECT z.nombre AS nombreZona, ((dd.poblacion - da.poblacion)::float / da.poblacion) * 100 AS crecimiento " +
                "FROM zonas_urbanas z " +
                "JOIN datos_demograficos dd ON z.id = dd.id_zona AND dd.anio = (SELECT MAX(anio) FROM datos_demograficos d1 WHERE d1.id_zona = z.id) " + //Aqui vemos que es el máximo
                "JOIN datos_demograficos da ON z.id = da.id_zona AND da.anio = (SELECT MAX(d2.anio) FROM datos_demograficos d2 WHERE d2.id_zona = z.id AND d2.anio <= (SELECT MAX(anio) - 5 FROM datos_demograficos)) " +
                "WHERE ((dd.poblacion - da.poblacion)::float / da.poblacion) * 100 > 10 " +
                "LIMIT 3";

        return jdbcTemplate.query(sql, (rs, rowNum) ->
                new ZonasRapidoCrecimientoDTO(
                        rs.getString("nombreZona"),
                        rs.getFloat("crecimiento")
                ));
    }

    // 5. COBERTURA DE INFRAESTRUCTURA (Vista Materializada)
    public List<Map<String, Object>> obtenerCobertura() {
        String sql = "SELECT * FROM vista_cobertura_infraestructura ORDER BY nombre_zona";
        return jdbcTemplate.queryForList(sql);
    }

    // 10. RESUMEN DE PROYECTOS POR ESTADO Y TIPO (Vista Materializada)
    public List<Map<String, Object>> obtenerResumenProyectos() {
        String sql = "SELECT * FROM vista_resumen_proyectos_estado_zona ORDER BY tipo_zona, estado";
        return jdbcTemplate.queryForList(sql);
    }

    // Refrescar Vista Materializada de Resumen
    public void refrescarResumenProyectos() {
        jdbcTemplate.execute("REFRESH MATERIALIZED VIEW CONCURRENTLY vista_resumen_proyectos_estado_zona");
    }
    
}