package com.example.bda.Services;

import com.example.bda.Model.usuarios;
import com.example.bda.Repository.UsuarioRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

@Service
public class UsuarioService {

    @Autowired
    private UsuarioRepository usuarioRepository;

    @Autowired
    private PasswordEncoder passwordEncoder;

    public String registrarNuevoUsuario(usuarios nuevoUsuario) {
        // Validar si existe
        if (usuarioRepository.findByEmail(nuevoUsuario.getEmail()).isPresent()) {
            throw new RuntimeException("El email ya está registrado");
        }

        // Encriptar contraseña
        String hash = passwordEncoder.encode(nuevoUsuario.getContrasena_hash());
        nuevoUsuario.setContrasena_hash(hash);

        // Asignar rol por defecto
        if (nuevoUsuario.getRol() == null || nuevoUsuario.getRol().isEmpty()) {
            nuevoUsuario.setRol("planificador");
        }

        // Llamar al repositorio
        usuarioRepository.crearUsuario(nuevoUsuario);

        return "Usuario registrado con éxito";
    }
}