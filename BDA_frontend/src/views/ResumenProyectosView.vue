<!-- BDA_frontend/src/views/ResumenProyectosView.vue -->
<script setup>
import { ref, onMounted, computed } from 'vue'
import ReporteService from '@/services/ReporteService'
import UtilService from '@/services/UtilService'

const resumen = ref([])
const error = ref('')
const cargando = ref(true)

const cargar = async () => {
  cargando.value = true
  error.value = ''

  try {
    const response = await ReporteService.obtenerResumenProyectos()
    resumen.value = response.data
  } catch (e) {
    console.error(e)
    error.value = 'No se pudo obtener el resumen de proyectos.'
  } finally {
    cargando.value = false
  }
}

const refrescar = async () => {
  cargando.value = true
  error.value = ''

  try {
    // Primero refrescamos la vista materializada
    await UtilService.actualizarResumenProyectos()
    // Luego recargamos los datos
    await cargar()
  } catch (e) {
    console.error(e)
    error.value = 'No se pudo refrescar la vista materializada.'
  } finally {
    cargando.value = false
  }
}

onMounted(cargar)

const formatearNumero = (n) => {
  if (n === null || n === undefined) return '-'
  return Number(n).toLocaleString('es-CL')
}

const badgeClass = (estado) => {
  const e = String(estado || '').trim().toLowerCase()
  if (e === 'planeado') return 'badge gray'
  if (e === 'en curso') return 'badge amber'
  if (e === 'completado') return 'badge green'
  if (e === 'retrasado') return 'badge red'
  return 'badge'
}

// Agrupar por tipo de zona
const zonas = computed(() => {
  const agrupado = {}
  resumen.value.forEach(item => {
    const tipo = item.tipo_zona || 'Sin Zona'
    if (!agrupado[tipo]) {
      agrupado[tipo] = []
    }
    agrupado[tipo].push(item)
  })
  return agrupado
})

const getTotalPorZona = (zona) => {
  return zona.reduce((sum, item) => sum + (Number(item.total_proyectos) || 0), 0)
}
</script>

<template>
  <div class="page">
    <div class="page-head">
      <div>
        <h3>Resumen de Proyectos por Estado y Zona</h3>
        <p>Vista materializada de proyectos agrupados por tipo de zona y estado.</p>
      </div>

      <div class="actions">
        <button class="btn" @click="cargar" :disabled="cargando">
          {{ cargando ? 'Cargando…' : 'Recargar' }}
        </button>
        <button class="btn primary" @click="refrescar" :disabled="cargando">
          🔄 Actualizar Vista
        </button>
      </div>
    </div>

    <div v-if="error" class="alert error">{{ error }}</div>
    <div v-else-if="cargando" class="alert">Cargando datos…</div>

    <div v-else>
      <!-- Vista en Cards por Tipo de Zona -->
      <div class="grid">
        <div v-for="(items, tipoZona) in zonas" :key="tipoZona" class="card zona-card">
          <div class="zona-header">
            <h4>{{ tipoZona }}</h4>
            <span class="badge primary">{{ getTotalPorZona(items) }} proyectos</span>
          </div>

          <div class="estados-list">
            <div v-for="item in items" :key="item.estado" class="estado-item">
              <span :class="badgeClass(item.estado)">{{ item.estado || 'Sin estado' }}</span>
              <span class="count">{{ formatearNumero(item.total_proyectos) }}</span>
            </div>
          </div>
        </div>

        <div v-if="Object.keys(zonas).length === 0" class="alert">
          No hay proyectos registrados.
        </div>
      </div>

      <!-- Vista en Tabla (Alternativa) -->
      <div class="section">
        <h4 class="section-title">Tabla Detallada</h4>
        <table class="table table--compact">
          <thead>
            <tr>
              <th>Tipo de Zona</th>
              <th>Estado</th>
              <th>Cantidad</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="(item, i) in resumen" :key="i">
              <td>{{ item.tipo_zona || 'Sin Zona' }}</td>
              <td><span :class="badgeClass(item.estado)">{{ item.estado }}</span></td>
              <td><strong>{{ formatearNumero(item.total_proyectos) }}</strong></td>
            </tr>
          </tbody>
        </table>
      </div>

      <div class="hint">
        <strong>Nota:</strong> Esta vista se actualiza concurrentemente para optimizar el rendimiento. Los datos son agregados automáticamente.
      </div>
    </div>
  </div>
</template>

<style scoped>
.page { display: grid; gap: 16px; }
.page-head { display: flex; justify-content: space-between; align-items: flex-start; gap: 12px; }

.actions {
  display: flex;
  gap: 10px;
  align-items: center;
}

.grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(280px, 1fr));
  gap: 14px;
}

.zona-card {
  padding: 16px;
}

.zona-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  gap: 10px;
  margin-bottom: 12px;
  padding-bottom: 12px;
  border-bottom: 1px solid rgba(255,255,255,.10);
}

.zona-header h4 {
  margin: 0;
  font-size: 15px;
}

.estados-list {
  display: grid;
  gap: 8px;
}

.estado-item {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 8px 12px;
  background: rgba(255,255,255,.03);
  border-radius: 8px;
  border: 1px solid rgba(255,255,255,.08);
}

.count {
  font-weight: 600;
  font-size: 14px;
}

.section {
  margin-top: 16px;
}

.section-title {
  margin: 0 0 12px;
  font-size: 13px;
  letter-spacing: .2px;
  opacity: .85;
}

.hint {
  font-size: 12px;
  opacity: .75;
  padding: 12px;
  background: rgba(255,255,255,.03);
  border-radius: 12px;
  border: 1px solid rgba(255,255,255,.08);
}
</style>
