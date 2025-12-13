<script setup>
import { ref, onMounted } from 'vue'
import ReporteService from '@/services/ReporteService'

const crecimiento = ref([])
const error = ref('')
const cargando = ref(true)

onMounted(async () => {
  try {
    const response = await ReporteService.obtenerCrecimiento()  // Consulta 4
    crecimiento.value = response.data
  } catch (e) {
    console.error("Error cargando reporte de crecimiento:", e)
    error.value = 'No se pudo obtener el reporte de crecimiento poblacional.'
  } finally {
    cargando.value = false
  }
})

const formatearNumero = (n) => {
  if (n === null || n === undefined) return '-'
  const num = Number(n)
  if (Number.isNaN(num)) return String(n)
  return num.toLocaleString('es-CL')
}
</script>

<template>
  <div class="page">
    <div class="page-head">
      <div>
        <h3>Simulación de Crecimiento Poblacional</h3>
        <p>Consulta de simulación de crecimiento poblacional por zona.</p>
      </div>

      <button class="btn" type="button" @click="onMounted" :disabled="cargando">
        {{ cargando ? 'Cargando…' : 'Refrescar' }}
      </button>
    </div>

    <div v-if="error" class="alert error">{{ error }}</div>

    <div v-else-if="cargando" class="alert">
      Cargando datos…
    </div>

    <div v-else>
      <table class="table table--info">
        <thead>
          <tr>
            <th>Zona</th>
            <th>% de Crecimiento</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="(item, index) in crecimiento" :key="index">
            <td>{{ item.nombre }}</td>
            <td>{{ formatearNumero(item.crecimiento) }}</td>
          </tr>

          <tr v-if="crecimiento.length === 0">
            <td colspan="3">No hay datos para mostrar.</td>
          </tr>
        </tbody>
      </table>
    </div>
  </div>
</template>

<style scoped>
.page { display: grid; gap: 12px; }
.page-head{ display: flex; justify-content: space-between; align-items: flex-start; gap: 12px; }

.grid{
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(260px, 1fr));
  gap: 14px;
}
</style>
