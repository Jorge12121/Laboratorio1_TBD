package com.example.bda.Services;

import com.example.bda.DTO.*;
import com.example.bda.Repository.ConsultasEspacialesRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class ConsultasEspacialesService {

    @Autowired
    private ConsultasEspacialesRepository consultasRepository;

    // ============ DENSIDAD REAL ============
    
    public List<DensidadRealDTO> obtenerDensidadReal() {
        return consultasRepository.obtenerDensidadReal();
    }

    public List<DensidadRealDTO> obtenerDensidadRealPorZona(Long idZona) {
        return consultasRepository.obtenerDensidadRealPorZona(idZona);
    }

    // ============ PROXIMIDAD (ESCUELAS) ============
    
    public List<EscuelaCercanaDTO> obtenerEscuelasCercanas() {
        return consultasRepository.obtenerEscuelasCercanas();
    }

    public List<EscuelaCercanaDTO> obtenerEscuelasCercanasPorProyecto(Long idProyecto) {
        return consultasRepository.obtenerEscuelasCercanasPorProyecto(idProyecto);
    }

    // ============ SUPERPOSICIÓN DE PROYECTOS ============
    
    public List<ProyectoSuperpuestoDTO> obtenerProyectosSuperpuestos() {
        return consultasRepository.obtenerProyectosSuperpuestos();
    }

    public List<ProyectoSuperpuestoDTO> obtenerProyectosSuperpuestosPorId(Long idProyecto) {
        return consultasRepository.obtenerProyectosSuperpuestosPorId(idProyecto);
    }

    // ============ COBERTURA DE SERVICIOS ============
    
    public List<CoberturaServicioDTO> obtenerCoberturaServicios() {
        return consultasRepository.obtenerCoberturaServicios();
    }

    public CoberturaServicioDTO obtenerCoberturaServiciosPorZona(Long idZona) {
        return consultasRepository.obtenerCoberturaServiciosPorZona(idZona);
    }
}
