package com.example.demo.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class EscuelaCercanaDTO {
    private Long idProyecto;
    private String nombreProyecto;
    private Long idEscuela;
    private String nombreEscuela;
    private BigDecimal distanciaM;
}
