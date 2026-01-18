package com.example.demo.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class ProyectoSuperpuestoDTO {
    private Long proyectoA;
    private Long proyectoB;
    private String nombreA;
    private String nombreB;
    private BigDecimal areaConflictoM2;
}
