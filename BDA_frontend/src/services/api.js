import axios from 'axios';

// Definimos la URL base general del Backend
const API_URL = import.meta.env.VITE_API_URL || 'http://localhost:8080';

const api = axios.create({ //Api creada usa axios
  baseURL: API_URL,
});

// Interceptor: Pega el token automáticamente en cada petición
api.interceptors.request.use((config) => {
  const token = localStorage.getItem('token');
  if (token) {
    config.headers.Authorization = `Bearer ${token}`;
  }
  return config;
});

// Interceptor: Si recibimos un 401, redirigimos al login
// Para 403, dejamos que el componente maneje el error
api.interceptors.response.use(
  (res) => res,
  (err) => {
    if (err?.response?.status === 401) {
      console.error('Token inválido o expirado. Redirigiendo al login...');
      localStorage.removeItem('token');
      localStorage.removeItem('userName');
      window.location.href = '/login';
    }
    // 403 puede ser por permisos, no necesariamente token inválido
    return Promise.reject(err);
  }
)

export const registerUser = async (usuario) => {
    // El backend espera: { nombre, email, contrasena_hash, rol }
    const response = await axios.post(`${API_URL}/api/usuarios/registro`, usuario);
    return response.data;
}

export default api;