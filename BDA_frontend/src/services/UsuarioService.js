import api from './api';

const RESOURCE_URL = '/api/usuarios';

class UsuarioService {
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

  create(usuario) {
    return api.post(RESOURCE_URL, usuario);
  }

  update(id, usuario) {
    return api.put(`${RESOURCE_URL}/${id}`, usuario);
  }

  delete(id) {
    return api.delete(`${RESOURCE_URL}/${id}`);
  }

  // Queries simples
  getByRol(rol) {
    return api.get(`${RESOURCE_URL}/rol/${rol}`);
  }

  getByNombre(nombre) {
    return api.get(`${RESOURCE_URL}/nombre`, { params: { nombre } });
  }

  // Método existente de registro
  registrar(usuario) {
    return api.post(`${RESOURCE_URL}/registro`, usuario);
  }

  // Alias en español
  obtenerPaginado(page, size) {
    return this.getAllPaginated(page, size);
  }

  crear(usuario) {
    return this.create(usuario);
  }

  actualizar(id, usuario) {
    return this.update(id, usuario);
  }

  eliminar(id) {
    return this.delete(id);
  }
}

export default new UsuarioService();
