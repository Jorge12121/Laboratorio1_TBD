package com.example.bda.Controller;

import com.example.bda.DTO.LoginRequest;
import com.example.bda.Security.JwtUtil;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.web.bind.annotation.*;

import java.util.Collections;
import java.util.Map;

@RestController
@RequestMapping("/auth")
@CrossOrigin(origins = "http://localhost:5173")
public class AuthController {

    @Autowired
    private AuthenticationManager authenticationManager;

    @Autowired
    private JwtUtil jwtUtil;

    @PostMapping("/login")
    public ResponseEntity<?> login(@RequestBody LoginRequest request) {
        try {
            System.out.println("=== LOGIN ATTEMPT ===");
            System.out.println("Email: " + request.getEmail());
            System.out.println("Password length: " + (request.getPassword() != null ? request.getPassword().length() : "null"));
            
            // Autenticacion usando Spring Security.
            authenticationManager.authenticate(
                    new UsernamePasswordAuthenticationToken(request.getEmail(), request.getPassword())
            );

            System.out.println("✅ Authentication successful");
            
            // Si pasa la línea anterior, las credenciales son correctas y se genera un token
            String token = jwtUtil.generateToken(request.getEmail());
            System.out.println("✅ Token generated");

            return ResponseEntity.ok(Collections.singletonMap("token", token));
            
        } catch (Exception e) {
            System.err.println("❌ LOGIN ERROR: " + e.getClass().getSimpleName());
            System.err.println("Message: " + e.getMessage());
            e.printStackTrace();
            
            return ResponseEntity.status(401)
                    .body(Collections.singletonMap("message", "Credenciales inválidas"));
        }
    }
}