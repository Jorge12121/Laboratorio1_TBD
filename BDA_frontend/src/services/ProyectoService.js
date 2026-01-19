import api from './api'; // Importamos nuestra instancia configurada

// URL específica para este recurso (siguiendo tu ejemplo)
// Nota: Como 'api' ya tiene la base 'http://localhost:8080', aquí solo ponemos la ruta relativa.
const RESOURCE_URL = '/api/proyectos';

class ProyectoService {
  
  // CRUD básico
  obtenerTodos() {
    // Usamos 'api' en vez de 'axios' para que viaje el Token
    return api.get(RESOURCE_URL);
  }

  obtenerTodosAsMap() {
    // Obtener proyectos como Map (método antiguo para compatibilidad)
    return api.get(`${RESOURCE_URL}/map`);
  }

  obtenerPaginado(page = 0, size = 10) {
    return api.get(`${RESOURCE_URL}/paginated`, { params: { page, size } });
  }

  obtenerPorId(id) {
    return api.get(`${RESOURCE_URL}/${id}`);
  }

  crear(datos) {
    return api.post(RESOURCE_URL, datos);
  }

  actualizar(id, datos) {
    return api.put(`${RESOURCE_URL}/${id}`, datos);
  }

  eliminar(id) {
    return api.delete(`${RESOURCE_URL}/${id}`);
  }

  // Queries simples
  obtenerPorEstado(estado) {
    return api.get(`${RESOURCE_URL}/estado/${estado}`);
  }

  obtenerPorZona(idZona) {
    return api.get(`${RESOURCE_URL}/zona/${idZona}`);
  }

  obtenerPorUsuario(idUsuario) {
    return api.get(`${RESOURCE_URL}/usuario/${idUsuario}`);
  }

  obtenerPorNombre(nombre) {
    return api.get(`${RESOURCE_URL}/nombre`, { params: { nombre } });
  }

  // Método existente
  actualizarEstadoProyecto(idUsuario) {
    return api.patch(`${RESOURCE_URL}/retrasos/id_usuario/${idUsuario}`);
  }
}

export default new ProyectoService();