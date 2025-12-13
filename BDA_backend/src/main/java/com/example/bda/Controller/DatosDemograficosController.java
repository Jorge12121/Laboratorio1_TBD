package com.example.bda.Controller;

import com.example.bda.Services.DatosDemograficosService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

@CrossOrigin(origins = "*") // Importante para evitar CORS
@RestController
@RequestMapping("/api/datos_demograficos")
public class DatosDemograficosController {

    @Autowired
    private DatosDemograficosService datosDemograficosService;

    @PatchMapping("/simular_crecimiento/id_zona/{id_zona}/casas/{casas}")
    public void simularCrecimiento(@PathVariable int id_zona, @PathVariable int casas) {
        datosDemograficosService.simularCrecimiento(id_zona, casas);
    }
}
