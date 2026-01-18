package com.example.bda.DTO;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class DensidadRealDTO {
    private Long idZona;
    private String nombreZona;
    private Integer anio;
    private Integer poblacion;
    private BigDecimal areaRealKm2;
    private BigDecimal densidadRealHabKm2;
}
