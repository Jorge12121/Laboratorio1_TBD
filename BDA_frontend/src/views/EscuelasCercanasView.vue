<script setup>
import { ref, onMounted, computed } from 'vue'
import ConsultasEspacialesService from '@/services/ConsultasEspacialesService'

const datos = ref([])
const error = ref('')
const cargando = ref(true)
const filtroProyecto = ref('')

const obtenerDatos = async () => {
  cargando.value = true
  error.value = ''

  try {
    const response = await ConsultasEspacialesService.obtenerEscuelasCercanas()
    datos.value = response.data
  } catch (e) {
    console.error(e)
    error.value = 'Error al obtener escuelas cercanas.'
  } finally {
    cargando.value = false
  }
}

const formatearNumero = (n) => {
  if (n === null || n === undefined) return '-'
  const num = Number(n)
  if (Number.isNaN(num)) return String(n)
  return num.toLocaleString('es-CL', { minimumFractionDigits: 2, maximumFractionDigits: 2 })
}

const datosFiltrados = computed(() => {
  if (!filtroProyecto.value) return datos.value
  return datos.value.filter(d => 
    d.nombreProyecto.toLowerCase().includes(filtroProyecto.value.toLowerCase()) ||
    d.nombreEscuela.toLowerCase().includes(filtroProyecto.value.toLowerCase())
  )
})

const proyectosUnicos = computed(() => {
  return [...new Set(datos.value.map(d => d.nombreProyecto))]
})

const getDistanceClass = (distancia) => {
  const dist = Number(distancia)
  if (dist < 200) return 'distance-close'
  if (dist < 400) return 'distance-medium'
  return 'distance-far'
}

onMounted(obtenerDatos)
</script>

<template>
  <div class="page">
    <div class="page-head">
      <div>
        <h3>🏫 Escuelas Cercanas a Proyectos</h3>
        <p>Escuelas a menos de 500m de proyectos en curso (ST_DWithin)</p>
      </div>

      <button class="btn" type="button" @click="obtenerDatos" :disabled="cargando">
        {{ cargando ? 'Cargando…' : 'Refrescar' }}
      </button>
    </div>

    <div class="filters">
      <input 
        v-model="filtroProyecto" 
        type="text" 
        placeholder="Filtrar por proyecto o escuela..."
        class="input"
      />
    </div>

    <div v-if="error" class="alert error">{{ error }}</div>

    <div v-else-if="cargando" class="alert">
      Cargando datos…
    </div>

    <div v-else>
      <div class="stats">
        <div class="stat-card">
          <div class="stat-value">{{ proyectosUnicos.length }}</div>
          <div class="stat-label">Proyectos con escuelas cercanas</div>
        </div>
        <div class="stat-card">
          <div class="stat-value">{{ datos.length }}</div>
          <div class="stat-label">Relaciones proyecto-escuela</div>
        </div>
      </div>

      <table class="table table--info">
        <thead>
          <tr>
            <th>ID Proyecto</th>
            <th>Proyecto</th>
            <th>ID Escuela</th>
            <th>Escuela</th>
            <th>Distancia (m)</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="item in datosFiltrados" :key="`${item.idProyecto}-${item.idEscuela}`">
            <td>{{ item.idProyecto }}</td>
            <td><strong>{{ item.nombreProyecto }}</strong></td>
            <td>{{ item.idEscuela }}</td>
            <td>{{ item.nombreEscuela }}</td>
            <td>
              <span class="distance-badge" :class="getDistanceClass(item.distanciaM)">
                {{ formatearNumero(item.distanciaM) }} m
              </span>
            </td>
          </tr>

          <tr v-if="datosFiltrados.length === 0">
            <td colspan="5" class="text-center">No hay datos para mostrar.</td>
          </tr>
        </tbody>
      </table>

      <div class="info-box">
        <strong>ℹ️ Información:</strong>
        <p>Esta consulta utiliza ST_DWithin para encontrar escuelas que están a menos de 500 metros 
        de proyectos con estado "En Curso". La distancia se calcula usando geography para mayor precisión.</p>
      </div>
    </div>
  </div>
</template>

<style scoped>
.page { display: grid; gap: 16px; }
.page-head {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  gap: 12px;
}
h3 { margin: 0; }
p { margin: 6px 0 0; color: #666; }

.filters {
  display: flex;
  gap: 12px;
}

.input {
  padding: 8px 12px;
  border: 1px solid #ddd;
  border-radius: 4px;
  font-size: 14px;
  flex: 1;
  max-width: 400px;
}

.stats {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
  gap: 16px;
  margin-bottom: 16px;
}

.stat-card {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  padding: 20px;
  border-radius: 8px;
  text-align: center;
}

.stat-value {
  font-size: 32px;
  font-weight: bold;
  margin-bottom: 8px;
}

.stat-label {
  font-size: 14px;
  opacity: 0.9;
}

.distance-badge {
  padding: 4px 12px;
  border-radius: 12px;
  font-weight: 600;
  font-size: 13px;
}

.distance-close {
  background: #c8e6c9;
  color: #2e7d32;
}

.distance-medium {
  background: #fff9c4;
  color: #f57f17;
}

.distance-far {
  background: #ffcdd2;
  color: #c62828;
}

.text-center {
  text-align: center;
}

.info-box {
  background: #f5f5f5;
  border-left: 4px solid #4caf50;
  padding: 12px 16px;
  border-radius: 4px;
  font-size: 14px;
}

.info-box p {
  margin: 4px 0 0;
  color: #666;
}
</style>
