package com.example.bda.Repository;

import com.example.bda.Model.usuarios;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.RowMapper;
import org.springframework.stereotype.Repository;

import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.List;
import java.util.Optional;

@Repository
public class UsuarioRepository {

    @Autowired
    private JdbcTemplate jdbcTemplate;

    // RowMapper manual para mapear campos específicos (snake_case) a la clase
    private final RowMapper<usuarios> usuarioRowMapper = new RowMapper<usuarios>() {
        @Override
        public usuarios mapRow(ResultSet rs, int rowNum) throws SQLException {
            usuarios u = new usuarios();
            u.setId_usuario(rs.getInt("id"));
            u.setNombre(rs.getString("nombre"));
            u.setEmail(rs.getString("email"));
            u.setContrasena_hash(rs.getString("contrasena_hash"));
            u.setRol(rs.getString("rol"));
            return u;
        }
    };

    // CREATE
    public int create(usuarios usuario) {
        String sql = "INSERT INTO usuarios (nombre, email, contrasena_hash, rol) VALUES (?, ?, ?, ?) RETURNING id";
        return jdbcTemplate.queryForObject(sql, Integer.class,
                usuario.getNombre(),
                usuario.getEmail(),
                usuario.getContrasena_hash(),
                usuario.getRol());
    }

    // READ - Obtener todos
    public List<usuarios> findAll() {
        String sql = "SELECT * FROM usuarios ORDER BY id";
        return jdbcTemplate.query(sql, usuarioRowMapper);
    }

    // READ - Obtener con paginación
    public List<usuarios> findAllPaginated(int page, int size) {
        int offset = page * size;
        String sql = "SELECT * FROM usuarios ORDER BY id LIMIT ? OFFSET ?";
        return jdbcTemplate.query(sql, usuarioRowMapper, size, offset);
    }

    // READ - Contar total
    public int count() {
        String sql = "SELECT COUNT(*) FROM usuarios";
        return jdbcTemplate.queryForObject(sql, Integer.class);
    }

    // READ - Obtener por ID
    public usuarios findById(int id) {
        String sql = "SELECT * FROM usuarios WHERE id = ?";
        List<usuarios> results = jdbcTemplate.query(sql, usuarioRowMapper, id);
        return results.isEmpty() ? null : results.get(0);
    }

    // UPDATE
    public int update(int id, usuarios usuario) {
        String sql = "UPDATE usuarios SET nombre = ?, email = ?, contrasena_hash = ?, rol = ? WHERE id = ?";
        return jdbcTemplate.update(sql, usuario.getNombre(), usuario.getEmail(), 
                usuario.getContrasena_hash(), usuario.getRol(), id);
    }

    // DELETE
    public int delete(int id) {
        String sql = "DELETE FROM usuarios WHERE id = ?";
        return jdbcTemplate.update(sql, id);
    }

    // QUERIES SIMPLES
    // Buscar por rol
    public List<usuarios> findByRol(String rol) {
        String sql = "SELECT * FROM usuarios WHERE rol = ? ORDER BY nombre";
        return jdbcTemplate.query(sql, usuarioRowMapper, rol);
    }

    // Buscar por nombre (búsqueda parcial)
    public List<usuarios> findByNombre(String nombre) {
        String sql = "SELECT * FROM usuarios WHERE nombre ILIKE ? ORDER BY nombre";
        return jdbcTemplate.query(sql, usuarioRowMapper, "%" + nombre + "%");
    }

    // MÉTODOS EXISTENTES PARA AUTENTICACIÓN
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