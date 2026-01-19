package com.example.bda.Services;

import com.example.bda.Model.zonas_urbanas;
import com.example.bda.Repository.ZonaRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Service
public class ZonaService {

    @Autowired
    private ZonaRepository zonaRepository;

    // CREATE
    public zonas_urbanas create(zonas_urbanas zona) {
        int id = zonaRepository.create(zona);
        zona.setId_zona(id);
        return zona;
    }

    // READ - Obtener todos
    public List<zonas_urbanas> getAll() {
        return zonaRepository.findAll();
    }

    // READ - Obtener con paginación
    public Map<String, Object> getAllPaginated(int page, int size) {
        List<zonas_urbanas> zonas = zonaRepository.findAllPaginated(page, size);
        int total = zonaRepository.count();
        
        Map<String, Object> response = new HashMap<>();
        response.put("zonas", zonas);
        response.put("currentPage", page);
        response.put("totalItems", total);
        response.put("totalPages", (int) Math.ceil((double) total / size));
        return response;
    }

    // READ - Obtener por ID
    public zonas_urbanas getById(int id) {
        return zonaRepository.findById(id);
    }

    // UPDATE
    public zonas_urbanas update(int id, zonas_urbanas zona) {
        int rowsAffected = zonaRepository.update(id, zona);
        if (rowsAffected > 0) {
            zona.setId_zona(id);
            return zona;
        }
        return null;
    }

    // DELETE
    public boolean delete(int id) {
        return zonaRepository.delete(id) > 0;
    }

    // QUERIES SIMPLES
    public List<zonas_urbanas> getByTipo(String tipoZona) {
        return zonaRepository.findByTipo(tipoZona);
    }

    public List<zonas_urbanas> getByNombre(String nombre) {
        return zonaRepository.findByNombre(nombre);
    }

    public List<zonas_urbanas> getByAreaRange(float minArea, float maxArea) {
        return zonaRepository.findByAreaRange(minArea, maxArea);
    }

    // MÉTODO EXISTENTE
    public List<Map<String, Object>> obtenerZonasSinPlanificacion() {
        return zonaRepository.obtenerZonasSinPlanificacion();
    }
}

