package com.example.bda.Controller;

import com.example.bda.DTO.CercaProyectoUrbanoDTO;
import com.example.bda.DTO.ZonaEscasezServicioDTO;
import com.example.bda.DTO.ZonasRapidoCrecimientoDTO;
import com.example.bda.Repository.ProyectoRepository;
import com.example.bda.Repository.ZonaRepository;
import com.example.bda.Services.ReporteService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@CrossOrigin(origins = "*")
@RestController
@RequestMapping("/api/reportes") // Prefijo para la URL
public class ReporteController {

    @Autowired
    private ReporteService reporteService;
    @Autowired
    private ZonaRepository zonaRepository;
    @Autowired
    private ProyectoRepository proyectoRepository;

    // URL final para consultas: http://localhost:8090/api/reportes/densidad
    @GetMapping("/densidad")
    public List<Map<String, Object>> verDensidad() {
        return reporteService.getDensidadPoblacion();
    }

    @GetMapping("/escasez")
    public List<ZonaEscasezServicioDTO> verEscasez() {
        return reporteService.obtenerZonaEscasezServicio();
    }

    @GetMapping("/escuelas")
    public List<CercaProyectoUrbanoDTO> verEscuelas() {
        return reporteService.obtenerCercaProyectoUrbano();
    }

    @GetMapping("/crecimiento")
    public List<ZonasRapidoCrecimientoDTO> verCrecimiento() {
        return reporteService.obtenerZonasRapidoCrecimiento();
    }

    @GetMapping("/cobertura")
    public List<Map<String, Object>> verCobertura() {
        return reporteService.obtenerCobertura();
    }

    @GetMapping("/zonas-sin-planificacion")
    public List<Map<String, Object>> getZonasOlvidadas() { return zonaRepository.obtenerZonasSinPlanificacion(); }

    @GetMapping("/superposicion-proyectos")
    public List<Map<String, Object>> getSuperposicionProyectos() { return proyectoRepository.obtenerProyectosSuperpuestos(); }

    @GetMapping("/resumen-proyectos")
    public List<Map<String, Object>> verResumenProyectos() {
        return reporteService.obtenerResumenProyectos();
    }

    @PostMapping("/refrescar-resumen")
    public void refrescarResumen() {
        reporteService.refrescarResumenProyectos();
    }

}
