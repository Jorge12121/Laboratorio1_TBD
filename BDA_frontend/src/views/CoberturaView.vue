<!-- BDA_frontend/src/views/CoberturaView.vue -->
<script setup>
import { ref, onMounted } from 'vue'
import api from '@/services/api'

const cobertura = ref([])
const error = ref('')
const cargando = ref(true)

const cargar = async () => {
  cargando.value = true
  error.value = ''

  try {
    const response = await api.get('/api/reportes/cobertura')
    cobertura.value = response.data
  } catch (e) {
    console.error(e)
    error.value = 'No se pudo obtener el reporte de cobertura.'
  } finally {
    cargando.value = false
  }
}

onMounted(cargar)

const formatearNumero = (n) => {
  if (n === null || n === undefined) return '-'
  return Number(n).toLocaleString('es-CL')
}

const getTotalServicios = (item) => {
  const hospitales = Number(item.hospitales) || 0
  const escuelas = Number(item.escuelas) || 0
  const parques = Number(item.parques) || 0
  return hospitales + escuelas + parques
}

const getColorBarra = (total) => {
  if (total >= 15) return '#4ade80' // Verde
  if (total >= 8) return '#fbbf24'  // Amarillo
  return '#f87171'                   // Rojo
}
</script>

<template>
  <div class="page">
    <div class="page-head">
      <div>
        <h3>Cobertura de Infraestructura</h3>
        <p>Vista materializada de servicios por zona urbana.</p>
      </div>

      <button class="btn" @click="cargar" :disabled="cargando">
        {{ cargando ? 'Cargando…' : 'Refrescar' }}
      </button>
    </div>

    <div v-if="error" class="alert error">{{ error }}</div>
    <div v-else-if="cargando" class="alert">Cargando datos…</div>

    <div v-else>
      <table class="table table--info">
        <thead>
          <tr>
            <th>Zona</th>
            <th>🏥 Hospitales</th>
            <th>🏫 Escuelas</th>
            <th>🌳 Parques</th>
            <th>Total</th>
            <th>Cobertura</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="item in cobertura" :key="item.id_zona">
            <td><strong>{{ item.nombre_zona }}</strong></td>
            <td>{{ formatearNumero(item.hospitales) }}</td>
            <td>{{ formatearNumero(item.escuelas) }}</td>
            <td>{{ formatearNumero(item.parques) }}</td>
            <td><span class="badge">{{ getTotalServicios(item) }}</span></td>
            <td>
              <div class="barra">
                <div 
                  class="barra-fill" 
                  :style="{ 
                    width: `${Math.min(100, getTotalServicios(item) * 5)}%`,
                    backgroundColor: getColorBarra(getTotalServicios(item))
                  }"
                ></div>
              </div>
            </td>
          </tr>

          <tr v-if="cobertura.length === 0">
            <td colspan="6">No hay datos de cobertura disponibles.</td>
          </tr>
        </tbody>
      </table>

      <div class="hint">
        <strong>Nota:</strong> Esta vista se actualiza semanalmente. Los datos reflejan el conteo actual de puntos de interés por zona.
      </div>
    </div>
  </div>
</template>

<style scoped>
.page { display: grid; gap: 12px; }
.page-head { display: flex; justify-content: space-between; align-items: flex-start; gap: 12px; }

.barra {
  width: 100%;
  height: 20px;
  background: rgba(255,255,255,.08);
  border-radius: 10px;
  overflow: hidden;
}

.barra-fill {
  height: 100%;
  transition: width 0.3s ease, background-color 0.3s ease;
  border-radius: 10px;
}

.hint {
  font-size: 12px;
  opacity: .75;
  padding: 12px;
  background: rgba(255,255,255,.03);
  border-radius: 12px;
  border: 1px solid rgba(255,255,255,.08);
  margin-top: 8px;
}
</style>
