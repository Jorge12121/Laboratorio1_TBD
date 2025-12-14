import api from './api'; // Importamos nuestra instancia configurada

// URLs
const API_URL_REPORTES = '/api/reportes';

class UtilService {
    // Actualiza los resumenes de proyectos
    actualizarResumenProyectos() {
        return api.post(`${API_URL_REPORTES}/refrescar-resumen`);
    }
}

export default new UtilService();
