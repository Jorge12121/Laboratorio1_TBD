package com.example.bda.Repository;

import com.example.bda.Model.usuarios;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.RowMapper;
import org.springframework.stereotype.Repository;

import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.Optional;

@Repository
public class UsuarioRepository {

    @Autowired
    private JdbcTemplate jdbcTemplate;

    // RowMapper manual para mapear tus campos específicos (snake_case) a la clase
    private final RowMapper<usuarios> usuarioRowMapper = new RowMapper<usuarios>() {
        @Override
        public usuarios mapRow(ResultSet rs, int rowNum) throws SQLException {
            usuarios u = new usuarios();
            // Asumiendo que en la BD la columna se llama id_usuario
            // u.setId_usuario(rs.getInt("id_usuario")); // Si tienes el setter
            u.setNombre(rs.getString("nombre"));
            u.setEmail(rs.getString("email"));
            u.setContrasena_hash(rs.getString("contrasena_hash")); // Tu campo específico
            u.setRol(rs.getString("rol"));
            return u;
        }
    };

    public Optional<usuarios> findByEmail(String email) {
        String sql = "SELECT * FROM usuarios WHERE email = ?";
        try {
            // Ejecutamos SQL nativo
            usuarios usuario = jdbcTemplate.queryForObject(sql, usuarioRowMapper, email);
            return Optional.ofNullable(usuario);
        } catch (Exception e) {
            return Optional.empty();
        }
    }

    public int crearUsuario(usuarios nuevoUsuario) {
        String sql = "INSERT INTO usuarios (nombre, email, contrasena_hash, rol) VALUES (?, ?, ?, ?)";
        return jdbcTemplate.update(sql,
                nuevoUsuario.getNombre(),
                nuevoUsuario.getEmail(),
                nuevoUsuario.getContrasena_hash(),
                nuevoUsuario.getRol()
        );
    }
}