package com.example.bda.Services;

import com.example.bda.Model.puntos_interes;
import com.example.bda.Repository.PuntoInteresRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Service
public class PuntoInteresService {

    @Autowired
    private PuntoInteresRepository repository;

    // CREATE
    public puntos_interes create(puntos_interes punto) {
        int id = repository.create(punto);
        punto.setId_punto(id);
        return punto;
    }

    // READ - Obtener todos
    public List<puntos_interes> getAll() {
        return repository.findAll();
    }

    // READ - Obtener con paginación
    public Map<String, Object> getAllPaginated(int page, int size) {
        List<puntos_interes> puntos = repository.findAllPaginated(page, size);
        int total = repository.count();
        
        Map<String, Object> response = new HashMap<>();
        response.put("puntos", puntos);
        response.put("currentPage", page);
        response.put("totalItems", total);
        response.put("totalPages", (int) Math.ceil((double) total / size));
        return response;
    }

    // READ - Obtener por ID
    public puntos_interes getById(int id) {
        return repository.findById(id);
    }

    // UPDATE
    public puntos_interes update(int id, puntos_interes punto) {
        int rowsAffected = repository.update(id, punto);
        if (rowsAffected > 0) {
            punto.setId_punto(id);
            return punto;
        }
        return null;
    }

    // DELETE
    public boolean delete(int id) {
        return repository.delete(id) > 0;
    }

    // QUERIES SIMPLES
    public List<puntos_interes> getByTipo(String tipo) {
        return repository.findByTipo(tipo);
    }

    public List<puntos_interes> getByZona(int idZona) {
        return repository.findByZona(idZona);
    }

    public List<puntos_interes> getByNombre(String nombre) {
        return repository.findByNombre(nombre);
    }

    public List<puntos_interes> getNearby(double latitud, double longitud, double radioKm) {
        return repository.findNearby(latitud, longitud, radioKm);
    }
}
