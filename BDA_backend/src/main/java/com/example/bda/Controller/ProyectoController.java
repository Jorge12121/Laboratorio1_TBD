package com.example.bda.Controller;

import com.example.bda.Services.ProyectoService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
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
}
