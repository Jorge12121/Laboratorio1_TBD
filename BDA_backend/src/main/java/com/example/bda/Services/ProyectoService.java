package com.example.bda.Services;

import com.example.bda.Model.proyectos_urbanos;
import com.example.bda.Repository.ProyectoRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Service
public class ProyectoService {

    @Autowired
    private ProyectoRepository proyectoRepository;

    // CREATE
    public proyectos_urbanos create(proyectos_urbanos proyecto) {
        int id = proyectoRepository.create(proyecto);
        proyecto.setId_proyectos(id);
        return proyecto;
    }

    // READ - Obtener todos
    public List<proyectos_urbanos> getAll() {
        return proyectoRepository.findAll();
    }

    // READ - Obtener con paginación
    public Map<String, Object> getAllPaginated(int page, int size) {
        List<proyectos_urbanos> proyectos = proyectoRepository.findAllPaginated(page, size);
        int total = proyectoRepository.count();
        
        Map<String, Object> response = new HashMap<>();
        response.put("proyectos", proyectos);
        response.put("currentPage", page);
        response.put("totalItems", total);
        response.put("totalPages", (int) Math.ceil((double) total / size));
        return response;
    }

    // READ - Obtener por ID
    public proyectos_urbanos getById(int id) {
        return proyectoRepository.findById(id);
    }

    // UPDATE
    public proyectos_urbanos update(int id, proyectos_urbanos proyecto) {
        int rowsAffected = proyectoRepository.update(id, proyecto);
        if (rowsAffected > 0) {
            proyecto.setId_proyectos(id);
            return proyecto;
        }
        return null;
    }

    // DELETE
    public boolean delete(int id) {
        return proyectoRepository.delete(id) > 0;
    }

    // QUERIES SIMPLES
    public List<proyectos_urbanos> getByEstado(String estado) {
        return proyectoRepository.findByEstado(estado);
    }

    public List<proyectos_urbanos> getByZona(int idZona) {
        return proyectoRepository.findByZona(idZona);
    }

    public List<proyectos_urbanos> getByUsuario(int idUsuario) {
        return proyectoRepository.findByUsuario(idUsuario);
    }

    public List<proyectos_urbanos> getByNombre(String nombre) {
        return proyectoRepository.findByNombre(nombre);
    }

    // MÉTODOS EXISTENTES
    public List<Map<String, Object>> getAllProyectos() {
        return proyectoRepository.findAllAsMap();
    }

    public void actualizarEstadoProyecto(int id_usario){
        proyectoRepository.actualizarEstadoProyecto(id_usario);
    }
}
