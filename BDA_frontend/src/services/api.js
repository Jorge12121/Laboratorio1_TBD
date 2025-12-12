import axios from 'axios';

// Definimos la URL base general del Backend
const API_URL = 'http://localhost:8090';

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

export default api;