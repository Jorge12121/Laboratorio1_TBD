<script setup>
import { ref, onMounted } from 'vue'
import DatosDemograficosService from '@/services/DatosDemograficosService'

const datos = ref([])
const cargando = ref(false)
const error = ref('')
const page = ref(0)
const size = ref(10)
const totalPages = ref(0)
const totalItems = ref(0)

// Filtros
const zonaFiltro = ref('')
const anioFiltro = ref('')

const cargar = async () => {
  cargando.value = true
  error.value = ''

  try {
    const response = await DatosDemograficosService.getAllPaginated(page.value, size.value)
    datos.value = response.data.datos
    page.value = response.data.currentPage
    totalPages.value = response.data.totalPages
    totalItems.value = response.data.totalItems
  } catch (e) {
    console.error(e)
    error.value = 'No se pudieron cargar los datos demográficos.'
  } finally {
    cargando.value = false
  }
}

const buscarPorZona = async () => {
  if (!zonaFiltro.value) return
  
  cargando.value = true
  error.value = ''
  
  try {
    const response = await DatosDemograficosService.getByZona(parseInt(zonaFiltro.value))
    datos.value = response.data
    totalPages.value = 1
    totalItems.value = datos.value.length
  } catch (e) {
    console.error(e)
    error.value = 'Error al buscar por zona.'
  } finally {
    cargando.value = false
  }
}

const buscarPorAnio = async () => {
  if (!anioFiltro.value) return
  
  cargando.value = true
  error.value = ''
  
  try {
    const response = await DatosDemograficosService.getByAnio(parseInt(anioFiltro.value))
    datos.value = response.data
    totalPages.value = 1
    totalItems.value = datos.value.length
  } catch (e) {
    console.error(e)
    error.value = 'Error al buscar por año.'
  } finally {
    cargando.value = false
  }
}

const limpiarFiltros = () => {
  zonaFiltro.value = ''
  anioFiltro.value = ''
  cargar()
}

const siguientePagina = () => {
  if (page.value < totalPages.value - 1) {
    page.value++
    cargar()
  }
}

const paginaAnterior = () => {
  if (page.value > 0) {
    page.value--
    cargar()
  }
}

onMounted(cargar)
</script>

<template>
  <div class="page">
    <div class="page-head">
      <div>
        <h3>Datos Demográficos</h3>
        <p>Gestión de datos demográficos por zona y año.</p>
      </div>
    </div>

    <!-- Filtros -->
    <div class="filters-card card">
      <h4>Filtros</h4>
      <div class="filters">
        <div class="filter-group">
          <label>ID Zona:</label>
          <input type="number" v-model="zonaFiltro" placeholder="Ej: 1" class="input" />
          <button @click="buscarPorZona" class="btn secondary" :disabled="!zonaFiltro">Buscar</button>
        </div>
        <div class="filter-group">
          <label>Año:</label>
          <input type="number" v-model="anioFiltro" placeholder="Ej: 2023" class="input" />
          <button @click="buscarPorAnio" class="btn secondary" :disabled="!anioFiltro">Buscar</button>
        </div>
        <button @click="limpiarFiltros" class="btn">Limpiar filtros</button>
      </div>
    </div>

    <div v-if="error" class="alert error">{{ error }}</div>

    <div v-else-if="cargando" class="alert">
      Cargando datos demográficos…
    </div>

    <!-- Tabla de datos -->
    <div v-else class="card">
      <div class="table-container">
        <table class="table">
          <thead>
            <tr>
              <th>ID</th>
              <th>Zona</th>
              <th>Año</th>
              <th>Población</th>
              <th>Densidad</th>
              <th>Edad Promedio</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="dato in datos" :key="dato.id_datos || dato.id">
              <td>{{ dato.id_datos || dato.id }}</td>
              <td>{{ dato.id_zona }}</td>
              <td>{{ dato.anio }}</td>
              <td>{{ dato.poblacion?.toLocaleString() }}</td>
              <td>{{ dato.densidad?.toFixed(2) }}</td>
              <td>{{ dato.edad_promedio?.toFixed(1) }} años</td>
            </tr>
          </tbody>
        </table>
      </div>

      <!-- Paginación -->
      <div class="pagination" v-if="totalPages > 1">
        <button @click="paginaAnterior" :disabled="page === 0" class="btn secondary">
          ← Anterior
        </button>
        <span class="page-info">
          Página {{ page + 1 }} de {{ totalPages }} ({{ totalItems }} registros)
        </span>
        <button @click="siguientePagina" :disabled="page >= totalPages - 1" class="btn secondary">
          Siguiente →
        </button>
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

.filters-card h4 {
  margin: 0 0 12px;
  font-size: 14px;
}

.filters {
  display: flex;
  gap: 12px;
  flex-wrap: wrap;
  align-items: flex-end;
}

.filter-group {
  display: flex;
  flex-direction: column;
  gap: 6px;
}

.filter-group label {
  font-size: 12px;
  opacity: 0.8;
}

.input {
  height: 38px;
  padding: 0 12px;
  border-radius: 8px;
  border: 1px solid rgba(255,255,255,.12);
  background-color: rgba(255,255,255,.06);
  color: #eaf0ff;
  outline: none;
  min-width: 150px;
}

.input:focus {
  border-color: rgba(66,185,131,.35);
  box-shadow: 0 0 0 3px rgba(66,185,131,.12);
}

.table-container {
  overflow-x: auto;
}

.table {
  width: 100%;
  border-collapse: collapse;
  font-size: 13px;
}

.table th {
  text-align: left;
  padding: 12px;
  border-bottom: 1px solid rgba(255,255,255,.12);
  font-weight: 600;
  opacity: 0.9;
}

.table td {
  padding: 12px;
  border-bottom: 1px solid rgba(255,255,255,.08);
}

.table tbody tr:hover {
  background-color: rgba(255,255,255,.03);
}

.pagination {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 16px;
  border-top: 1px solid rgba(255,255,255,.08);
}

.page-info {
  font-size: 13px;
  opacity: 0.8;
}

.btn.secondary {
  background-color: rgba(255,255,255,.08);
}

.btn.secondary:hover:not(:disabled) {
  background-color: rgba(255,255,255,.12);
}

.btn:disabled {
  opacity: 0.4;
  cursor: not-allowed;
}
</style>
