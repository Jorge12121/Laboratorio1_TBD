package com.example.bda.Controller;

import com.example.bda.Model.usuarios;
import com.example.bda.Services.UsuarioService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.List;
import java.util.Map;

@CrossOrigin(origins = "*")
@RestController
@RequestMapping("/api/usuarios")
public class UsuarioController {

    @Autowired
    private UsuarioService usuarioService; 

    // CREATE
    @PostMapping
    public ResponseEntity<?> create(@RequestBody usuarios usuario) {
        try {
            usuarios created = usuarioService.create(usuario);
            return ResponseEntity.status(HttpStatus.CREATED).body(created);
        } catch (RuntimeException e) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(e.getMessage());
        }
    }

    // READ - Obtener todos
    @GetMapping
    public ResponseEntity<List<usuarios>> getAll() {
        return ResponseEntity.ok(usuarioService.getAll());
    }

    // READ - Obtener con paginación
    @GetMapping("/paginated")
    public ResponseEntity<Map<String, Object>> getAllPaginated(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "10") int size) {
        return ResponseEntity.ok(usuarioService.getAllPaginated(page, size));
    }

    // READ - Obtener por ID
    @GetMapping("/{id}")
    public ResponseEntity<usuarios> getById(@PathVariable int id) {
        usuarios usuario = usuarioService.getById(id);
        return usuario != null ? ResponseEntity.ok(usuario) : ResponseEntity.notFound().build();
    }

    // UPDATE
    @PutMapping("/{id}")
    public ResponseEntity<?> update(@PathVariable int id, @RequestBody usuarios usuario) {
        try {
            usuarios updated = usuarioService.update(id, usuario);
            return updated != null ? ResponseEntity.ok(updated) : ResponseEntity.notFound().build();
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(e.getMessage());
        }
    }

    // DELETE
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> delete(@PathVariable int id) {
        return usuarioService.delete(id) ? ResponseEntity.noContent().build() : ResponseEntity.notFound().build();
    }

    // QUERIES SIMPLES
    @GetMapping("/rol/{rol}")
    public ResponseEntity<List<usuarios>> getByRol(@PathVariable String rol) {
        return ResponseEntity.ok(usuarioService.getByRol(rol));
    }

    @GetMapping("/nombre")
    public ResponseEntity<List<usuarios>> getByNombre(@RequestParam String nombre) {
        return ResponseEntity.ok(usuarioService.getByNombre(nombre));
    }

    // MÉTODO EXISTENTE PARA REGISTRO
    @PostMapping("/registro")
    public ResponseEntity<String> registrarUsuario(@RequestBody usuarios nuevoUsuario) {
        try {
            // El controlleR delega la tarea al servicio
            String mensaje = usuarioService.registrarNuevoUsuario(nuevoUsuario);
            return ResponseEntity.ok(mensaje);

        } catch (RuntimeException e) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(e.getMessage());
        }
    }
}