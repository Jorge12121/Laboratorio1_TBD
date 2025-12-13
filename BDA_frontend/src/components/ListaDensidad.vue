<script setup>
import { ref, onMounted } from 'vue'
import ReporteService from '@/services/ReporteService'

const reportes = ref([])
const error = ref('')
const cargando = ref(true)

const obtenerDatos = async () => {
  cargando.value = true
  error.value = ''

  try {
    const response = await ReporteService.obtenerDensidad()
    reportes.value = response.data
  } catch (e) {
    console.error(e)
    error.value = 'Error al conectar con el backend.'
  } finally {
    cargando.value = false
  }
}

const formatearNumero = (n) => {
  if (n === null || n === undefined) return '-'
  const num = Number(n)
  if (Number.isNaN(num)) return String(n)
  return num.toLocaleString('es-CL')
}

onMounted(obtenerDatos)
</script>

<template>
  <div class="page">
    <div class="page-head">
      <div>
        <h3>Densidad Poblacional</h3>
        <p>Reporte por zona urbana.</p>
      </div>

      <button class="btn" type="button" @click="obtenerDatos" :disabled="cargando">
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
            <th>Densidad (Hab/km²)</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="(item, index) in reportes" :key="index">
            <td>{{ item.nombre }}</td>
            <td>{{ formatearNumero(item.densidad) }}</td>
          </tr>

          <tr v-if="reportes.length === 0">
            <td colspan="2">No hay datos para mostrar.</td>
          </tr>
        </tbody>
      </table>
    </div>
  </div>
</template>

<style scoped>
.page { display: grid; gap: 12px; }
.page-head {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  gap: 12px;
}
h3 { margin: 0; }
p { margin: 6px 0 0; }
</style>
