package com.example.bda.Security;

import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.web.authentication.WebAuthenticationDetailsSource;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;

import java.io.IOException;

@Component
public class JwtFilter extends OncePerRequestFilter {

    @Autowired
    private JwtUtil jwtUtil;

    @Autowired
    private UserDetailsService userDetailsService;

    @Override
    protected void doFilterInternal(HttpServletRequest request, HttpServletResponse response, FilterChain filterChain)
            throws ServletException, IOException {

        String authHeader = request.getHeader("Authorization");
        String requestURI = request.getRequestURI();
        
        System.out.println("=== JWT Filter ===");
        System.out.println("Request URI: " + requestURI);
        System.out.println("Authorization Header: " + (authHeader != null ? "presente" : "ausente"));

        if (authHeader != null && authHeader.startsWith("Bearer ")) {
            String token = authHeader.substring(7);
            System.out.println("Token extraído (primeros 20 chars): " + token.substring(0, Math.min(20, token.length())) + "...");
            
            try {
                String email = jwtUtil.validateTokenAndGetEmail(token);
                System.out.println("Token válido para usuario: " + email);

                if (email != null && SecurityContextHolder.getContext().getAuthentication() == null) {
                    UserDetails userDetails = userDetailsService.loadUserByUsername(email);

                    UsernamePasswordAuthenticationToken authToken =
                            new UsernamePasswordAuthenticationToken(userDetails, null, userDetails.getAuthorities());

                    authToken.setDetails(new WebAuthenticationDetailsSource().buildDetails(request));
                    SecurityContextHolder.getContext().setAuthentication(authToken);
                    System.out.println("Autenticación establecida exitosamente");
                }
            } catch (Exception e) {
                // Token inválido, no autenticamos
                System.err.println("❌ ERROR validando token: " + e.getClass().getSimpleName() + " - " + e.getMessage());
                e.printStackTrace();
            }
        } else {
            System.out.println("No hay token Bearer en la petición");
        }
        
        System.out.println("Authentication: " + (SecurityContextHolder.getContext().getAuthentication() != null ? "presente" : "null"));
        System.out.println("==================");
        
        filterChain.doFilter(request, response);
    }
}