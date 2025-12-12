package com.example.bda.Services;

import com.example.bda.Model.usuarios;
import com.example.bda.Repository.UsuarioRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.userdetails.User;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.stereotype.Service;

@Service
public class CustomUserDetailsService implements UserDetailsService {

    @Autowired
    private UsuarioRepository usuarioRepository;

    @Override
    public UserDetails loadUserByUsername(String email) throws UsernameNotFoundException {
        // 1. Buscamos el usuario en la BD usando tu repositorio SQL nativo
        usuarios usuario = usuarioRepository.findByEmail(email)
                .orElseThrow(() -> new UsernameNotFoundException("Usuario no encontrado: " + email));

        // 2. Convertimos tu clase 'usuarios' al estándar 'UserDetails' de Spring
        return User.builder()
                .username(usuario.getEmail())
                .password(usuario.getContrasena_hash()) // ASUMÍ este campo basándome en tu modelo
                .roles(usuario.getRol() != null ? usuario.getRol() : "USER")
                .build();
    }
}