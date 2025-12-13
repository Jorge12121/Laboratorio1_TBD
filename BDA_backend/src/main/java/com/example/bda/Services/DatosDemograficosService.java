package com.example.bda.Services;

import com.example.bda.Repository.DatosDemograficosRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

@Service
public class DatosDemograficosService {

    @Autowired
    private DatosDemograficosRepository datosDemograficosRepository;

    public void simularCrecimiento(int id_zona, int casas){
        datosDemograficosRepository.simularCrecimiento(id_zona, casas);
    }
}
