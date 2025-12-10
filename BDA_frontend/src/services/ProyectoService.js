import axios from 'axios';

const API_URL = 'http://localhost:8090/api/proyectos';

class ProyectoService {
  obtenerTodos() {
    return axios.get(API_URL);
  }
}

export default new ProyectoService();