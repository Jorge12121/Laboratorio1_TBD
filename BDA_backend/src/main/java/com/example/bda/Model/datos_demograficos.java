package com.example.bda.Model;

public class datos_demograficos {

    private int id_zona;
    private int anio;
    private int poblacion;
    private float densidad;
    private float edad_promedio;

    public int getId_zona() {
        return id_zona;
    }

    public void setId_zona(int id_zona) {
        this.id_zona = id_zona;
    }

    public int getAnio() {
        return anio;
    }

    public void setAnio(int anio) {
        this.anio = anio;
    }

    public int getPoblacion() {
        return poblacion;
    }

    public void setPoblacion(int poblacion) {
        this.poblacion = poblacion;
    }

    public float getDensidad() {
        return densidad;
    }

    public void setDensidad(float densidad) {
        this.densidad = densidad;
    }

    public float getEdad_promedio() {
        return edad_promedio;
    }

    public void setEdad_promedio(float edad_promedio) {
        this.edad_promedio = edad_promedio;
    }
}
