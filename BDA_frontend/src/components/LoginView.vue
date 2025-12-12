<template>
  <div class="login-wrapper">
    <div class="login-card">
      <h2>Acceso Urbanismo</h2>
      <form @submit.prevent="login">
        <input v-model="email" type="email" placeholder="Usuario (email)" required />
        <input v-model="password" type="password" placeholder="Contraseña" required />
        <button type="submit" :disabled="cargando">
          {{ cargando ? 'Ingresando...' : 'Entrar' }}
        </button>
      </form>
      <p v-if="error" class="error">{{ error }}</p>
    </div>
  </div>
</template>

<script setup>
import { ref } from 'vue';
import api from '../services/api'; // Asegúrate de tener el axios configurado aquí

const emit = defineEmits(['login-success']); // Evento para avisar al padre
const email = ref('');
const password = ref('');
const error = ref('');
const cargando = ref(false);

const login = async () => {
  cargando.value = true;
  error.value = '';
  try {
    const response = await api.post('/auth/login', {
      email: email.value,
      password: password.value
    });
    // Guardamos token y emitimos éxito
    localStorage.setItem('token', response.data.token);
    emit('login-success');
  } catch (e) {
    error.value = 'Credenciales inválidas';
  } finally {
    cargando.value = false;
  }
};
</script>

<style scoped>
.login-wrapper { display: flex; height: 100vh; align-items: center; justify-content: center; background: #f0f2f5; }
.login-card { background: white; padding: 2rem; border-radius: 8px; box-shadow: 0 4px 6px rgba(0,0,0,0.1); text-align: center; width: 300px; }
input { display: block; width: 100%; margin-bottom: 10px; padding: 8px; border: 1px solid #ddd; border-radius: 4px; }
button { width: 100%; padding: 10px; background: #2c3e50; color: white; border: none; border-radius: 4px; cursor: pointer; }
button:disabled { background: #ccc; }
.error { color: crimson; font-size: 0.9rem; margin-top: 10px; }
</style>