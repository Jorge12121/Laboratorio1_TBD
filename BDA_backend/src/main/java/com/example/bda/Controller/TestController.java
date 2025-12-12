package com.example.bda.Controller;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

//Clase de prueba para ver si los token están funcionando correctamente.
@RestController
@RequestMapping("/test")
public class TestController {

    @GetMapping("/protegido")
    public String rutaProtegida() {
        return "¡Si ves esto, tu token JWT funciona correctamente!";
    }
}