package com.example.bda.Model;

public class zonas_urbanas {

    private int id_zona;
    private String nombre;
    private String tipo_zona;
    private String coordenadas;
    private float area_km2;

    public String getNombre() {
        return nombre;
    }

    public void setNombre(String nombre) {
        this.nombre = nombre;
    }

    public String getTipo_zona() {
        return tipo_zona;
    }

    public void setTipo_zona(String tipo_zona) {
        this.tipo_zona = tipo_zona;
    }

    public String getCoordenadas() {
        return coordenadas;
    }

    public void setCoordenadas(String coordenadas) {
        this.coordenadas = coordenadas;
    }

    public float getArea_km2() {
        return area_km2;
    }

    public void setArea_km2(float area_km2) {
        this.area_km2 = area_km2;
    }
}
