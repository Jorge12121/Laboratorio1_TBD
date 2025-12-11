package com.example.bda.Services;

import com.example.bda.DTO.CercaProyectoUrbanoDTO;
import com.example.bda.DTO.ZonaEscasezServicioDTO;
import com.example.bda.Repository.ReporteRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import java.util.List;
import java.util.Map;

@Service
public class ReporteService {

    @Autowired
    private ReporteRepository reporteRepository;

    public List<Map<String, Object>> getDensidadPoblacion() {
        return reporteRepository.obtenerDensidad();
    }

    public List<ZonaEscasezServicioDTO> obtenerZonaEscasezServicio() {
        return reporteRepository.obtenerZonaEscasez();
    }

    public List<CercaProyectoUrbanoDTO> obtenerCercaProyectoUrbano() {
        return reporteRepository.obtenerCercaProyectoUrbano();
    }
}