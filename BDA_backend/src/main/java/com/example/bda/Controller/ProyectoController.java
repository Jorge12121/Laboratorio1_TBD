package com.example.bda.Controller;

import com.example.bda.Model.proyectos_urbanos;
import com.example.bda.Services.ProyectoService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@CrossOrigin(origins = "*")
@RestController
@RequestMapping("/api/proyectos")
public class ProyectoController {

    @Autowired
    private ProyectoService proyectoService;

    // CREATE
    @PostMapping
    public ResponseEntity<proyectos_urbanos> create(@RequestBody proyectos_urbanos proyecto) {
        proyectos_urbanos created = proyectoService.create(proyecto);
        return ResponseEntity.status(HttpStatus.CREATED).body(created);
    }

    // READ - Obtener todos como objetos
    @GetMapping
    public ResponseEntity<List<proyectos_urbanos>> getAll() {
        return ResponseEntity.ok(proyectoService.getAll());
    }

    // READ - Obtener todos como Map (método existente)
    @GetMapping("/map")
    public ResponseEntity<List<Map<String, Object>>> getAllAsMap() {
        return ResponseEntity.ok(proyectoService.getAllProyectos());
    }

    // READ - Obtener con paginación
    @GetMapping("/paginated")
    public ResponseEntity<Map<String, Object>> getAllPaginated(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "10") int size) {
        return ResponseEntity.ok(proyectoService.getAllPaginated(page, size));
    }

    // READ - Obtener por ID
    @GetMapping("/{id}")
    public ResponseEntity<proyectos_urbanos> getById(@PathVariable int id) {
        proyectos_urbanos proyecto = proyectoService.getById(id);
        return proyecto != null ? ResponseEntity.ok(proyecto) : ResponseEntity.notFound().build();
    }

    // UPDATE
    @PutMapping("/{id}")
    public ResponseEntity<proyectos_urbanos> update(@PathVariable int id, @RequestBody proyectos_urbanos proyecto) {
        proyectos_urbanos updated = proyectoService.update(id, proyecto);
        return updated != null ? ResponseEntity.ok(updated) : ResponseEntity.notFound().build();
    }

    // DELETE
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> delete(@PathVariable int id) {
        return proyectoService.delete(id) ? ResponseEntity.noContent().build() : ResponseEntity.notFound().build();
    }

    // QUERIES SIMPLES
    @GetMapping("/estado/{estado}")
    public ResponseEntity<List<proyectos_urbanos>> getByEstado(@PathVariable String estado) {
        return ResponseEntity.ok(proyectoService.getByEstado(estado));
    }

    @GetMapping("/zona/{idZona}")
    public ResponseEntity<List<proyectos_urbanos>> getByZona(@PathVariable int idZona) {
        return ResponseEntity.ok(proyectoService.getByZona(idZona));
    }

    @GetMapping("/usuario/{idUsuario}")
    public ResponseEntity<List<proyectos_urbanos>> getByUsuario(@PathVariable int idUsuario) {
        return ResponseEntity.ok(proyectoService.getByUsuario(idUsuario));
    }

    @GetMapping("/nombre")
    public ResponseEntity<List<proyectos_urbanos>> getByNombre(@RequestParam String nombre) {
        return ResponseEntity.ok(proyectoService.getByNombre(nombre));
    }

    // MÉTODO EXISTENTE
    @PatchMapping("/retrasos/id_usuario/{id_usuario}")
    public void actualizarEstadoProyecto(@PathVariable int id_usuario) {
        proyectoService.actualizarEstadoProyecto(id_usuario);
    }
}
