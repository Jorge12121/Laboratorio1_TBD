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
        // 1. Lógica: Validar si existe
        if (usuarioRepository.findByEmail(nuevoUsuario.getEmail()).isPresent()) {
            throw new RuntimeException("El email ya está registrado");
        }

        // 2. Lógica: Encriptar contraseña
        String hash = passwordEncoder.encode(nuevoUsuario.getContrasena_hash());
        nuevoUsuario.setContrasena_hash(hash);

        // 3. Lógica: Asignar rol por defecto
        if (nuevoUsuario.getRol() == null || nuevoUsuario.getRol().isEmpty()) {
            nuevoUsuario.setRol("planificador");
        }

        // 4. Persistencia: Llamar al repositorio
        usuarioRepository.crearUsuario(nuevoUsuario);

        return "Usuario registrado con éxito";
    }
}