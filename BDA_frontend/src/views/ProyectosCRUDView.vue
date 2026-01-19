<script setup>
import { ref, computed, watch, onMounted } from 'vue'
import ProyectoService from '@/services/ProyectoService'
import ZonaService from '@/services/ZonaService'
import MapPicker from '@/components/MapPicker.vue'

const proyectos = ref([])
const cargando = ref(false)
const error = ref('')
const page = ref(0)
const size = ref(10)
const totalPages = ref(0)
const totalItems = ref(0)

// Filtros
const estadoFiltro = ref('')
const nombreFiltro = ref('')

// Modal para crear/editar
const showModal = ref(false)
const editando = ref(false)
const proyectoActual = ref({
  nombre: '',
  descripcion: '',
  fecha_inicio: '',
  fecha_fin: '',
  estado: 'Planeado',
  id_zona: null,
  id_usuario: null,
  area_km2: 0.01// Área del círculo (no se guarda, solo para calcular radio)
})

const centro = ref(null) // Centro del círculo del proyecto
const zonaSeleccionada = ref([]) // Array de zonas para mostrar en el mapa
const zonaDetectada = ref(null) // Zona detectada automáticamente

// Computed: calcular radio desde área (A = πr² → r = √(A/π))
const radioCalculado = computed(() => {
  if (!proyectoActual.value.area_km2 || proyectoActual.value.area_km2 <= 0) return 0.56
  return Math.sqrt(proyectoActual.value.area_km2 / Math.PI)
})

const cargarZonas = async () => {
  try {
    const response = await ZonaService.obtenerTodos()
    zonaSeleccionada.value = response.data
      .map(z => {
        let coordParsed = null
        if (z.coordenadas && typeof z.coordenadas === 'string') {
          try {
            coordParsed = JSON.parse(z.coordenadas)
          } catch (e) {
            // No es JSON válido, ignorar
          }
        } else if (z.coordenadas && typeof z.coordenadas === 'object') {
          coordParsed = z.coordenadas
        }
        
        if (coordParsed && coordParsed.center && coordParsed.radius) {
          return {
            id_zona: z.id_zona,
            nombre: z.nombre,
            tipo: z.tipo_zona,
            center: coordParsed.center,
            radius: coordParsed.radius
          }
        }
        return null
      })
      .filter(z => z !== null)
    console.log('✅ Zonas cargadas para proyectos:', zonaSeleccionada.value.length)
  } catch (error) {
    console.error('❌ Error al cargar zonas:', error)
  }
}

// Detectar en qué zona está el centro del proyecto
const detectarZona = (coordenadas) => {
  if (!coordenadas || coordenadas.length !== 2) {
    zonaDetectada.value = null
    proyectoActual.value.id_zona = null
    return
  }

  const [lat, lng] = coordenadas
  
  // Buscar zona que contenga el punto
  for (const zona of zonaSeleccionada.value) {
    if (zona.center && zona.radius) {
      // Círculo: usar distancia Haversine
      const distance = haversineDistance(lat, lng, zona.center[0], zona.center[1])
      if (distance <= zona.radius) {
        zonaDetectada.value = zona
        proyectoActual.value.id_zona = zona.id_zona
        console.log(`✅ Proyecto asignado a zona "${zona.nombre}" (ID: ${zona.id_zona})`)
        return
      }
    }
  }
  
  // No está en ninguna zona
  zonaDetectada.value = null
  proyectoActual.value.id_zona = null
  console.log('⚠️ Proyecto fuera de todas las zonas - id_zona = null')
}

// Fórmula de Haversine para calcular distancia entre dos puntos
const haversineDistance = (lat1, lon1, lat2, lon2) => {
  const R = 6371 // Radio de la Tierra en km
  const dLat = (lat2 - lat1) * Math.PI / 180
  const dLon = (lon2 - lon1) * Math.PI / 180
  const a = 
    Math.sin(dLat/2) * Math.sin(dLat/2) +
    Math.cos(lat1 * Math.PI / 180) * Math.cos(lat2 * Math.PI / 180) *
    Math.sin(dLon/2) * Math.sin(dLon/2)
  const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a))
  return R * c
}

// Watch para detectar zona automáticamente cuando cambia el centro
watch(centro, (newCentro) => {
  if (newCentro) {
    detectarZona(newCentro)
  } else {
    zonaDetectada.value = null
    proyectoActual.value.id_zona = null
  }
})

const cargar = async () => {
  cargando.value = true
  error.value = ''

  try {
    console.log('Cargando proyectos paginados... Token:', localStorage.getItem('token') ? 'presente' : 'ausente')
    const response = await ProyectoService.obtenerPaginado(page.value, size.value)
    proyectos.value = response.data.proyectos
    page.value = response.data.currentPage
    totalPages.value = response.data.totalPages
    totalItems.value = response.data.totalItems
    console.log('Proyectos cargados:', proyectos.value.length)
  } catch (e) {
    console.error('Error al cargar proyectos:', e)
    if (e?.response?.status === 403) {
      error.value = 'No tienes permisos para acceder a los proyectos. Por favor, verifica tu sesión.'
    } else {
      error.value = 'No se pudieron cargar los proyectos.'
    }
  } finally {
    cargando.value = false
  }
}

const aplicarFiltros = async () => {
  // Si no hay ningún filtro activo, cargar todos
  if (!estadoFiltro.value && !nombreFiltro.value) {
    cargar()
    return
  }
  
  cargando.value = true
  error.value = ''
  
  try {
    let response
    
    // Si hay ambos filtros
    if (estadoFiltro.value && nombreFiltro.value) {
      // Buscar por estado primero
      response = await ProyectoService.obtenerPorEstado(estadoFiltro.value)
      // Filtrar por nombre en el cliente
      proyectos.value = response.data.filter(p => 
        p.nombre.toLowerCase().includes(nombreFiltro.value.toLowerCase())
      )
    }
    // Solo estado
    else if (estadoFiltro.value) {
      response = await ProyectoService.obtenerPorEstado(estadoFiltro.value)
      proyectos.value = response.data
    }
    // Solo nombre
    else if (nombreFiltro.value) {
      response = await ProyectoService.obtenerPorNombre(nombreFiltro.value)
      proyectos.value = response.data
    }
    
    totalPages.value = 1
    totalItems.value = proyectos.value.length
  } catch (e) {
    console.error(e)
    error.value = 'Error al aplicar filtros.'
  } finally {
    cargando.value = false
  }
}

const limpiarFiltros = () => {
  estadoFiltro.value = ''
  nombreFiltro.value = ''
  cargar()
}

const abrirModalCrear = () => {
  editando.value = false
  proyectoActual.value = {
    nombre: '',
    descripcion: '',
    fecha_inicio: '',
    fecha_fin: '',
    estado: 'Planeado',
    id_zona: null,
    id_usuario: null,
    area_km2: 0.01
  }
  centro.value = null
  zonaDetectada.value = null
  cargarZonas() // Cargar zonas al abrir modal
  showModal.value = true
}

const abrirModalEditar = (proyecto) => {
  editando.value = true
  proyectoActual.value = { ...proyecto, area_km2: proyecto.area_km2 || 0.01 }
  centro.value = null
  cargarZonas() // Cargar zonas al abrir modal
  showModal.value = true
}

// Convertir círculo a polígono (aproximación con N puntos)
const circuloAPoligono = (center, radiusKm, numPuntos = 32) => {
  const [lat, lng] = center
  const points = []
  const R = 6371 // Radio de la Tierra en km
  
  for (let i = 0; i < numPuntos; i++) {
    const angle = (i * 360 / numPuntos) * Math.PI / 180
    
    // Calcular nuevo punto usando fórmula de destino
    const latRad = lat * Math.PI / 180
    const dLat = radiusKm * Math.cos(angle) / R
    const dLng = radiusKm * Math.sin(angle) / (R * Math.cos(latRad))
    
    const newLat = lat + (dLat * 180 / Math.PI)
    const newLng = lng + (dLng * 180 / Math.PI)
    
    points.push([newLat, newLng])
  }
  
  // Cerrar el polígono (último punto = primer punto)
  points.push(points[0])
  return points
}

// Convertir array de coordenadas a formato WKT POLYGON
const coordsToWKT = (coords) => {
  // coords es array de [lat, lng]
  // WKT necesita formato: POLYGON((lng lat, lng lat, ...))
  const wktPoints = coords.map(coord => `${coord[1]} ${coord[0]}`).join(', ')
  return `POLYGON((${wktPoints}))`
}

const guardar = async () => {
  try {
    // Validar que haya centro para generar el polígono del área
    if (!centro.value) {
      alert('⚠️ Debes seleccionar el centro del proyecto en el mapa')
      return
    }
    
    // Calcular radio desde área
    const radioKm = radioCalculado.value
    
    // Generar polígono aproximado del círculo para el área del proyecto
    const poligonoCoords = circuloAPoligono(centro.value, radioKm)
    
    // Convertir a formato WKT para PostGIS
    const ubicacionWKT = coordsToWKT(poligonoCoords)
    
    // Limpiar datos: convertir strings vacíos a null para campos numéricos
    const datosLimpios = {
      nombre: proyectoActual.value.nombre,
      descripcion: proyectoActual.value.descripcion,
      fecha_inicio: proyectoActual.value.fecha_inicio,
      fecha_fin: proyectoActual.value.fecha_fin,
      estado: proyectoActual.value.estado,
      id_zona: proyectoActual.value.id_zona === '' || proyectoActual.value.id_zona === null 
        ? null 
        : Number(proyectoActual.value.id_zona),
      id_usuario: proyectoActual.value.id_usuario === '' || proyectoActual.value.id_usuario === null 
        ? null 
        : Number(proyectoActual.value.id_usuario),
      ubicacion: ubicacionWKT // WKT string para PostGIS
    }
    
    console.log('📤 Enviando proyecto con área circular (WKT):', datosLimpios)
    
    if (editando.value) {
      const id = proyectoActual.value.id_proyectos || proyectoActual.value.id
      await ProyectoService.actualizar(id, datosLimpios)
    } else {
      await ProyectoService.crear(datosLimpios)
    }
    showModal.value = false
    await cargar()
  } catch (e) {
    console.error('Error al guardar:', e)
    alert('Error al guardar el proyecto: ' + (e.response?.data?.message || e.message))
  }
}

const eliminar = async (proyecto) => {
  if (!confirm(`¿Está seguro de eliminar el proyecto "${proyecto.nombre}"?`)) return
  
  try {
    const id = proyecto.id_proyectos || proyecto.id
    await ProyectoService.eliminar(id)
    await cargar()
  } catch (e) {
    console.error(e)
    alert('Error al eliminar el proyecto')
  }
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

const formatearFecha = (fecha) => {
  if (!fecha) return '-'
  try {
    return new Date(fecha).toLocaleDateString('es-CL')
  } catch {
    return String(fecha)
  }
}

const badgeClass = (estado) => {
  const e = String(estado || '').toLowerCase()
  if (e === 'planeado' || e === 'planeada') return 'badge gray'
  if (e === 'en curso' || e.includes('curso')) return 'badge amber'
  if (e === 'completado' || e === 'completada') return 'badge green'
  if (e === 'retrasado' || e === 'retrasada') return 'badge red'
  return 'badge'
}

onMounted(cargar)
</script>

<template>
  <div class="page">
    <div class="page-head">
      <div>
        <h3>Gestión de Proyectos</h3>
        <p>CRUD completo de proyectos urbanos con paginación.</p>
      </div>
      <button @click="abrirModalCrear" class="btn primary">+ Nuevo Proyecto</button>
    </div>

    <!-- Filtros -->
    <div class="filters-card card">
      <h4>Filtros</h4>
      <div class="filters">
        <div class="filter-group">
          <label>Estado:</label>
          <select v-model="estadoFiltro" class="select">
            <option value="">Todos</option>
            <option value="Planeado">Planeado</option>
            <option value="En Curso">En Curso</option>
            <option value="Completado">Completado</option>
            <option value="Retrasado">Retrasado</option>
          </select>
        </div>
        <div class="filter-group">
          <label>Nombre:</label>
          <input type="text" v-model="nombreFiltro" placeholder="Buscar..." class="input" />
        </div>
        <button @click="aplicarFiltros" class="btn secondary">Buscar</button>
        <button @click="limpiarFiltros" class="btn">Limpiar</button>
      </div>
    </div>

    <div v-if="error" class="alert error">{{ error }}</div>

    <div v-else-if="cargando" class="alert">
      Cargando proyectos…
    </div>

    <!-- Tabla de proyectos -->
    <div v-else class="card">
      <div class="table-container">
        <table class="table">
          <thead>
            <tr>
              <th>Nombre</th>
              <th>Estado</th>
              <th>Fecha Inicio</th>
              <th>Fecha Fin</th>
              <th>Zona</th>
              <th>Acciones</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="proy in proyectos" :key="proy.id_proyectos || proy.id">
              <td>
                <strong>{{ proy.nombre }}</strong>
                <div style="font-size: 11px; opacity: 0.7;">{{ proy.descripcion }}</div>
              </td>
              <td><span :class="badgeClass(proy.estado)">{{ proy.estado }}</span></td>
              <td>{{ formatearFecha(proy.fecha_inicio) }}</td>
              <td>{{ formatearFecha(proy.fecha_fin) }}</td>
              <td>{{ proy.id_zona }}</td>
              <td>
                <div class="actions-cell">
                  <button @click="abrirModalEditar(proy)" class="btn-icon" title="Editar">
                    ✏️
                  </button>
                  <button @click="eliminar(proy)" class="btn-icon danger" title="Eliminar">
                    🗑️
                  </button>
                </div>
              </td>
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
          Página {{ page + 1 }} de {{ totalPages }} ({{ totalItems }} proyectos)
        </span>
        <button @click="siguientePagina" :disabled="page >= totalPages - 1" class="btn secondary">
          Siguiente →
        </button>
      </div>
    </div>

    <!-- Modal -->
    <div v-if="showModal" class="modal-overlay" @click.self="showModal = false">
      <div class="modal">
        <h3>{{ editando ? 'Editar Proyecto' : 'Nuevo Proyecto' }}</h3>
        <form @submit.prevent="guardar" class="form">
          <div class="form-group">
            <label>Nombre *</label>
            <input v-model="proyectoActual.nombre" required class="input" />
          </div>
          
          <div class="form-group">
            <label>Descripción</label>
            <textarea v-model="proyectoActual.descripcion" class="input" rows="3"></textarea>
          </div>

          <div class="form-row">
            <div class="form-group">
              <label>Fecha Inicio</label>
              <input type="date" v-model="proyectoActual.fecha_inicio" class="input" />
            </div>
            
            <div class="form-group">
              <label>Fecha Fin</label>
              <input type="date" v-model="proyectoActual.fecha_fin" class="input" />
            </div>
          </div>

          <div class="form-row">
            <div class="form-group">
              <label>Estado</label>
              <select v-model="proyectoActual.estado" class="input">
                <option value="Planeado">Planeado</option>
                <option value="En Curso">En Curso</option>
                <option value="Completado">Completado</option>
                <option value="Retrasado">Retrasado</option>
              </select>
            </div>
            
            <div class="form-group">
              <label>Zona Asignada</label>
              <div class="input" style="background: rgba(255,255,255,0.03); cursor: not-allowed;">
                <span v-if="zonaDetectada">🟢 {{ zonaDetectada.nombre }} (ID: {{ zonaDetectada.id_zona }})</span>
                <span v-else style="opacity: 0.5;">⚫ Fuera de zonas / Sin asignar</span>
              </div>
              <small style="opacity: 0.7; font-size: 11px; display: block; margin-top: 4px;">
                🎯 Se asigna automáticamente según el centro del proyecto
              </small>
            </div>
          </div>

          <div class="form-group">
            <label>ID Usuario (opcional)</label>
            <input type="number" v-model.number="proyectoActual.id_usuario" class="input" placeholder="Dejar vacío si no aplica" />
          </div>

          <div class="form-group">
            <label>Área del Proyecto (km²) *</label>
            <input 
              type="number" 
              step="0.01" 
              min="0.01"
              v-model.number="proyectoActual.area_km2" 
              required 
              class="input" 
              placeholder="Ejemplo: 5.25"
            />
            <small style="opacity: 0.7; font-size: 11px; display: block; margin-top: 4px;">
              <strong>Obligatorio:</strong> Define el área del proyecto. Radio calculado: {{ radioCalculado.toFixed(2) }} km
            </small>
          </div>

          <div class="form-group">
            <label>🌍 Centro del Área del Proyecto *</label>
            <p style="font-size: 12px; opacity: 0.7; margin: 4px 0 8px;">Haz clic en el mapa para marcar el centro del área circular del proyecto</p>
            <MapPicker v-model="centro" :radius="radioCalculado" mode="circle" :allZones="zonaSeleccionada" />
          </div>

          <div class="modal-actions">
            <button type="button" @click="showModal = false" class="btn">Cancelar</button>
            <button type="submit" class="btn primary">Guardar</button>
          </div>
        </form>
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

.input, .select {
  height: 38px;
  padding: 0 12px;
  border-radius: 8px;
  border: 1px solid rgba(255,255,255,.12);
  background-color: rgba(255,255,255,.06);
  color: #eaf0ff;
  outline: none;
  min-width: 150px;
}

select.input {
  cursor: pointer;
  appearance: none;
  background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='18' height='18' viewBox='0 0 24 24' fill='none' stroke='%23eaf0ff' stroke-width='2' stroke-linecap='round' stroke-linejoin='round'%3E%3Cpolyline points='6 9 12 15 18 9'/%3E%3C/svg%3E");
  background-repeat: no-repeat;
  background-position: right 12px center;
  background-size: 16px 16px;
  padding-right: 40px;
}

/* Estilos para las opciones del select */
select.input option {
  background-color: #1e2333;
  color: #eaf0ff;
  padding: 10px;
}

select.input option:checked {
  background-color: #3498db;
  color: white;
}

select.input option:hover {
  background-color: #2c3444;
}

textarea.input {
  height: auto;
  padding: 10px 12px;
  font-family: inherit;
}

.input:focus, .select:focus {
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

.actions-cell {
  display: flex;
  gap: 8px;
}

.btn-icon {
  background: none;
  border: none;
  cursor: pointer;
  font-size: 16px;
  padding: 4px 8px;
  border-radius: 6px;
  transition: background 0.2s;
}

.btn-icon:hover {
  background-color: rgba(255,255,255,.1);
}

.btn-icon.danger:hover {
  background-color: rgba(239,68,68,.2);
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

.badge {
  padding: 4px 10px;
  border-radius: 12px;
  font-size: 11px;
  font-weight: 600;
  display: inline-block;
}

.badge.gray {
  background: rgba(156, 163, 175, 0.2);
  color: rgb(209, 213, 219);
}

.badge.amber {
  background: rgba(251, 191, 36, 0.2);
  color: rgb(252, 211, 77);
}

.badge.green {
  background: rgba(16, 185, 129, 0.2);
  color: rgb(52, 211, 153);
}

.badge.red {
  background: rgba(239, 68, 68, 0.2);
  color: rgb(248, 113, 113);
}

/* Modal */
.modal-overlay {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background-color: rgba(0, 0, 0, 0.7);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 1000;
}

.modal {
  background-color: #1a1f2e;
  padding: 24px;
  border-radius: 16px;
  max-width: 600px;
  width: 90%;
  max-height: 90vh;
  overflow-y: auto;
}

.modal h3 {
  margin: 0 0 20px;
}

.form {
  display: grid;
  gap: 16px;
}

.form-group {
  display: flex;
  flex-direction: column;
  gap: 6px;
}

.form-group label {
  font-size: 13px;
  opacity: 0.9;
}

.form-row {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 16px;
}

.modal-actions {
  display: flex;
  gap: 12px;
  justify-content: flex-end;
  margin-top: 8px;
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
