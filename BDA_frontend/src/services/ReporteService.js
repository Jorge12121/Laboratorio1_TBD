import api from './api'; // Importamos nuestra instancia de api para traer el Token JWT

//Como 'api' ya tiene la base 'http://localhost:8090', aquí solo ponemos la ruta relativa.
const API_URL = '/api/reportes';

class ReporteService {
  obtenerDensidad() {
    return api.get(`${API_URL}/densidad`);
  }

  
  obtenerEscasez() {
    return api.get(`${API_URL}/escasez`); 
  }
}

export default new ReporteService();