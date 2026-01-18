package com.example.demo.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class CoberturaServicioDTO {
    private Long idZona;
    private String nombreZona;
    private BigDecimal areaZonaM2;
    private BigDecimal areaCubiertaM2;
    private BigDecimal porcentajeCobertura;
}
