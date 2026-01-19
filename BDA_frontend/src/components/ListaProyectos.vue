<script setup>
import { ref, onMounted, computed } from 'vue'
import ProyectoService from '@/services/ProyectoService'

const proyectos = ref([])
const cargando = ref(true)
const error = ref('')

const filtroEstado = ref('TODOS') // TODOS | PLANEADO | EN_CURSO | COMPLETADO | RETRASADO

const cargar = async () => {
  cargando.value = true
  error.value = ''

  try {
    console.log('Cargando proyectos... Token:', localStorage.getItem('token') ? 'presente' : 'ausente')
    const response = await ProyectoService.obtenerTodos()
    proyectos.value = response.data
    console.log('Proyectos cargados:', proyectos.value.length)
  } catch (e) {
    console.error('Error al cargar proyectos:', e)
    if (e?.response?.status === 403) {
      error.value = 'No tienes permisos para acceder a los proyectos. Por favor, inicia sesión nuevamente.'
    } else {
      error.value = 'No se pudieron cargar los proyectos.'
    }
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
  if (s === 'retrasado') return 'RETRASADO'
  return 'OTRO'
}

const badgeClass = (estado) => {
  const e = normalizarEstado(estado)
  if (e === 'PLANEADO') return 'badge gray'
  if (e === 'EN_CURSO') return 'badge amber'
  if (e === 'COMPLETADO') return 'badge green'
  if (e === 'RETRASADO') return 'badge red'
  return 'badge'
}

const proyectosFiltrados = computed(() => {
  if (filtroEstado.value === 'TODOS') return proyectos.value
  return proyectos.value.filter(p => normalizarEstado(p.estado) === filtroEstado.value)
})

const formatearFecha = (fecha) => {
  if (!fecha) return '-'
  try {
    const d = new Date(fecha)
    return d.toLocaleDateString('es-CL', { 
      year: 'numeric', 
      month: 'short', 
      day: 'numeric' 
    })
  } catch {
    return String(fecha)
  }
}
</script>

<template>
  <div class="page">
    <div class="page-head">
      <div>
        <h3>Proyectos Urbanos</h3>
        <p>Listado de proyectos registrados.</p>
      </div>

      <div class="actions">
        <select class="select" v-model="filtroEstado">
          <option value="TODOS">Todos</option>
          <option value="PLANEADO">Planeado</option>
          <option value="EN_CURSO">En curso</option>
          <option value="COMPLETADO">Completado</option>
          <option value="RETRASADO">Retrasado</option>
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
      <div v-for="proy in proyectosFiltrados" :key="proy.id_proyectos || proy.id" class="card project-card">
        <div class="row">
          <h4 class="name">{{ proy.nombre }}</h4>
          <span :class="badgeClass(proy.estado)">{{ proy.estado || 'Sin estado' }}</span>
        </div>

        <p class="desc">{{ proy.descripcion || 'Sin descripción.' }}</p>

        <div class="meta">
          <span class="meta-item" v-if="proy.fecha_inicio">
             Inicio: {{ formatearFecha(proy.fecha_inicio) }}
          </span>
          <span class="meta-item" v-if="proy.fecha_fin">
             Fin: {{ formatearFecha(proy.fecha_fin) }}
          </span>
          <span class="meta-item" v-if="proy.id_usuario">
             Usuario ID: {{ proy.id_usuario }}
          </span>
        </div>
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
  grid-template-columns: repeat(auto-fill, minmax(280px, 1fr));
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
  margin: 0 0 10px;
  font-size: 13px;
  color: rgba(234,240,255,.78);
}

.meta{
  display: flex;
  flex-wrap: wrap;
  gap: 8px;
  font-size: 11px;
  opacity: .75;
}

.meta-item{
  padding: 4px 8px;
  border-radius: 6px;
  background: rgba(255,255,255,.05);
  border: 1px solid rgba(255,255,255,.08);
}
</style>
