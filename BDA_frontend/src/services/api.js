import axios from 'axios';

// Definimos la URL base general del Backend
const API_URL = import.meta.env.VITE_API_URL || 'http://localhost:8090';

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
api.interceptors.response.use(
  (res) => res,
  (err) => {
    if (err?.response?.status === 401) {
      localStorage.removeItem('token')
      window.location.href = '/login'
    }
    return Promise.reject(err)
  }
)

export default api;