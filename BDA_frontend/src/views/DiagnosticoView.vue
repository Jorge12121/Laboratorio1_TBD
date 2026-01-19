<template>
  <div class="diagnostico-container">
    <h1>🔧 Diagnóstico del Sistema</h1>
    
    <div class="panel">
      <h2>1. Estado del Token</h2>
      <div v-if="token">
        <p class="success">✅ Token presente en localStorage</p>
        <pre>{{ tokenPreview }}</pre>
        <button @click="copiarToken">Copiar Token Completo</button>
      </div>
      <div v-else>
        <p class="error">❌ No hay token en localStorage</p>
        <p>Necesitas hacer login primero</p>
        <button @click="irALogin">Ir a Login</button>
      </div>
    </div>

    <div class="panel" v-if="token">
      <h2>2. Decodificar Token JWT</h2>
      <div v-if="tokenDecoded">
        <p><strong>Usuario:</strong> {{ tokenDecoded.sub }}</p>
        <p><strong>Emitido:</strong> {{ formatDate(tokenDecoded.iat) }}</p>
        <p><strong>Expira:</strong> {{ formatDate(tokenDecoded.exp) }}</p>
        <p v-if="isExpired" class="error">⚠️ El token HA EXPIRADO</p>
        <p v-else class="success">✅ El token es válido (expira en {{ timeToExpire }})</p>
      </div>
    </div>

    <div class="panel" v-if="token">
      <h2>3. Prueba de Conexión al Backend</h2>
      <button @click="probarConexion" :disabled="probando">
        {{ probando ? 'Probando...' : 'Probar Conexión' }}
      </button>
      
      <div v-if="resultadoPrueba">
        <p :class="resultadoPrueba.success ? 'success' : 'error'">
          {{ resultadoPrueba.mensaje }}
        </p>
        <pre v-if="resultadoPrueba.detalles">{{ resultadoPrueba.detalles }}</pre>
      </div>
    </div>

    <div class="panel">
      <h2>4. Acciones Rápidas</h2>
      <button @click="limpiarSesion" class="btn-danger">Limpiar Sesión</button>
      <button @click="renovarSesion" class="btn-primary">Renovar Sesión (Login)</button>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import api from '@/services/api'

const router = useRouter()
const token = ref(null)
const tokenDecoded = ref(null)
const probando = ref(false)
const resultadoPrueba = ref(null)

onMounted(() => {
  token.value = localStorage.getItem('token')
  if (token.value) {
    decodificarToken()
  }
})

const tokenPreview = computed(() => {
  if (!token.value) return ''
  return token.value.substring(0, 50) + '...'
})

const decodificarToken = () => {
  try {
    const parts = token.value.split('.')
    if (parts.length !== 3) {
      console.error('Token JWT inválido')
      return
    }
    
    const payload = parts[1]
    const decoded = JSON.parse(atob(payload))
    tokenDecoded.value = decoded
  } catch (e) {
    console.error('Error al decodificar token:', e)
  }
}

const isExpired = computed(() => {
  if (!tokenDecoded.value || !tokenDecoded.value.exp) return false
  const now = Math.floor(Date.now() / 1000)
  return tokenDecoded.value.exp < now
})

const timeToExpire = computed(() => {
  if (!tokenDecoded.value || !tokenDecoded.value.exp) return ''
  const now = Math.floor(Date.now() / 1000)
  const diff = tokenDecoded.value.exp - now
  
  if (diff < 0) return 'expirado'
  
  const hours = Math.floor(diff / 3600)
  const minutes = Math.floor((diff % 3600) / 60)
  
  if (hours > 0) return `${hours}h ${minutes}m`
  return `${minutes}m`
})

const formatDate = (timestamp) => {
  if (!timestamp) return 'N/A'
  return new Date(timestamp * 1000).toLocaleString('es-ES')
}

const copiarToken = () => {
  navigator.clipboard.writeText(token.value)
  alert('Token copiado al portapapeles')
}

const irALogin = () => {
  router.push('/login')
}

const probarConexion = async () => {
  probando.value = true
  resultadoPrueba.value = null

  try {
    const response = await api.get('/api/proyectos')
    resultadoPrueba.value = {
      success: true,
      mensaje: '✅ Conexión exitosa con el backend',
      detalles: `Se obtuvieron ${response.data.length} proyectos`
    }
  } catch (e) {
    const status = e?.response?.status || 'desconocido'
    const mensaje = e?.response?.data?.message || e.message || 'Error desconocido'
    
    resultadoPrueba.value = {
      success: false,
      mensaje: `❌ Error ${status}: ${mensaje}`,
      detalles: JSON.stringify(e?.response?.data || e.message, null, 2)
    }
  } finally {
    probando.value = false
  }
}

const limpiarSesion = () => {
  if (confirm('¿Estás seguro de que deseas limpiar la sesión?')) {
    localStorage.clear()
    alert('Sesión limpiada. Por favor, inicia sesión de nuevo.')
    router.push('/login')
  }
}

const renovarSesion = () => {
  router.push('/login')
}
</script>

<style scoped>
.diagnostico-container {
  padding: 2rem;
  max-width: 900px;
  margin: 0 auto;
}

h1 {
  color: #2c3e50;
  margin-bottom: 2rem;
}

.panel {
  background: white;
  border: 1px solid #ddd;
  border-radius: 8px;
  padding: 1.5rem;
  margin-bottom: 1.5rem;
}

h2 {
  color: #34495e;
  font-size: 1.2rem;
  margin-bottom: 1rem;
}

pre {
  background: #f5f5f5;
  padding: 1rem;
  border-radius: 4px;
  overflow-x: auto;
  font-size: 0.9rem;
}

button {
  background: #3498db;
  color: white;
  border: none;
  padding: 0.7rem 1.5rem;
  border-radius: 4px;
  cursor: pointer;
  font-size: 1rem;
  margin-right: 0.5rem;
  margin-top: 0.5rem;
}

button:hover {
  background: #2980b9;
}

button:disabled {
  background: #95a5a6;
  cursor: not-allowed;
}

.btn-danger {
  background: #e74c3c;
}

.btn-danger:hover {
  background: #c0392b;
}

.btn-primary {
  background: #2ecc71;
}

.btn-primary:hover {
  background: #27ae60;
}

.success {
  color: #27ae60;
  font-weight: bold;
}

.error {
  color: #e74c3c;
  font-weight: bold;
}

p {
  margin: 0.5rem 0;
}
</style>
