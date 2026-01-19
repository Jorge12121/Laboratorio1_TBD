import api from './api';

const RESOURCE_URL = '/api/puntos-interes';

class PuntoInteresService {
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

  create(punto) {
    return api.post(RESOURCE_URL, punto);
  }

  update(id, punto) {
    return api.put(`${RESOURCE_URL}/${id}`, punto);
  }

  delete(id) {
    return api.delete(`${RESOURCE_URL}/${id}`);
  }

  // Queries simples
  getByTipo(tipo) {
    return api.get(`${RESOURCE_URL}/tipo/${tipo}`);
  }

  getByZona(idZona) {
    return api.get(`${RESOURCE_URL}/zona/${idZona}`);
  }

  getByNombre(nombre) {
    return api.get(`${RESOURCE_URL}/nombre`, { params: { nombre } });
  }

  getNearby(latitud, longitud, radioKm = 5.0) {
    return api.get(`${RESOURCE_URL}/cercanos`, { params: { latitud, longitud, radioKm } });
  }

  // Alias en español
  obtenerPaginado(page, size) {
    return this.getAllPaginated(page, size);
  }

  crear(punto) {
    return this.create(punto);
  }

  actualizar(id, punto) {
    return this.update(id, punto);
  }

  eliminar(id) {
    return this.delete(id);
  }
}

export default new PuntoInteresService();
