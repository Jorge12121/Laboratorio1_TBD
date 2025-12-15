<script setup>
import { ref, reactive, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { registerUser } from '../services/api'

const router = useRouter()
const loading = ref(false)
const error = ref('')
const showPass = ref(false)

const form = reactive({
  nombre: '',
  email: '',
  contrasena_hash: '',
  rol: 'planificador',
})

onMounted(() => {
  form.nombre = ''
  form.email = ''
  form.contrasena_hash = ''
  form.rol = 'planificador'
  showPass.value = false
})

const handleRegister = async () => {
  loading.value = true
  error.value = ''
  try {
    await registerUser(form)
    alert('Usuario registrado con éxito.')
    router.push('/login')
  } catch (e) {
    error.value = e.response?.data || 'Error al registrarse.'
  } finally {
    loading.value = false
  }
}
</script>

<template>
  <div class="page">
    <div class="card">
      <div class="header">
        <span class="icon">📝</span>
        <div>
          <h2>Crear Cuenta</h2>
          <p>Completa el formulario para ingresar.</p>
        </div>
      </div>

      <form @submit.prevent="handleRegister" class="form" autocomplete="off">
        <input type="text" name="fake-user" autocomplete="username" style="display:none" />
        <input type="password" name="fake-pass" autocomplete="current-password" style="display:none" />

        <input
          v-model="form.nombre"
          class="input"
          type="text"
          placeholder="Nombre Completo"
          autocomplete="off"
          autocapitalize="words"
          spellcheck="false"
          required
        />

        <input
          v-model="form.email"
          class="input"
          type="email"
          placeholder="Correo Electrónico"
          autocomplete="new-email"
          spellcheck="false"
          required
        />

        <div class="input-wrap">
          <input
            v-model="form.contrasena_hash"
            class="input"
            :type="showPass ? 'text' : 'password'"
            placeholder="Contraseña"
            autocomplete="new-password"
            required
          />

          <button
            class="toggle"
            type="button"
            @click="showPass = !showPass"
            :aria-label="showPass ? 'Ocultar contraseña' : 'Mostrar contraseña'"
          >
            <svg
              v-if="showPass"
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

        <div class="input-wrap arrow">
          <select v-model="form.rol" class="input" autocomplete="off">
            <option value="planificador">Planificador</option>
            <option value="admin">Administrador</option>
            <option value="USER">Usuario Normal</option>
          </select>
        </div>

        <button class="btn-submit" type="submit" :disabled="loading">
          {{ loading ? 'Registrando...' : 'Registrarse' }}
        </button>

        <p v-if="error" class="error-msg">{{ error }}</p>
        <p class="footer">
          ¿Ya tienes cuenta? <router-link to="/login">Inicia Sesión</router-link>
        </p>
      </form>
    </div>
  </div>
</template>

<style scoped>
.page {
  min-height: 100vh;
  display: grid;
  place-items: center;
  background-color: rgba(11,18,32,.65);
  color: #eaf0ff;
  padding: 20px;
}

.card {
  width: 100%;
  max-width: 400px;
  background: #151b27ff;
  padding: 2rem;
  border-radius: 1rem;
  box-shadow: 0 10px 25px rgba(0,0,0,0.3);
  border: 1px solid rgba(255,255,255,0.05);
}

.header { display: flex; gap: 1rem; align-items: center; margin-bottom: 1.5rem; }
.icon { font-size: 1.5rem; background: rgba(66,185,131,0.2); padding: 0.5rem; border-radius: 0.5rem; }
h2 { margin: 0; font-size: 1.25rem; }
p { margin: 0; color: #94a3b8; font-size: 0.875rem; }

.form { display: grid; gap: 1rem; }
.input {
  width: 100%;
  padding: 0.75rem;
  background: rgba(11,18,32,.65);
  border: 1px solid rgba(255,255,255,0.1);
  border-radius: 0.5rem;
  color: #fff;
  outline: none;
  box-sizing: border-box;
}
.input:focus { border-color: #42b983; }

.input-wrap { position: relative; }

.arrow::after {
  content: '▼';
  position: absolute;
  right: 15px;
  top: 18px;
  font-size: 0.7rem;
  color: rgba(255,255,255,0.5);
  pointer-events: none;
}
select.input { appearance: none; cursor: pointer; }

.btn-submit {
  padding: 0.75rem;
  background-color: #42b983;
  color: white;
  border: none;
  border-radius: 0.5rem;
  font-weight: bold;
  cursor: pointer;
  transition: 0.2s;
}
.btn-submit:hover { background-color: #3aa876; }
.btn-submit:disabled { opacity: 0.7; cursor: not-allowed; }

.error-msg {
  color: #ff6b6b;
  text-align: center;
  font-size: 0.9rem;
  background: rgba(255,107,107,0.1);
  padding: 0.5rem;
  border-radius: 0.5rem;
}

.footer { text-align: center; margin-top: 1rem; }
.footer a { color: #42b983; text-decoration: none; font-weight: bold; }

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
</style>
