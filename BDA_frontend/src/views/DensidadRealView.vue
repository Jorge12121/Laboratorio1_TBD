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
    const response = await ConsultasEspacialesService.obtenerDensidadReal()
    datos.value = response.data
  } catch (e) {
    console.error(e)
    error.value = 'Error al obtener densidad real.'
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

onMounted(obtenerDatos)
</script>

<template>
  <div class="page">
    <div class="page-head">
      <div>
        <h3>📐 Densidad Real</h3>
        <p>Cálculo de densidad usando ST_Area (población / área real en km²)</p>
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
      <table class="table table--info">
        <thead>
          <tr>
            <th>ID</th>
            <th>Zona</th>
            <th>Año</th>
            <th>Población</th>
            <th>Área Real (km²)</th>
            <th>Densidad Real (Hab/km²)</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="item in datosFiltrados" :key="`${item.idZona}-${item.anio}`">
            <td>{{ item.idZona }}</td>
            <td><strong>{{ item.nombreZona }}</strong></td>
            <td>{{ item.anio }}</td>
            <td>{{ formatearNumero(item.poblacion) }}</td>
            <td>{{ formatearNumero(item.areaRealKm2) }}</td>
            <td><span class="badge">{{ formatearNumero(item.densidadRealHabKm2) }}</span></td>
          </tr>

          <tr v-if="datosFiltrados.length === 0">
            <td colspan="6" class="text-center">No hay datos para mostrar.</td>
          </tr>
        </tbody>
      </table>

      <div class="info-box">
        <strong>ℹ️ Información:</strong>
        <p>Esta consulta utiliza ST_Area(geom::geography) para calcular el área real de cada zona urbana en metros cuadrados, 
        luego la convierte a km² y calcula la densidad poblacional real.</p>
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

.badge {
  background: #e3f2fd;
  color: #1976d2;
  padding: 4px 8px;
  border-radius: 4px;
  font-weight: 600;
}

.text-center {
  text-align: center;
}

.info-box {
  background: #f5f5f5;
  border-left: 4px solid #2196f3;
  padding: 12px 16px;
  border-radius: 4px;
  font-size: 14px;
}

.info-box p {
  margin: 4px 0 0;
  color: #666;
}
</style>
