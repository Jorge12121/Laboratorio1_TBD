package com.example.bda.Model;

import java.util.List;

public class zonas_urbanas {

    private int id_zona;
    private String nombre;
    private String tipo_zona;
    private String coordenadas;
    private float area_km2;
    private List<double[]> poligono; // [[lat, lng], [lat, lng], ...]
    private Double latitud;  // Centro del círculo
    private Double longitud; // Centro del círculo
    private Double radio;    // Radio en km
    private String geom;     // Geometría WKT desde PostGIS

    public String getGeom() {
        return geom;
    }

    public void setGeom(String geom) {
        this.geom = geom;
    }

    public int getId_zona() {
        return id_zona;
    }

    public void setId_zona(int id_zona) {
        this.id_zona = id_zona;
    }

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

    public List<double[]> getPoligono() {
        return poligono;
    }

    public void setPoligono(List<double[]> poligono) {
        this.poligono = poligono;
    }

    public Double getLatitud() {
        return latitud;
    }

    public void setLatitud(Double latitud) {
        this.latitud = latitud;
    }

    public Double getLongitud() {
        return longitud;
    }

    public void setLongitud(Double longitud) {
        this.longitud = longitud;
    }

    public Double getRadio() {
        return radio;
    }

    public void setRadio(Double radio) {
        this.radio = radio;
    }
}
