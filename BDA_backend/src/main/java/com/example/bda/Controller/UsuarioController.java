package com.example.bda.Controller;

import com.example.bda.Model.usuarios;
import com.example.bda.Services.UsuarioService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/usuarios")
public class UsuarioController {

    @Autowired
    private UsuarioService usuarioService; // Inyectamos el Service, NO el Repository

    @PostMapping("/registro")
    public ResponseEntity<String> registrarUsuario(@RequestBody usuarios nuevoUsuario) {
        try {
            // El controller solo delega la tarea al servicio
            String mensaje = usuarioService.registrarNuevoUsuario(nuevoUsuario);
            return ResponseEntity.ok(mensaje);

        } catch (RuntimeException e) {
            // Manejo básico de errores (ej. si el email ya existe)
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(e.getMessage());
        }
    }
}