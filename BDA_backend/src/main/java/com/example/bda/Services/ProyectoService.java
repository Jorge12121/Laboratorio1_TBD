package com.example.bda.Services;

import com.example.bda.Repository.ProyectoRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import java.util.List;
import java.util.Map;

@Service
public class ProyectoService {

    @Autowired
    private ProyectoRepository proyectoRepository;

    public List<Map<String, Object>> getAllProyectos() {
        return proyectoRepository.findAll();
    }
}
