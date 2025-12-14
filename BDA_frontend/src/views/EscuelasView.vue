<script setup>
import { ref, onMounted, computed } from 'vue'
import ReporteService from '@/services/ReporteService'

const filas = ref([])
const error = ref('')
const cargando = ref(true)

const pageSize = 10
const page = ref(1) // 1..n

const cargar = async () => {
  cargando.value = true
  error.value = ''
  try {
    const response = await ReporteService.obtenerEscuelas()
    filas.value = response.data ?? []
    page.value = 1 // reset al refrescar
  } catch (e) {
    console.error(e)
    error.value = 'No se pudo obtener el reporte de escuelas.'
  } finally {
    cargando.value = false
  }
}

onMounted(cargar)

// total páginas
const totalPages = computed(() => {
  const total = filas.value.length
  return Math.max(1, Math.ceil(total / pageSize))
})

// slice de la página actual
const filasPaginadas = computed(() => {
  const start = (page.value - 1) * pageSize
  return filas.value.slice(start, start + pageSize)
})

const puedeAtras = computed(() => page.value > 1)
const puedeAdelante = computed(() => page.value < totalPages.value)

const atras = () => {
  if (puedeAtras.value) page.value -= 1
}

const adelante = () => {
  if (puedeAdelante.value) page.value += 1
}

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
        <h3>Escuelas</h3>
        <p>Reporte asociado a escuelas por zona.</p>
      </div>

      <button class="btn" type="button" @click="cargar" :disabled="cargando">
        {{ cargando ? 'Cargando…' : 'Refrescar' }}
      </button>
    </div>

    <div v-if="error" class="alert error">{{ error }}</div>
    <div v-else-if="cargando" class="alert">Cargando datos…</div>

    <div v-else>
      <table class="table table--warn">
        <thead>
          <tr>
            <th>Escuela</th>
            <th>Proyecto</th>
            <th>Distancia Escuela-Proyecto (Km)</th>
          </tr>
        </thead>

        <tbody>
          <tr v-for="(item, i) in filasPaginadas" :key="i">
            <td>{{ item.nombreEscuela}}</td>
            <td>{{ item.nombreProyecto}}</td>
            <td>{{ formatearNumero(item.distancia) }}</td>
          </tr>

          <tr v-if="filas.length === 0">
            <td colspan="2">No hay datos para mostrar.</td>
          </tr>
        </tbody>
      </table>

      <!-- Footer paginación -->
      <div v-if="filas.length > 0" class="pager">
        <button class="btn" type="button" @click="atras" :disabled="!puedeAtras">
          ← Anterior
        </button>

        <div class="pager-info">
          Página {{ page }} de {{ totalPages }}
        </div>

        <button class="btn" type="button" @click="adelante" :disabled="!puedeAdelante">
          Siguiente →
        </button>
      </div>
    </div>
  </div>
</template>

<style scoped>
.page{ display:grid; gap:12px; }
.page-head{ display:flex; justify-content:space-between; align-items:flex-start; gap:12px; }
</style>
