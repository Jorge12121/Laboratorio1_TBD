<script setup>
import { ref, onMounted, computed } from 'vue'
import ConsultasEspacialesService from '@/services/ConsultasEspacialesService'

const datos = ref([])
const error = ref('')
const cargando = ref(true)
const filtroZona = ref('')

const obtenerDatos = async () => {
  cargando.value = true
  error.value = ''

  try {
    const response = await ConsultasEspacialesService.obtenerCoberturaServicios()
    datos.value = response.data
  } catch (e) {
    console.error(e)
    error.value = 'Error al obtener cobertura de servicios.'
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
  if (!filtroZona.value) return datos.value
  return datos.value.filter(d => 
    d.nombreZona.toLowerCase().includes(filtroZona.value.toLowerCase())
  )
})

const coberturaPromedio = computed(() => {
  const validos = datos.value.filter(d => d.porcentajeCobertura !== null && d.porcentajeCobertura !== undefined)
  if (validos.length === 0) return 0
  const suma = validos.reduce((sum, item) => sum + Number(item.porcentajeCobertura || 0), 0)
  return (suma / validos.length).toFixed(2)
})

const zonasSinCobertura = computed(() => {
  return datos.value.filter(d => Number(d.porcentajeCobertura || 0) === 0).length
})

const getCoberturaClass = (porcentaje) => {
  const p = Number(porcentaje || 0)
  if (p === 0) return 'status-none'
  if (p < 10) return 'status-none'
  if (p < 40) return 'status-poor'
  if (p < 70) return 'status-good'
  return 'status-excellent'
}

const getCoberturaLabel = (porcentaje) => {
  const p = Number(porcentaje || 0)
  if (p === 0) return 'Sin cobertura'
  if (p < 10) return 'Crítico'
  if (p < 40) return 'Deficiente'
  if (p < 70) return 'Buena'
  return 'Excelente'
}

onMounted(obtenerDatos)
</script>

<template>
  <div class="page">
    <div class="page-head">
      <div>
        <h3>🏥 Cobertura de Hospitales</h3>
        <p>Porcentaje de área cubierta por buffer de 1km de hospitales (ST_Buffer + ST_Intersection)</p>
      </div>

      <button class="btn" type="button" @click="obtenerDatos" :disabled="cargando">
        {{ cargando ? 'Cargando…' : 'Refrescar' }}
      </button>
    </div>

    <div class="filters">
      <input 
        v-model="filtroZona" 
        type="text" 
        placeholder="Filtrar por nombre de zona..."
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
          <div class="stat-value">{{ coberturaPromedio }}%</div>
          <div class="stat-label">Cobertura promedio</div>
        </div>
        <div class="stat-card danger" v-if="zonasSinCobertura > 0">
          <div class="stat-value">{{ zonasSinCobertura }}</div>
          <div class="stat-label">Zonas sin cobertura</div>
        </div>
        <div class="stat-card success" v-else>
          <div class="stat-value">✓</div>
          <div class="stat-label">Todas las zonas tienen cobertura</div>
        </div>
      </div>

      <table class="table table--info">
        <thead>
          <tr>
            <th>ID</th>
            <th>Zona</th>
            <th>Área Total (m²)</th>
            <th>Área Cubierta (m²)</th>
            <th>Cobertura (%)</th>
            <th>Estado</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="item in datosFiltrados" :key="item.idZona">
            <td>{{ item.idZona }}</td>
            <td><strong>{{ item.nombreZona }}</strong></td>
            <td>{{ formatearNumero(item.areaZonaM2) }}</td>
            <td>{{ formatearNumero(item.areaCubiertaM2) }}</td>
            <td>
              <div class="progress-container">
                <div class="progress-bar" :style="{ width: `${Math.min(item.porcentajeCobertura || 0, 100)}%` }">
                  <span class="progress-text">{{ formatearNumero(item.porcentajeCobertura) }}%</span>
                </div>
              </div>
            </td>
            <td>
              <span class="status-badge" :class="getCoberturaClass(item.porcentajeCobertura)">
                {{ getCoberturaLabel(item.porcentajeCobertura) }}
              </span>
            </td>
          </tr>

          <tr v-if="datosFiltrados.length === 0">
            <td colspan="6" class="text-center">No hay datos para mostrar.</td>
          </tr>
        </tbody>
      </table>

      <div class="info-box">
        <strong>ℹ️ Información:</strong>
        <p>Esta consulta utiliza ST_Buffer para crear un área de servicio de 1km alrededor de cada hospital, 
        y ST_Intersection para calcular qué porcentaje del área de cada zona está cubierta por estos buffers.</p>
        <p><strong>Interpretación:</strong></p>
        <ul>
          <li>🟢 <strong>Excelente</strong>: &gt; 70% de cobertura</li>
          <li>🟡 <strong>Buena</strong>: 40-70% de cobertura</li>
          <li>🟠 <strong>Deficiente</strong>: 10-40% de cobertura</li>
          <li>🔴 <strong>Sin cobertura</strong>: &lt; 10% o 0%</li>
        </ul>
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

.stat-card.danger {
  background: linear-gradient(135deg, #f093fb 0%, #f5576c 100%);
}

.stat-card.success {
  background: linear-gradient(135deg, #4facfe 0%, #00f2fe 100%);
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

.progress-container {
  width: 100%;
  height: 24px;
  background: #e0e0e0;
  border-radius: 12px;
  overflow: hidden;
  position: relative;
}

.progress-bar {
  height: 100%;
  background: linear-gradient(90deg, #4caf50 0%, #8bc34a 100%);
  display: flex;
  align-items: center;
  justify-content: center;
  transition: width 0.3s ease;
  min-width: 60px;
}

.progress-text {
  color: white;
  font-size: 12px;
  font-weight: 600;
  text-shadow: 0 1px 2px rgba(0,0,0,0.2);
}

.status-badge {
  padding: 4px 12px;
  border-radius: 12px;
  font-weight: 600;
  font-size: 13px;
}

.status-excellent {
  background: #c8e6c9;
  color: #2e7d32;
}

.status-good {
  background: #fff9c4;
  color: #f57f17;
}

.status-poor {
  background: #ffcc80;
  color: #e65100;
}

.status-none {
  background: #ffcdd2;
  color: #c62828;
}

.text-center {
  text-align: center;
}

.info-box {
  background: #f5f5f5;
  border-left: 4px solid #00bcd4;
  padding: 12px 16px;
  border-radius: 4px;
  font-size: 14px;
}

.info-box p {
  margin: 8px 0 0;
  color: #666;
}

.info-box ul {
  margin: 8px 0 0;
  padding-left: 20px;
  color: #666;
}

.info-box li {
  margin: 4px 0;
}
</style>
