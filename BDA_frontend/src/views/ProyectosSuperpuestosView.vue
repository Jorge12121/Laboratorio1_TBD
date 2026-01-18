<script setup>
import { ref, onMounted, computed } from 'vue'
import ConsultasEspacialesService from '@/services/ConsultasEspacialesService'

const datos = ref([])
const error = ref('')
const cargando = ref(true)
const filtroNombre = ref('')

const obtenerDatos = async () => {
  cargando.value = true
  error.value = ''

  try {
    const response = await ConsultasEspacialesService.obtenerProyectosSuperpuestos()
    datos.value = response.data
  } catch (e) {
    console.error(e)
    error.value = 'Error al obtener proyectos superpuestos.'
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
  if (!filtroNombre.value) return datos.value
  return datos.value.filter(d => 
    d.nombreA.toLowerCase().includes(filtroNombre.value.toLowerCase()) ||
    d.nombreB.toLowerCase().includes(filtroNombre.value.toLowerCase())
  )
})

const areaTotal = computed(() => {
  return datos.value.reduce((sum, item) => sum + Number(item.areaConflictoM2 || 0), 0)
})

const getAreaClass = (area) => {
  const areaNum = Number(area)
  if (areaNum > 5000) return 'area-critical'
  if (areaNum > 2000) return 'area-high'
  return 'area-moderate'
}

onMounted(obtenerDatos)
</script>

<template>
  <div class="page">
    <div class="page-head">
      <div>
        <h3>⚠️ Superposición de Proyectos</h3>
        <p>Proyectos con conflictos geográficos (ST_Intersects + ST_Intersection)</p>
      </div>

      <button class="btn" type="button" @click="obtenerDatos" :disabled="cargando">
        {{ cargando ? 'Cargando…' : 'Refrescar' }}
      </button>
    </div>

    <div class="filters">
      <input 
        v-model="filtroNombre" 
        type="text" 
        placeholder="Filtrar por nombre de proyecto..."
        class="input"
      />
    </div>

    <div v-if="error" class="alert error">{{ error }}</div>

    <div v-else-if="cargando" class="alert">
      Cargando datos…
    </div>

    <div v-else>
      <div class="stats">
        <div class="stat-card warning">
          <div class="stat-value">{{ datos.length }}</div>
          <div class="stat-label">Conflictos detectados</div>
        </div>
        <div class="stat-card warning">
          <div class="stat-value">{{ formatearNumero(areaTotal) }} m²</div>
          <div class="stat-label">Área total de conflicto</div>
        </div>
      </div>

      <table class="table table--info">
        <thead>
          <tr>
            <th>ID Proyecto A</th>
            <th>Proyecto A</th>
            <th>ID Proyecto B</th>
            <th>Proyecto B</th>
            <th>Área de Conflicto (m²)</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="item in datosFiltrados" :key="`${item.proyectoA}-${item.proyectoB}`" class="conflict-row">
            <td>{{ item.proyectoA }}</td>
            <td><strong>{{ item.nombreA }}</strong></td>
            <td>{{ item.proyectoB }}</td>
            <td><strong>{{ item.nombreB }}</strong></td>
            <td>
              <span class="area-badge" :class="getAreaClass(item.areaConflictoM2)">
                {{ formatearNumero(item.areaConflictoM2) }} m²
              </span>
            </td>
          </tr>

          <tr v-if="datosFiltrados.length === 0">
            <td colspan="5" class="text-center">
              <div class="success-message">
                ✅ No se detectaron conflictos de superposición entre proyectos.
              </div>
            </td>
          </tr>
        </tbody>
      </table>

      <div class="info-box warning-box" v-if="datos.length > 0">
        <strong>⚠️ Acción requerida:</strong>
        <p>Se han detectado {{ datos.length }} conflicto(s) de superposición. Es necesario revisar y ajustar 
        las geometrías de estos proyectos para evitar problemas de planificación y ejecución.</p>
      </div>

      <div class="info-box" v-else>
        <strong>ℹ️ Información:</strong>
        <p>Esta consulta utiliza ST_Intersects para detectar proyectos que se superponen geográficamente 
        y ST_Intersection para calcular el área exacta del conflicto en metros cuadrados.</p>
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
  grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
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

.stat-card.warning {
  background: linear-gradient(135deg, #f093fb 0%, #f5576c 100%);
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

.conflict-row {
  background: #ffb74d;
  border-left: 4px solid #e65100;
  color: #1a1a1a;
  font-weight: 500;
}

.conflict-row:hover {
  background: #ffa726;
  color: #000;
}

.area-badge {
  padding: 4px 12px;
  border-radius: 12px;
  font-weight: 600;
  font-size: 13px;
}

.area-moderate {
  background: #fff9c4;
  color: #f57f17;
}

.area-high {
  background: #ffcc80;
  color: #e65100;
}

.area-critical {
  background: #ef5350;
  color: white;
}

.text-center {
  text-align: center;
}

.success-message {
  color: #2e7d32;
  font-weight: 600;
  padding: 12px;
}

.info-box {
  background: #f5f5f5;
  border-left: 4px solid #ff9800;
  padding: 12px 16px;
  border-radius: 4px;
  font-size: 14px;
}

.warning-box {
  background: #fff3e0;
  border-left: 4px solid #f57c00;
}

.info-box p {
  margin: 4px 0 0;
  color: #666;
}
</style>
