package com.example.bda.DTO;

public class CercaProyectoUrbanoDTO {
    //Puntos_interes
    private String nombreEscuela;

    //Proyectos_urbanos
    private String nombreProyecto;

    //La diferencia entre punto interes y proyecto urbano
    private double distancia;

    public CercaProyectoUrbanoDTO() {}

    public CercaProyectoUrbanoDTO(String nombreEscuela, String nombreProyecto, double distancia) {
        this.nombreEscuela = nombreEscuela;
        this.nombreProyecto = nombreProyecto;
        this.distancia = distancia;
    }

    public String getNombreEscuela() {
        return nombreEscuela;
    }

    public void setNombreEscuela(String nombreEscuela) {
        this.nombreEscuela = nombreEscuela;
    }

    public String getNombreProyecto() {
        return nombreProyecto;
    }

    public void setNombreProyecto(String nombreProyecto) {
        this.nombreProyecto = nombreProyecto;
    }

    public double getDistancia() {
        return distancia;
    }

    public void setDistancia(double distancia) {
        this.distancia = distancia;
    }
}
