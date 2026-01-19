import api from './api';

const RESOURCE_URL = '/api/datos_demograficos';

class DatosDemograficosService {
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

  create(dato) {
    return api.post(RESOURCE_URL, dato);
  }

  update(id, dato) {
    return api.put(`${RESOURCE_URL}/${id}`, dato);
  }

  delete(id) {
    return api.delete(`${RESOURCE_URL}/${id}`);
  }

  // Queries simples
  getByZona(idZona) {
    return api.get(`${RESOURCE_URL}/zona/${idZona}`);
  }

  getByAnio(anio) {
    return api.get(`${RESOURCE_URL}/anio/${anio}`);
  }

  getByPoblacionRange(min, max) {
    return api.get(`${RESOURCE_URL}/poblacion`, { params: { min, max } });
  }

  // Método existente
  simularCrecimiento(idZona, casas) {
    return api.patch(`${RESOURCE_URL}/simular_crecimiento/id_zona/${idZona}/casas/${casas}`);
  }
}

export default new DatosDemograficosService();
