<script setup>
import { ref, onMounted, computed } from 'vue'
import ProyectoService from '@/services/ProyectoService'

const proyectos = ref([])
const cargando = ref(true)
const error = ref('')

const filtroEstado = ref('TODOS') // TODOS | PLANEADO | EN_CURSO | COMPLETADO

const cargar = async () => {
  cargando.value = true
  error.value = ''

  try {
    const response = await ProyectoService.obtenerTodos()
    proyectos.value = response.data
  } catch (e) {
    console.error(e)
    error.value = 'No se pudieron cargar los proyectos.'
  } finally {
    cargando.value = false
  }
}

onMounted(cargar)

const normalizarEstado = (estado) => {
  const s = String(estado || '').trim().toLowerCase()
  if (s === 'planeado') return 'PLANEADO'
  if (s === 'en curso') return 'EN_CURSO'
  if (s === 'completado') return 'COMPLETADO'
  return 'OTRO'
}

const badgeClass = (estado) => {
  const e = normalizarEstado(estado)
  if (e === 'PLANEADO') return 'badge gray'
  if (e === 'EN_CURSO') return 'badge amber'
  if (e === 'COMPLETADO') return 'badge green'
  return 'badge'
}

const proyectosFiltrados = computed(() => {
  if (filtroEstado.value === 'TODOS') return proyectos.value
  return proyectos.value.filter(p => normalizarEstado(p.estado) === filtroEstado.value)
})
</script>

<template>
  <div class="page">
    <div class="page-head">
      <div>
        <h3>Proyectos Urbanos</h3>
        <p>Listado de proyectos registrados.</p>
      </div>

      <div class="select-wrap">
        <select class="select" v-model="filtroEstado">
          <option value="TODOS">Todos</option>
          <option value="PLANEADO">Planeado</option>
          <option value="EN_CURSO">En curso</option>
          <option value="COMPLETADO">Completado</option>
        </select>

        <button class="btn primary" type="button" @click="cargar" :disabled="cargando">
          {{ cargando ? 'Cargando…' : 'Refrescar' }}
        </button>
      </div>
    </div>

    <div v-if="error" class="alert error">{{ error }}</div>

    <div v-else-if="cargando" class="alert">
      Cargando proyectos…
    </div>

    <div v-else class="grid">
      <div v-for="proy in proyectosFiltrados" :key="proy.id" class="card project-card">
        <div class="row">
          <h4 class="name">{{ proy.nombre }}</h4>
          <span :class="badgeClass(proy.estado)">{{ proy.estado || 'Sin estado' }}</span>
        </div>

        <p class="desc">{{ proy.descripcion || 'Sin descripción.' }}</p>
      </div>

      <div v-if="proyectosFiltrados.length === 0" class="alert">
        No hay proyectos para mostrar con ese filtro.
      </div>
    </div>
  </div>
</template>

<style scoped>
.page { display: grid; gap: 12px; }

.page-head{
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  gap: 12px;
}

.actions{
  display: flex;
  gap: 10px;
  align-items: center;
}

.select{
  height: 38px;
  padding: 0 38px 0 12px;
  border-radius: 12px;
  border: 1px solid rgba(255,255,255,.12);
  background-color: rgba(255,255,255,.06);
  color: #eaf0ff;
  outline: none;
  cursor: pointer;

  appearance: none;
  -webkit-appearance: none;
  -moz-appearance: none;

  background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='18' height='18' viewBox='0 0 24 24' fill='none' stroke='%23eaf0ff' stroke-width='2' stroke-linecap='round' stroke-linejoin='round'%3E%3Cpolyline points='6 9 12 15 18 9'/%3E%3C/svg%3E");
  background-repeat: no-repeat;
  background-position: right 12px center;
  background-size: 16px 16px;
}

.select:focus{
  border-color: rgba(66,185,131,.35);
  box-shadow: 0 0 0 3px rgba(66,185,131,.12);
}

.actions .btn{
  height: 38px;
  padding: 0 14px;
}

.grid{
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(260px, 1fr));
  gap: 14px;
}

.project-card{ padding: 16px; }

.row{
  display: flex;
  justify-content: space-between;
  align-items: center;
  gap: 10px;
  margin-bottom: 8px;
}

.name{ margin: 0; font-size: 15px; }

.desc{
  margin: 0;
  font-size: 13px;
  color: rgba(234,240,255,.78);
}
</style>
