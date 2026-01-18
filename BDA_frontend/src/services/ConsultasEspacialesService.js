import api from './api'

// URLs específicas para consultas espaciales
const API_URL = '/api/consultas-espaciales'

class ConsultasEspacialesService {
  // ============================================================
  // 1. CÁLCULO DE DENSIDAD REAL
  // ============================================================
  
  obtenerDensidadReal() {
    return api.get(`${API_URL}/densidad-real`)
  }

  obtenerDensidadRealPorZona(idZona) {
    return api.get(`${API_URL}/densidad-real/${idZona}`)
  }

  // ============================================================
  // 2. ANÁLISIS DE PROXIMIDAD (ESCUELAS)
  // ============================================================
  
  obtenerEscuelasCercanas() {
    return api.get(`${API_URL}/escuelas-cercanas`)
  }

  obtenerEscuelasCercanasPorProyecto(idProyecto) {
    return api.get(`${API_URL}/escuelas-cercanas/proyecto/${idProyecto}`)
  }

  // ============================================================
  // 3. SUPERPOSICIÓN DE PROYECTOS
  // ============================================================
  
  obtenerProyectosSuperpuestos() {
    return api.get(`${API_URL}/proyectos-superpuestos`)
  }

  obtenerProyectosSuperpuestosPorId(idProyecto) {
    return api.get(`${API_URL}/proyectos-superpuestos/${idProyecto}`)
  }

  // ============================================================
  // 4. COBERTURA DE SERVICIOS (HOSPITALES)
  // ============================================================
  
  obtenerCoberturaServicios() {
    return api.get(`${API_URL}/cobertura-servicios`)
  }

  obtenerCoberturaServiciosPorZona(idZona) {
    return api.get(`${API_URL}/cobertura-servicios/${idZona}`)
  }
}

export default new ConsultasEspacialesService()
