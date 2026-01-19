import api from './api';

const RESOURCE_URL = '/api/zona';

class ZonaService {
  // CRUD básico
  getAll() {
    return api.get(RESOURCE_URL);
  }

  getAllPaginated(page = 0, size = 10) {
    return api.get(`${RESOURCE_URL}/paginated`, { params: { page, size } });
  }

  getById(id) {
    return api.get(`${RESOURCE_URL}/${id}`);
  }

  create(zona) {
    return api.post(RESOURCE_URL, zona);
  }

  update(id, zona) {
    return api.put(`${RESOURCE_URL}/${id}`, zona);
  }

  delete(id) {
    return api.delete(`${RESOURCE_URL}/${id}`);
  }

  // Queries simples
  getByTipo(tipoZona) {
    return api.get(`${RESOURCE_URL}/tipo/${tipoZona}`);
  }

  getByNombre(nombre) {
    return api.get(`${RESOURCE_URL}/nombre`, { params: { nombre } });
  }

  getByAreaRange(minArea, maxArea) {
    return api.get(`${RESOURCE_URL}/area`, { params: { minArea, maxArea } });
  }

  // Método existente
  getSinPlanificacion() {
    return api.get(`${RESOURCE_URL}/sin-planificacion`);
  }

  // Alias en español
  obtenerTodos() {
    return this.getAll();
  }

  obtenerPaginado(page, size) {
    return this.getAllPaginated(page, size);
  }

  obtenerPorId(id) {
    return this.getById(id);
  }

  crear(zona) {
    return this.create(zona);
  }

  actualizar(id, zona) {
    return this.update(id, zona);
  }

  eliminar(id) {
    return this.delete(id);
  }
}

export default new ZonaService();
