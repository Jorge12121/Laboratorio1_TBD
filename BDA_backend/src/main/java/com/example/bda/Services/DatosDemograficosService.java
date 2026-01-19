package com.example.bda.Services;

import com.example.bda.Model.datos_demograficos;
import com.example.bda.Repository.DatosDemograficosRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Service
public class DatosDemograficosService {

    @Autowired
    private DatosDemograficosRepository repository;

    // CREATE
    public datos_demograficos create(datos_demograficos dato) {
        int id = repository.create(dato);
        dato.setId_datos(id);
        return dato;
    }

    // READ - Obtener todos
    public List<datos_demograficos> getAll() {
        return repository.findAll();
    }

    // READ - Obtener con paginación
    public Map<String, Object> getAllPaginated(int page, int size) {
        List<datos_demograficos> datos = repository.findAllPaginated(page, size);
        int total = repository.count();
        
        Map<String, Object> response = new HashMap<>();
        response.put("datos", datos);
        response.put("currentPage", page);
        response.put("totalItems", total);
        response.put("totalPages", (int) Math.ceil((double) total / size));
        return response;
    }

    // READ - Obtener por ID
    public datos_demograficos getById(int id) {
        return repository.findById(id);
    }

    // UPDATE
    public datos_demograficos update(int id, datos_demograficos dato) {
        int rowsAffected = repository.update(id, dato);
        if (rowsAffected > 0) {
            dato.setId_datos(id);
            return dato;
        }
        return null;
    }

    // DELETE
    public boolean delete(int id) {
        return repository.delete(id) > 0;
    }

    // QUERIES SIMPLES
    public List<datos_demograficos> getByZona(int idZona) {
        return repository.findByZona(idZona);
    }

    public List<datos_demograficos> getByAnio(int anio) {
        return repository.findByAnio(anio);
    }

    public List<datos_demograficos> getByPoblacionRange(int min, int max) {
        return repository.findByPoblacionRange(min, max);
    }

    // MÉTODO EXISTENTE
    public void simularCrecimiento(int id_zona, int casas){
        repository.simularCrecimiento(id_zona, casas);
    }
}
