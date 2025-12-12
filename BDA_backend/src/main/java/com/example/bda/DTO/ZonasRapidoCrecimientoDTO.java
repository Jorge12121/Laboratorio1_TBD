package com.example.bda.DTO;

public class ZonasRapidoCrecimientoDTO {

    // Zonas_urbanas
    private String nombre;

    //Porcentaje crecimiento
    private float crecimiento;

    public ZonasRapidoCrecimientoDTO() {}

    public ZonasRapidoCrecimientoDTO(String nombre, float crecimiento) {
        this.nombre = nombre;
        this.crecimiento = crecimiento;
    }

    public String getNombre() {
        return nombre;
    }

    public void setNombre(String nombre) {
        this.nombre = nombre;
    }

    public float getCrecimiento() {
        return crecimiento;
    }

    public void setCrecimiento(float crecimiento) {
        this.crecimiento = crecimiento;
    }
}
