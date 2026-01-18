package com.example.demo.controller;

import com.example.demo.dto.*;
import com.example.demo.service.ConsultasEspacialesService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/consultas-espaciales")
@CrossOrigin(origins = "*")
public class ConsultasEspacialesController {

    @Autowired
    private ConsultasEspacialesService consultasService;

    // ============================================================
    // 1. CÁLCULO DE DENSIDAD REAL
    // ============================================================

    /**
     * GET /api/consultas-espaciales/densidad-real
     * Obtiene la densidad real de todas las zonas (población / área real en km²)
     */
    @GetMapping("/densidad-real")
    public ResponseEntity<List<DensidadRealDTO>> obtenerDensidadReal() {
        List<DensidadRealDTO> resultado = consultasService.obtenerDensidadReal();
        return ResponseEntity.ok(resultado);
    }

    /**
     * GET /api/consultas-espaciales/densidad-real/{idZona}
     * Obtiene la densidad real de una zona específica
     */
    @GetMapping("/densidad-real/{idZona}")
    public ResponseEntity<List<DensidadRealDTO>> obtenerDensidadRealPorZona(@PathVariable Long idZona) {
        List<DensidadRealDTO> resultado = consultasService.obtenerDensidadRealPorZona(idZona);
        return ResponseEntity.ok(resultado);
    }

    // ============================================================
    // 2. ANÁLISIS DE PROXIMIDAD (ESCUELAS)
    // ============================================================

    /**
     * GET /api/consultas-espaciales/escuelas-cercanas
     * Encuentra escuelas a menos de 500m de proyectos en curso
     */
    @GetMapping("/escuelas-cercanas")
    public ResponseEntity<List<EscuelaCercanaDTO>> obtenerEscuelasCercanas() {
        List<EscuelaCercanaDTO> resultado = consultasService.obtenerEscuelasCercanas();
        return ResponseEntity.ok(resultado);
    }

    /**
     * GET /api/consultas-espaciales/escuelas-cercanas/proyecto/{idProyecto}
     * Encuentra escuelas cercanas a un proyecto específico
     */
    @GetMapping("/escuelas-cercanas/proyecto/{idProyecto}")
    public ResponseEntity<List<EscuelaCercanaDTO>> obtenerEscuelasCercanasPorProyecto(@PathVariable Long idProyecto) {
        List<EscuelaCercanaDTO> resultado = consultasService.obtenerEscuelasCercanasPorProyecto(idProyecto);
        return ResponseEntity.ok(resultado);
    }

    // ============================================================
    // 3. SUPERPOSICIÓN DE PROYECTOS
    // ============================================================

    /**
     * GET /api/consultas-espaciales/proyectos-superpuestos
     * Identifica pares de proyectos que se superponen y calcula el área de conflicto
     */
    @GetMapping("/proyectos-superpuestos")
    public ResponseEntity<List<ProyectoSuperpuestoDTO>> obtenerProyectosSuperpuestos() {
        List<ProyectoSuperpuestoDTO> resultado = consultasService.obtenerProyectosSuperpuestos();
        return ResponseEntity.ok(resultado);
    }

    /**
     * GET /api/consultas-espaciales/proyectos-superpuestos/{idProyecto}
     * Obtiene las superposiciones que involucran un proyecto específico
     */
    @GetMapping("/proyectos-superpuestos/{idProyecto}")
    public ResponseEntity<List<ProyectoSuperpuestoDTO>> obtenerProyectosSuperpuestosPorId(@PathVariable Long idProyecto) {
        List<ProyectoSuperpuestoDTO> resultado = consultasService.obtenerProyectosSuperpuestosPorId(idProyecto);
        return ResponseEntity.ok(resultado);
    }

    // ============================================================
    // 4. COBERTURA DE SERVICIOS (HOSPITALES)
    // ============================================================

    /**
     * GET /api/consultas-espaciales/cobertura-servicios
     * Calcula el % del área de cada zona cubierta por hospitales (buffer 1km)
     */
    @GetMapping("/cobertura-servicios")
    public ResponseEntity<List<CoberturaServicioDTO>> obtenerCoberturaServicios() {
        List<CoberturaServicioDTO> resultado = consultasService.obtenerCoberturaServicios();
        return ResponseEntity.ok(resultado);
    }

    /**
     * GET /api/consultas-espaciales/cobertura-servicios/{idZona}
     * Obtiene la cobertura de servicios de una zona específica
     */
    @GetMapping("/cobertura-servicios/{idZona}")
    public ResponseEntity<CoberturaServicioDTO> obtenerCoberturaServiciosPorZona(@PathVariable Long idZona) {
        CoberturaServicioDTO resultado = consultasService.obtenerCoberturaServiciosPorZona(idZona);
        if (resultado == null) {
            return ResponseEntity.notFound().build();
        }
        return ResponseEntity.ok(resultado);
    }
}
