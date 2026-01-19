package com.example.bda.Controller;

import com.example.bda.Model.puntos_interes;
import com.example.bda.Services.PuntoInteresService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.List;
import java.util.Map;

@CrossOrigin(origins = "*")
@RestController
@RequestMapping("/api/puntos-interes")
public class PuntoInteresController {

    @Autowired
    private PuntoInteresService service;

    // CREATE
    @PostMapping
    public ResponseEntity<puntos_interes> create(@RequestBody puntos_interes punto) {
        puntos_interes created = service.create(punto);
        return ResponseEntity.status(HttpStatus.CREATED).body(created);
    }

    // READ - Obtener todos
    @GetMapping
    public ResponseEntity<List<puntos_interes>> getAll() {
        return ResponseEntity.ok(service.getAll());
    }

    // READ - Obtener con paginación
    @GetMapping("/paginated")
    public ResponseEntity<Map<String, Object>> getAllPaginated(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "10") int size) {
        return ResponseEntity.ok(service.getAllPaginated(page, size));
    }

    // READ - Obtener por ID
    @GetMapping("/{id}")
    public ResponseEntity<puntos_interes> getById(@PathVariable int id) {
        puntos_interes punto = service.getById(id);
        return punto != null ? ResponseEntity.ok(punto) : ResponseEntity.notFound().build();
    }

    // UPDATE
    @PutMapping("/{id}")
    public ResponseEntity<puntos_interes> update(@PathVariable int id, @RequestBody puntos_interes punto) {
        puntos_interes updated = service.update(id, punto);
        return updated != null ? ResponseEntity.ok(updated) : ResponseEntity.notFound().build();
    }

    // DELETE
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> delete(@PathVariable int id) {
        return service.delete(id) ? ResponseEntity.noContent().build() : ResponseEntity.notFound().build();
    }

    // QUERIES SIMPLES
    @GetMapping("/tipo/{tipo}")
    public ResponseEntity<List<puntos_interes>> getByTipo(@PathVariable String tipo) {
        return ResponseEntity.ok(service.getByTipo(tipo));
    }

    @GetMapping("/zona/{idZona}")
    public ResponseEntity<List<puntos_interes>> getByZona(@PathVariable int idZona) {
        return ResponseEntity.ok(service.getByZona(idZona));
    }

    @GetMapping("/nombre")
    public ResponseEntity<List<puntos_interes>> getByNombre(@RequestParam String nombre) {
        return ResponseEntity.ok(service.getByNombre(nombre));
    }

    @GetMapping("/cercanos")
    public ResponseEntity<List<puntos_interes>> getNearby(
            @RequestParam double latitud,
            @RequestParam double longitud,
            @RequestParam(defaultValue = "5.0") double radioKm) {
        return ResponseEntity.ok(service.getNearby(latitud, longitud, radioKm));
    }
}
