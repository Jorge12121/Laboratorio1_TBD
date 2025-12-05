package com.example.bda.Model;

public class usuarios {

    private String nombre;
    private String email;
    private String contrasena_hash;
    private String rol;

    public String getNombre() {
        return nombre;
    }

    public void setNombre(String nombre) {
        this.nombre = nombre;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getContrasena_hash() {
        return contrasena_hash;
    }

    public void setContrasena_hash(String contrasena_hash) {
        this.contrasena_hash = contrasena_hash;
    }

    public String getRol() {
        return rol;
    }

    public void setRol(String rol) {
        this.rol = rol;
    }
}
