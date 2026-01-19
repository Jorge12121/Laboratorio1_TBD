package com.example.bda.Controller;

import com.example.bda.Model.zonas_urbanas;
import com.example.bda.Services.ZonaService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.List;
import java.util.Map;

@CrossOrigin(origins = "*")
@RestController
@RequestMapping("/api/zona")
public class ZonaController {

    @Autowired
    private ZonaService zonaService;

    // CREATE
    @PostMapping
    public ResponseEntity<zonas_urbanas> create(@RequestBody zonas_urbanas zona) {
        zonas_urbanas created = zonaService.create(zona);
        return ResponseEntity.status(HttpStatus.CREATED).body(created);
    }

    // READ - Obtener todos
    @GetMapping
    public ResponseEntity<List<zonas_urbanas>> getAll() {
        return ResponseEntity.ok(zonaService.getAll());
    }

    // READ - Obtener con paginación
    @GetMapping("/paginated")
    public ResponseEntity<Map<String, Object>> getAllPaginated(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "10") int size) {
        return ResponseEntity.ok(zonaService.getAllPaginated(page, size));
    }

    // READ - Obtener por ID
    @GetMapping("/{id}")
    public ResponseEntity<zonas_urbanas> getById(@PathVariable int id) {
        zonas_urbanas zona = zonaService.getById(id);
        return zona != null ? ResponseEntity.ok(zona) : ResponseEntity.notFound().build();
    }

    // UPDATE
    @PutMapping("/{id}")
    public ResponseEntity<zonas_urbanas> update(@PathVariable int id, @RequestBody zonas_urbanas zona) {
        zonas_urbanas updated = zonaService.update(id, zona);
        return updated != null ? ResponseEntity.ok(updated) : ResponseEntity.notFound().build();
    }

    // DELETE
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> delete(@PathVariable int id) {
        return zonaService.delete(id) ? ResponseEntity.noContent().build() : ResponseEntity.notFound().build();
    }

    // QUERIES SIMPLES
    @GetMapping("/tipo/{tipoZona}")
    public ResponseEntity<List<zonas_urbanas>> getByTipo(@PathVariable String tipoZona) {
        return ResponseEntity.ok(zonaService.getByTipo(tipoZona));
    }

    @GetMapping("/nombre")
    public ResponseEntity<List<zonas_urbanas>> getByNombre(@RequestParam String nombre) {
        return ResponseEntity.ok(zonaService.getByNombre(nombre));
    }

    @GetMapping("/area")
    public ResponseEntity<List<zonas_urbanas>> getByAreaRange(
            @RequestParam float minArea,
            @RequestParam float maxArea) {
        return ResponseEntity.ok(zonaService.getByAreaRange(minArea, maxArea));
    }

    // MÉTODO EXISTENTE
    @GetMapping("/sin-planificacion")
    public ResponseEntity<List<Map<String, Object>>> getZonasSinPlanificacion() {
        return ResponseEntity.ok(zonaService.obtenerZonasSinPlanificacion());
    }
}

