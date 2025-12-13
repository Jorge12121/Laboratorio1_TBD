package com.example.bda.Controller;

import com.example.bda.Services.ProyectoService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@CrossOrigin(origins = "*") // Importante para evitar CORS
@RestController
@RequestMapping("/api/proyectos")
public class ProyectoController {

    @Autowired
    private ProyectoService proyectoService;

    // ESTE ES EL MÉTODO QUE FALTABA
    @GetMapping
    public List<Map<String, Object>> obtenerTodos() {
        return proyectoService.getAllProyectos();
    }

    @PatchMapping("/retrasos/id_usuario/{id_usuario}")
    public void actualizarEstadoProyecto(@PathVariable int id_usuario) {
        proyectoService.actualizarEstadoProyecto(id_usuario);
    }
}
