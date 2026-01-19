package com.example.bda.Controller;

import com.example.bda.Model.datos_demograficos;
import com.example.bda.Services.DatosDemograficosService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.List;
import java.util.Map;

@CrossOrigin(origins = "*") // Importante para evitar CORS
@RestController
@RequestMapping("/api/datos_demograficos")
public class DatosDemograficosController {

    @Autowired
    private DatosDemograficosService datosDemograficosService;

    // CREATE
    @PostMapping
    public ResponseEntity<datos_demograficos> create(@RequestBody datos_demograficos dato) {
        datos_demograficos created = datosDemograficosService.create(dato);
        return ResponseEntity.status(HttpStatus.CREATED).body(created);
    }

    // READ - Obtener todos
    @GetMapping
    public ResponseEntity<List<datos_demograficos>> getAll() {
        return ResponseEntity.ok(datosDemograficosService.getAll());
    }

    // READ - Obtener con paginación
    @GetMapping("/paginated")
    public ResponseEntity<Map<String, Object>> getAllPaginated(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "10") int size) {
        return ResponseEntity.ok(datosDemograficosService.getAllPaginated(page, size));
    }

    // READ - Obtener por ID
    @GetMapping("/{id}")
    public ResponseEntity<datos_demograficos> getById(@PathVariable int id) {
        datos_demograficos dato = datosDemograficosService.getById(id);
        return dato != null ? ResponseEntity.ok(dato) : ResponseEntity.notFound().build();
    }

    // UPDATE
    @PutMapping("/{id}")
    public ResponseEntity<datos_demograficos> update(@PathVariable int id, @RequestBody datos_demograficos dato) {
        datos_demograficos updated = datosDemograficosService.update(id, dato);
        return updated != null ? ResponseEntity.ok(updated) : ResponseEntity.notFound().build();
    }

    // DELETE
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> delete(@PathVariable int id) {
        return datosDemograficosService.delete(id) ? ResponseEntity.noContent().build() : ResponseEntity.notFound().build();
    }

    // QUERIES SIMPLES
    @GetMapping("/zona/{idZona}")
    public ResponseEntity<List<datos_demograficos>> getByZona(@PathVariable int idZona) {
        return ResponseEntity.ok(datosDemograficosService.getByZona(idZona));
    }

    @GetMapping("/anio/{anio}")
    public ResponseEntity<List<datos_demograficos>> getByAnio(@PathVariable int anio) {
        return ResponseEntity.ok(datosDemograficosService.getByAnio(anio));
    }

    @GetMapping("/poblacion")
    public ResponseEntity<List<datos_demograficos>> getByPoblacionRange(
            @RequestParam int min,
            @RequestParam int max) {
        return ResponseEntity.ok(datosDemograficosService.getByPoblacionRange(min, max));
    }

    // MÉTODO EXISTENTE
    @PatchMapping("/simular_crecimiento/id_zona/{id_zona}/casas/{casas}")
    public void simularCrecimiento(@PathVariable int id_zona, @PathVariable int casas) {
        datosDemograficosService.simularCrecimiento(id_zona, casas);
    }
}
