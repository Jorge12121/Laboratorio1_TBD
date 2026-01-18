package com.example.demo.repository;

import com.example.demo.dto.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Repository;

import java.math.BigDecimal;
import java.util.List;

@Repository
public class ConsultasEspacialesRepository {

    @Autowired
    private JdbcTemplate jdbcTemplate;

    /**
     * 1. Cálculo de Densidad Real
     * Usa la vista v_densidad_real
     */
    public List<DensidadRealDTO> obtenerDensidadReal() {
        String sql = "SELECT id_zona, nombre_zona, anio, poblacion, area_real_km2, densidad_real_hab_km2 " +
                     "FROM v_densidad_real " +
                     "ORDER BY id_zona, anio DESC";
        
        return jdbcTemplate.query(sql, (rs, rowNum) -> new DensidadRealDTO(
            rs.getLong("id_zona"),
            rs.getString("nombre_zona"),
            rs.getInt("anio"),
            rs.getInt("poblacion"),
            rs.getBigDecimal("area_real_km2"),
            rs.getBigDecimal("densidad_real_hab_km2")
        ));
    }

    /**
     * Densidad real de una zona específica
     */
    public List<DensidadRealDTO> obtenerDensidadRealPorZona(Long idZona) {
        String sql = "SELECT id_zona, nombre_zona, anio, poblacion, area_real_km2, densidad_real_hab_km2 " +
                     "FROM v_densidad_real " +
                     "WHERE id_zona = ? " +
                     "ORDER BY anio DESC";
        
        return jdbcTemplate.query(sql, new Object[]{idZona}, (rs, rowNum) -> new DensidadRealDTO(
            rs.getLong("id_zona"),
            rs.getString("nombre_zona"),
            rs.getInt("anio"),
            rs.getInt("poblacion"),
            rs.getBigDecimal("area_real_km2"),
            rs.getBigDecimal("densidad_real_hab_km2")
        ));
    }

    /**
     * 2. Análisis de Proximidad
     * Escuelas a menos de 500m de proyectos en curso
     */
    public List<EscuelaCercanaDTO> obtenerEscuelasCercanas() {
        String sql = "SELECT id_proyecto, nombre_proyecto, id_escuela, nombre_escuela, distancia_m " +
                     "FROM v_escuelas_cerca_proyectos_en_curso " +
                     "ORDER BY distancia_m";
        
        return jdbcTemplate.query(sql, (rs, rowNum) -> new EscuelaCercanaDTO(
            rs.getLong("id_proyecto"),
            rs.getString("nombre_proyecto"),
            rs.getLong("id_escuela"),
            rs.getString("nombre_escuela"),
            rs.getBigDecimal("distancia_m")
        ));
    }

    /**
     * Escuelas cercanas a un proyecto específico
     */
    public List<EscuelaCercanaDTO> obtenerEscuelasCercanasPorProyecto(Long idProyecto) {
        String sql = "SELECT id_proyecto, nombre_proyecto, id_escuela, nombre_escuela, distancia_m " +
                     "FROM v_escuelas_cerca_proyectos_en_curso " +
                     "WHERE id_proyecto = ? " +
                     "ORDER BY distancia_m";
        
        return jdbcTemplate.query(sql, new Object[]{idProyecto}, (rs, rowNum) -> new EscuelaCercanaDTO(
            rs.getLong("id_proyecto"),
            rs.getString("nombre_proyecto"),
            rs.getLong("id_escuela"),
            rs.getString("nombre_escuela"),
            rs.getBigDecimal("distancia_m")
        ));
    }

    /**
     * 3. Superposición de Proyectos
     * Identifica proyectos que se superponen geográficamente
     */
    public List<ProyectoSuperpuestoDTO> obtenerProyectosSuperpuestos() {
        String sql = "SELECT proyecto_a, proyecto_b, nombre_a, nombre_b, area_conflicto_m2 " +
                     "FROM v_proyectos_superpuestos " +
                     "ORDER BY area_conflicto_m2 DESC";
        
        return jdbcTemplate.query(sql, (rs, rowNum) -> new ProyectoSuperpuestoDTO(
            rs.getLong("proyecto_a"),
            rs.getLong("proyecto_b"),
            rs.getString("nombre_a"),
            rs.getString("nombre_b"),
            rs.getBigDecimal("area_conflicto_m2")
        ));
    }

    /**
     * Superposiciones que involucran un proyecto específico
     */
    public List<ProyectoSuperpuestoDTO> obtenerProyectosSuperpuestosPorId(Long idProyecto) {
        String sql = "SELECT proyecto_a, proyecto_b, nombre_a, nombre_b, area_conflicto_m2 " +
                     "FROM v_proyectos_superpuestos " +
                     "WHERE proyecto_a = ? OR proyecto_b = ? " +
                     "ORDER BY area_conflicto_m2 DESC";
        
        return jdbcTemplate.query(sql, new Object[]{idProyecto, idProyecto}, (rs, rowNum) -> new ProyectoSuperpuestoDTO(
            rs.getLong("proyecto_a"),
            rs.getLong("proyecto_b"),
            rs.getString("nombre_a"),
            rs.getString("nombre_b"),
            rs.getBigDecimal("area_conflicto_m2")
        ));
    }

    /**
     * 4. Cobertura de Servicios
     * % área cubierta por hospitales (buffer 1km)
     */
    public List<CoberturaServicioDTO> obtenerCoberturaServicios() {
        String sql = "SELECT id_zona, nombre_zona, area_zona_m2, area_cubierta_m2, porcentaje_cobertura " +
                     "FROM v_cobertura_servicios_hospitales " +
                     "ORDER BY porcentaje_cobertura DESC NULLS LAST";
        
        return jdbcTemplate.query(sql, (rs, rowNum) -> new CoberturaServicioDTO(
            rs.getLong("id_zona"),
            rs.getString("nombre_zona"),
            rs.getBigDecimal("area_zona_m2"),
            rs.getBigDecimal("area_cubierta_m2"),
            rs.getBigDecimal("porcentaje_cobertura")
        ));
    }

    /**
     * Cobertura de servicios de una zona específica
     */
    public CoberturaServicioDTO obtenerCoberturaServiciosPorZona(Long idZona) {
        String sql = "SELECT id_zona, nombre_zona, area_zona_m2, area_cubierta_m2, porcentaje_cobertura " +
                     "FROM v_cobertura_servicios_hospitales " +
                     "WHERE id_zona = ?";
        
        List<CoberturaServicioDTO> result = jdbcTemplate.query(sql, new Object[]{idZona}, 
            (rs, rowNum) -> new CoberturaServicioDTO(
                rs.getLong("id_zona"),
                rs.getString("nombre_zona"),
                rs.getBigDecimal("area_zona_m2"),
                rs.getBigDecimal("area_cubierta_m2"),
                rs.getBigDecimal("porcentaje_cobertura")
            ));
        
        return result.isEmpty() ? null : result.get(0);
    }
}
