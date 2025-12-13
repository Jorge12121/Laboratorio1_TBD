import api from './api'

const API_URL = '/api/reportes'

class ReporteService {
  // Consulta 1
  obtenerDensidad() {
    return api.get(`${API_URL}/densidad`)
  }

  // Consulta 2
  obtenerEscasez() {
    return api.get(`${API_URL}/escasez`)
  }

  // Consulta 3
  obtenerEscuelas() {
    return api.get(`${API_URL}/escuelas`)
  }

  // Consulta 4
  obtenerCrecimiento() {
    return api.get(`${API_URL}/crecimiento`)
  }
}

export default new ReporteService()
