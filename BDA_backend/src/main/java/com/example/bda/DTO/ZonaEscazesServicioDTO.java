package com.example.bda.DTO;

public class ZonaEscazesServicioDTO {
    //Para devolver esta clase en 2
    private String nombreZona;

    //De datos_demograficos
    private int poblacion;

    //Conteo de puntos_interes
    private int hospitales;

    //DTO vacio porque no funciona sin esto
    public ZonaEscazesServicioDTO() {}

    public ZonaEscazesServicioDTO(String nombreZona, int poblacion, int hospitales) {
        this.nombreZona = nombreZona;
        this.poblacion = poblacion;
        this.hospitales = hospitales;
    }

    public String getNombreZona() {
        return nombreZona;
    }

    public void setNombreZona(String nombreZona) {
        this.nombreZona = nombreZona;
    }

    public int getPoblacion() {
        return poblacion;
    }

    public void setPoblacion(int poblacion) {
        this.poblacion = poblacion;
    }

    public int getHospitales() {
        return hospitales;
    }

    public void setHospitales(int hospitales) {
        this.hospitales = hospitales;
    }
}
