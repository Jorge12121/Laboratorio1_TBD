import api from './api'

// URLs específicas para este recurso
const API_URL_REPORTES = '/api/reportes'
const API_URL_DATOS_DEMOGRAFICOS = '/api/datos_demograficos'
const API_URL_PROYECTOS = '/api/proyectos'

class ReporteService {
  // Consulta 1
  obtenerDensidad() {
    return api.get(`${API_URL_REPORTES}/densidad`)
  }

  // Consulta 2
  obtenerEscasez() {
    return api.get(`${API_URL_REPORTES}/escasez`)
  }

  // Consulta 3
  obtenerEscuelas() {
    return api.get(`${API_URL_REPORTES}/escuelas`)
  }

  // Consulta 4
  obtenerCrecimiento() {
    return api.get(`${API_URL_REPORTES}/crecimiento`)
  }

  // Consulta 5
  obtenerCobertura() {
    return api.get(`${API_URL_REPORTES}/cobertura`)
  }

  // Consulta 6
  simularCrecimiento(idZona, nuevasViviendas) {
    const idZ = encodeURIComponent(idZona)
    const viviendas = encodeURIComponent(nuevasViviendas)

    return api.patch(
      `${API_URL_DATOS_DEMOGRAFICOS}/simular_crecimiento/id_zona/${idZ}/casas/${viviendas}`
    )
  }

  // Consulta 7
  actualizarRetrasados(idUsuario) {
    const idU = encodeURIComponent(idUsuario)

    return api.patch(
      `${API_URL_PROYECTOS}/retrasos/id_usuario/${idU}`
    )
  }

  // Consulta 8
  obtenerZonasSinPlan() {
    return api.get(`${API_URL_REPORTES}/zonas-sin-planificacion`)
  }

  // Consulta 9
  obtenerSuperposicion() {
    return api.get(`${API_URL_REPORTES}/superposicion-proyectos`)
  }

  // Consulta 10
  obtenerResumenProyectos() {
    return api.get(`${API_URL_REPORTES}/resumen-proyectos`)
  }
  
}

export default new ReporteService()
