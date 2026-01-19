package com.example.bda.Services;

import com.example.bda.Model.usuarios;
import com.example.bda.Repository.UsuarioRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Service
public class UsuarioService {

    @Autowired
    private UsuarioRepository usuarioRepository;

    @Autowired
    private PasswordEncoder passwordEncoder;

    // CREATE
    public usuarios create(usuarios usuario) {
        // Validar si existe
        if (usuarioRepository.findByEmail(usuario.getEmail()).isPresent()) {
            throw new RuntimeException("El email ya está registrado");
        }
        
        // Encriptar contraseña antes de guardar
        usuario.setContrasena_hash(passwordEncoder.encode(usuario.getContrasena_hash()));
        
        // Asignar rol por defecto si no se especifica
        if (usuario.getRol() == null || usuario.getRol().isEmpty()) {
            usuario.setRol("planificador");
        }
        
        int id = usuarioRepository.create(usuario);
        usuario.setId_usuario(id);
        return usuario;
    }

    // READ - Obtener todos
    public List<usuarios> getAll() {
        return usuarioRepository.findAll();
    }

    // READ - Obtener con paginación
    public Map<String, Object> getAllPaginated(int page, int size) {
        List<usuarios> usuarios = usuarioRepository.findAllPaginated(page, size);
        int total = usuarioRepository.count();
        
        Map<String, Object> response = new HashMap<>();
        response.put("usuarios", usuarios);
        response.put("currentPage", page);
        response.put("totalItems", total);
        response.put("totalPages", (int) Math.ceil((double) total / size));
        return response;
    }

    // READ - Obtener por ID
    public usuarios getById(int id) {
        return usuarioRepository.findById(id);
    }

    // UPDATE
    public usuarios update(int id, usuarios usuario) {
        // Si se proporciona una nueva contraseña, encriptarla
        if (usuario.getContrasena_hash() != null && !usuario.getContrasena_hash().isEmpty()) {
            usuario.setContrasena_hash(passwordEncoder.encode(usuario.getContrasena_hash()));
        } else {
            // Mantener la contraseña actual
            usuarios usuarioActual = usuarioRepository.findById(id);
            if (usuarioActual != null) {
                usuario.setContrasena_hash(usuarioActual.getContrasena_hash());
            }
        }
        
        int rowsAffected = usuarioRepository.update(id, usuario);
        if (rowsAffected > 0) {
            usuario.setId_usuario(id);
            return usuario;
        }
        return null;
    }

    // DELETE
    public boolean delete(int id) {
        return usuarioRepository.delete(id) > 0;
    }

    // QUERIES SIMPLES
    public List<usuarios> getByRol(String rol) {
        return usuarioRepository.findByRol(rol);
    }

    public List<usuarios> getByNombre(String nombre) {
        return usuarioRepository.findByNombre(nombre);
    }

    // MÉTODO EXISTENTE PARA AUTENTICACIÓN/REGISTRO
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