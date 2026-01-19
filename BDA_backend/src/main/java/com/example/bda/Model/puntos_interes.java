package com.example.bda.Model;

public class puntos_interes {

    private int id_punto;
    private String nombre;
    private String tipo;
    private double latitud;
    private double longitud;
    private Integer id_zona; // Nullable

    public int getId_punto() {
        return id_punto;
    }

    public void setId_punto(int id_punto) {
        this.id_punto = id_punto;
    }

    public String getNombre() {
        return nombre;
    }

    public void setNombre(String nombre) {
        this.nombre = nombre;
    }

    public String getTipo() {
        return tipo;
    }

    public void setTipo(String tipo) {
        this.tipo = tipo;
    }

    public double getLatitud() {
        return latitud;
    }

    public void setLatitud(double latitud) {
        this.latitud = latitud;
    }

    public double getLongitud() {
        return longitud;
    }

    public void setLongitud(double longitud) {
        this.longitud = longitud;
    }

    public Integer getId_zona() {
        return id_zona;
    }

    public void setId_zona(Integer id_zona) {
        this.id_zona = id_zona;
    }
}
