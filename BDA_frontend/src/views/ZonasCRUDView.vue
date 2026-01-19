<template>
  <div class="page">
    <div class="page-head">
      <h3>🏙️ Gestión de Zonas Urbanas</h3>
      
      <button @click="abrirModalCrear" class="btn primary">+ Nueva Zona</button>
    </div>

    <div class="card">
      <div class="table-container">
        <table class="table">
          <thead>
            <tr>
              <th>ID</th>
              <th>Nombre</th>
              <th>Tipo</th>
              <th>Área (km²)</th>
              <th>Acciones</th>
            </tr>
          </thead>
          <tbody>
            <tr v-if="cargando">
              <td colspan="5" style="text-align: center; padding: 40px;">Cargando...</td>
            </tr>
            <tr v-else-if="zonas.length === 0">
              <td colspan="5" style="text-align: center; padding: 40px;">No hay zonas</td>
            </tr>
            <tr v-else v-for="zona in zonas" :key="zona.id_zona || zona.id">
              <td>{{ zona.id_zona || zona.id }}</td>
              <td>{{ zona.nombre }}</td>
              <td><span :class="badgeClass(zona.tipo_zona)">{{ zona.tipo_zona }}</span></td>
              <td>{{ zona.area_km2 || 'N/A' }}</td>
              <td class="actions-cell">
                <button @click="abrirModalEditar(zona)" class="btn-icon">✏️</button>
                <button @click="eliminar(zona)" class="btn-icon danger">🗑️</button>
              </td>
            </tr>
          </tbody>
        </table>
      </div>

      <div class="pagination">
        <button @click="paginaAnterior" :disabled="page <= 0" class="btn secondary">
          ← Anterior
        </button>
        <span class="page-info">
          Página {{ page + 1 }} de {{ totalPages }} ({{ totalItems }} zonas)
        </span>
        <button @click="siguientePagina" :disabled="page >= totalPages - 1" class="btn secondary">
          Siguiente →
        </button>
      </div>
    </div>

    <!-- Modal -->
    <div v-if="showModal" class="modal-overlay" @click.self="showModal = false">
      <div class="modal">
        <h3>{{ editando ? 'Editar Zona' : 'Nueva Zona' }}</h3>
        <form @submit.prevent="guardar" class="form">
          <div class="form-group">
            <label>Nombre *</label>
            <input v-model="zonaActual.nombre" required class="input" />
          </div>
          
          <div class="form-group">
            <label>Tipo de Zona *</label>
            <select v-model="zonaActual.tipo_zona" required class="input">
              <option value="Residencial">Residencial</option>
              <option value="Comercial">Comercial</option>
              <option value="Industrial">Industrial</option>
              <option value="Mixta">Mixta</option>
            </select>
          </div>

          <div class="form-group">
            <label>Área (km²) *</label>
            <input 
              type="number" 
              step="0.01" 
              min="0.01"
              v-model.number="zonaActual.area_km2" 
              required 
              class="input" 
              placeholder="Ejemplo: 5.25"
            />
            <small style="opacity: 0.7; font-size: 11px; display: block; margin-top: 4px;">
              <strong>Obligatorio:</strong> Define el área del círculo. Radio calculado: {{ radioCalculado.toFixed(2) }} km
            </small>
          </div>

          <div class="form-group">
            <label>🌍 Centro de la Zona *</label>
            <MapPicker ref="mapPickerRef" v-model="centro" :radius="radioCalculado" mode="circle" :allZones="todasLasZonas" />
            <small style="opacity: 0.7; font-size: 11px; display: block; margin-top: 4px;">
              Haz clic en el mapa para marcar el centro de la zona circular
            </small>
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

<script setup>
import { ref, computed, onMounted } from 'vue'
import ZonaService from '@/services/ZonaService'
import MapPicker from '@/components/MapPicker.vue'

const zonas = ref([])
const cargando = ref(false)
const page = ref(0)
const size = ref(10)
const totalPages = ref(0)
const totalItems = ref(0)

const showModal = ref(false)
const editando = ref(false)
const zonaActual = ref({
  nombre: '',
  tipo_zona: 'Residencial',
  area_km2: 1.0
})

const centro = ref(null)
const mapPickerRef = ref(null)
const todasLasZonas = ref([]) // Para mostrar en el mapa

// Computed: calcular radio desde área (A = πr² → r = √(A/π))
const radioCalculado = computed(() => {
  if (!zonaActual.value.area_km2 || zonaActual.value.area_km2 <= 0) return 0.56  // radio para área ~1km²
  return Math.sqrt(zonaActual.value.area_km2 / Math.PI)
})

const cargar = async () => {
  cargando.value = true
  
  try {
    const response = await ZonaService.obtenerPaginado(page.value, size.value)
    zonas.value = response.data.zonas
    page.value = response.data.currentPage
    totalPages.value = response.data.totalPages
    totalItems.value = response.data.totalItems
  } catch (e) {
    console.error('Error al cargar zonas:', e)
  } finally {
    cargando.value = false
  }
}

const cargarTodasLasZonas = async () => {
  try {
    const response = await ZonaService.obtenerTodos()
    todasLasZonas.value = response.data
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
    console.log('✅ Zonas cargadas para referencia:', todasLasZonas.value.length)
  } catch (error) {
    console.error('❌ Error al cargar zonas:', error)
  }
}

const abrirModalCrear = () => {
  editando.value = false
  zonaActual.value = {
    nombre: '',
    tipo_zona: 'Residencial',
    area_km2: 1.0
  }
  centro.value = null
  cargarTodasLasZonas() // Cargar zonas existentes para mostrar en el mapa
  showModal.value = true
}

const abrirModalEditar = (zona) => {
  editando.value = true
  zonaActual.value = { ...zona }
  
  // Cargar centro desde coordenadas si existen
  if (zona.coordenadas) {
    try {
      const data = typeof zona.coordenadas === 'string' ? JSON.parse(zona.coordenadas) : zona.coordenadas
      if (data.center) {
        centro.value = data.center
      } else {
        centro.value = null
      }
    } catch (e) {
      console.warn('Error al parsear coordenadas:', e)
      centro.value = null
    }
  } else {
    centro.value = null
  }
  
  cargarTodasLasZonas() // Cargar zonas existentes para mostrar en el mapa
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

const guardar = async () => {
  try {
    // Validar que haya centro y área
    if (!centro.value || !zonaActual.value.area_km2 || zonaActual.value.area_km2 <= 0) {
      alert('⚠️ Debes seleccionar el centro de la zona en el mapa y definir un área válida')
      return
    }
    
    // Calcular radio desde área
    const radioKm = radioCalculado.value
    
    // Generar polígono aproximado del círculo
    const poligonoCoords = circuloAPoligono(centro.value, radioKm)
    
    const datos = {
      ...zonaActual.value,
      coordenadas: JSON.stringify({
        center: centro.value,
        radius: radioKm
      }),
      latitud: centro.value[0],
      longitud: centro.value[1],
      radio: radioKm,
      poligono: poligonoCoords,
      area_km2: Number(zonaActual.value.area_km2)
    }
    
    console.log('📤 Enviando datos al backend:', datos)
    
    if (editando.value) {
      const id = zonaActual.value.id_zona || zonaActual.value.id
      await ZonaService.actualizar(id, datos)
    } else {
      await ZonaService.crear(datos)
    }
    showModal.value = false
    await cargar()
  } catch (e) {
    console.error('Error al guardar:', e)
    alert('Error al guardar la zona: ' + (e.response?.data?.message || e.message))
  }
}

const eliminar = async (zona) => {
  if (!confirm(`¿Está seguro de eliminar la zona "${zona.nombre}"?`)) return
  
  try {
    const id = zona.id_zona || zona.id
    await ZonaService.eliminar(id)
    await cargar()
  } catch (e) {
    console.error('Error al eliminar:', e)
    alert('Error al eliminar la zona')
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

const badgeClass = (tipo) => {
  if (tipo === 'Residencial') return 'badge blue'
  if (tipo === 'Comercial') return 'badge red'
  if (tipo === 'Industrial') return 'badge gray'
  if (tipo === 'Mixta') return 'badge purple'
  return 'badge'
}

onMounted(cargar)
</script>

<style scoped>
.page { display: grid; gap: 16px; }
.page-head {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.card {
  border-radius: 16px;
  border: 1px solid rgba(255,255,255,.10);
  background: rgba(255,255,255,.03);
  overflow: hidden;
}

.btn {
  height: 38px;
  padding: 0 18px;
  border-radius: 10px;
  border: 1px solid rgba(255,255,255,.12);
  background-color: rgba(255,255,255,.06);
  color: #eaf0ff;
  cursor: pointer;
  font-weight: 500;
  transition: all 0.2s;
}

.btn:hover { background-color: rgba(255,255,255,.10); }
.btn.primary {
  background: linear-gradient(135deg, #42b983 0%, #35a372 100%);
  border-color: transparent;
}
.btn.secondary { opacity: 0.7; }
.btn:disabled { opacity: 0.3; cursor: not-allowed; }

.input, textarea.input {
  padding: 0 12px;
  border-radius: 8px;
  border: 1px solid rgba(255,255,255,.12);
  background-color: rgba(255,255,255,.06);
  color: #eaf0ff;
  outline: none;
  width: 100%;
}

.input { height: 38px; }
textarea.input {
  padding: 10px 12px;
  font-family: inherit;
  resize: vertical;
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

select.input option {
  background-color: #1e2333;
  color: #eaf0ff;
}

.input:focus {
  border-color: rgba(66,185,131,.35);
  box-shadow: 0 0 0 3px rgba(66,185,131,.12);
}

.table-container { overflow-x: auto; }
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

.table tbody tr:hover { background-color: rgba(255,255,255,.03); }

.actions-cell { display: flex; gap: 8px; }
.btn-icon {
  background: none;
  border: none;
  cursor: pointer;
  font-size: 16px;
  padding: 4px 8px;
  border-radius: 6px;
  transition: background 0.2s;
}

.btn-icon:hover { background-color: rgba(255,255,255,.1); }
.btn-icon.danger:hover { background-color: rgba(239,68,68,.2); }

.pagination {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 16px;
  border-top: 1px solid rgba(255,255,255,.08);
}

.page-info { font-size: 13px; opacity: 0.8; }

.badge {
  padding: 4px 10px;
  border-radius: 12px;
  font-size: 11px;
  font-weight: 600;
  display: inline-block;
}

.badge.blue {
  background: rgba(59, 130, 246, 0.2);
  color: rgb(96, 165, 250);
}

.badge.red {
  background: rgba(239, 68, 68, 0.2);
  color: rgb(248, 113, 113);
}

.badge.gray {
  background: rgba(156, 163, 175, 0.2);
  color: rgb(209, 213, 219);
}

.badge.purple {
  background: rgba(168, 85, 247, 0.2);
  color: rgb(192, 132, 252);
}

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
  max-width: 550px;
  width: 90%;
  max-height: 90vh;
  overflow-y: auto;
}

.modal h3 { margin: 0 0 20px; }

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

.modal-actions {
  display: flex;
  gap: 12px;
  justify-content: flex-end;
  margin-top: 8px;
}
</style>
