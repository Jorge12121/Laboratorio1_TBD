import axios from 'axios';

const API_URL = 'http://localhost:8090/api/reportes';

class ReporteService {
  obtenerDensidad() {
    return axios.get(`${API_URL}/densidad`);
  }

  
  obtenerEscasez() {
    return axios.get(`${API_URL}/escasez`); 
  }
}

export default new ReporteService();