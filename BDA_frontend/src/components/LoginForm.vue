<script setup>
import { ref } from 'vue'
import api from '../services/api'

const emit = defineEmits(['login-success'])

const email = ref('')
const password = ref('')
const error = ref('')
const cargando = ref(false)
const mostrarPassword = ref(false)

const login = async () => {
  cargando.value = true
  error.value = ''

  try {
    const response = await api.post('/auth/login', {
      email: email.value,
      password: password.value,
    })

    console.log('LOGIN RESPONSE:', response.data)

    // Guardar token y nombre de usuario en localStorage
    localStorage.setItem('token', response.data.token)
    localStorage.setItem('userName', email.value)

    emit('login-success')
  } catch (e) {
    error.value = e?.response?.data?.message || 'Credenciales inválidas'
  } finally {
    cargando.value = false
  }
}
</script>

<template>
  <div class="login-page">
    <div class="login-card card">
      <div class="header">
        <div class="icon">🏙️</div>
        <div>
          <h2>Acceso Urbanismo</h2>
          <p>Ingresa con tus credenciales para continuar.</p>
        </div>
      </div>

      <form @submit.prevent="login" class="form">
        <label class="label">
          Usuario (email)
          <input v-model="email" class="input" type="email" placeholder="correo@ejemplo.com" required />
        </label>

        <label class="label">
          Contraseña
          <div class="password-wrap">
            <input
              v-model="password"
              class="input input-with-toggle"
              :type="mostrarPassword ? 'text' : 'password'"
              placeholder="••••••••"
              required
            />
            <button
              class="toggle"
              type="button"
              @click="mostrarPassword = !mostrarPassword"
              :aria-label="mostrarPassword ? 'Ocultar contraseña' : 'Mostrar contraseña'"
            >
              <!-- Si está mostrando la contraseña, muestro "ojo tachado" (para ocultar) -->
              <svg
                v-if="mostrarPassword"
                xmlns="http://www.w3.org/2000/svg"
                viewBox="0 0 24 24"
                fill="none"
                stroke="currentColor"
                stroke-width="1.8"
                stroke-linecap="round"
                stroke-linejoin="round"
                class="eye-icon"
              >
                <path d="M17.94 17.94A10.94 10.94 0 0 1 12 20C7 20 2.73 16.89 1 12c.74-2.11 2.06-4 3.76-5.44" />
                <path d="M9.9 4.24A10.94 10.94 0 0 1 12 4c5 0 9.27 3.11 11 8a11.3 11.3 0 0 1-2.16 3.19" />
                <path d="M14.12 14.12a3 3 0 0 1-4.24-4.24" />
                <path d="M1 1l22 22" />
              </svg>

              <!-- Si está oculta, muestro "ojo" (para mostrar) -->
              <svg
                v-else
                xmlns="http://www.w3.org/2000/svg"
                viewBox="0 0 24 24"
                fill="none"
                stroke="currentColor"
                stroke-width="1.8"
                stroke-linecap="round"
                stroke-linejoin="round"
                class="eye-icon"
              >
                <path d="M2 12s3.5-7 10-7 10 7 10 7-3.5 7-10 7-10-7-10-7z" />
                <circle cx="12" cy="12" r="3" />
              </svg>
            </button>
          </div>
        </label>

        <button class="btn primary" type="submit" :disabled="cargando">
          {{ cargando ? 'Ingresando…' : 'Entrar' }}
        </button>

        <div v-if="error" class="alert error">{{ error }}</div>
        <div style="margin-top: 15px; text-align: center;">
          <small>¿No tienes cuenta? 
            <router-link to="/registro" style="color: #42b983; font-weight: bold;">Regístrate aquí</router-link>
          </small>
        </div>
      </form>
    </div>
  </div>
  
</template>



<style scoped>
.login-page{
  min-height: 100vh;
  display: grid;
  place-items: center;
  padding: 24px 16px;
}

.login-card{
  width: 100%;
  max-width: 420px;
}

.header{
  display: flex;
  gap: 12px;
  align-items: center;
  margin-bottom: 14px;
}

.icon{
  width: 44px;
  height: 44px;
  display: grid;
  place-items: center;
  border-radius: 14px;
  background: rgba(66,185,131,.18);
}

h2{
  margin: 0;
  font-size: 18px;
}

p{
  margin: 4px 0 0;
  font-size: 13px;
}

.form{
  display: grid;
  gap: 12px;
}

.label{
  display: grid;
  gap: 6px;
  font-size: 12px;
  color: rgba(234,240,255,.85);
}

.password-wrap{
  position: relative;
}

.toggle{
  position: absolute;
  right: 10px;
  top: 50%;
  transform: translateY(-50%);
  z-index: 2;
  display: flex;
  align-items: center;
  justify-content: center;
  background: rgba(11,18,32,.65);
  border: 1px solid rgba(255,255,255,.16);
  box-shadow: 0 6px 18px rgba(0,0,0,.25);
  color: #eaf0ff;
  border-radius: 10px;
  padding: 6px 8px;
  cursor: pointer;
}

.toggle:hover{
  background: rgba(11,18,32,.78);
}

.eye-icon{
  width: 18px;
  height: 18px;
  display: block;
}

.input-with-toggle{
  padding-right: 52px;
}
</style>
