import api from './api'; // Importamos nuestra instancia configurada

// URL específica para este recurso (siguiendo tu ejemplo)
// Nota: Como 'api' ya tiene la base 'http://localhost:8080', aquí solo ponemos la ruta relativa.
const RESOURCE_URL = '/api/proyectos';

class ProyectoService {
  
  obtenerTodos() {
    // Usamos 'api' en vez de 'axios' para que viaje el Token
    return api.get(RESOURCE_URL);
  }

  // Puedes agregar más métodos siguiendo la misma lógica
  crear(datos) {
    return api.post(RESOURCE_URL, datos);
  }
}

export default new ProyectoService();