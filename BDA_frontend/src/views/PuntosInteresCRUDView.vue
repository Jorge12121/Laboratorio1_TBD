<template>
  <div class="page">
    <div class="page-head">
      <h3>📍 Gestión de Puntos de Interés</h3>
      
      <button @click="abrirModalCrear" class="btn primary">+ Nuevo Punto</button>
    </div>

    <div class="card">
      <div class="table-container">
        <table class="table">
          <thead>
            <tr>
              <th>ID</th>
              <th>Nombre</th>
              <th>Tipo</th>
              <th>Zona</th>
              <th>Acciones</th>
            </tr>
          </thead>
          <tbody>
            <tr v-if="cargando">
              <td colspan="5" style="text-align: center; padding: 40px;">Cargando...</td>
            </tr>
            <tr v-else-if="puntos.length === 0">
              <td colspan="5" style="text-align: center; padding: 40px;">No hay puntos de interés</td>
            </tr>
            <tr v-else v-for="punto in puntos" :key="punto.id_punto || punto.id">
              <td>{{ punto.id_punto || punto.id }}</td>
              <td>{{ punto.nombre }}</td>
              <td><span :class="badgeClass(punto.tipo)">{{ punto.tipo }}</span></td>
              <td>{{ punto.id_zona || 'N/A' }}</td>
              <td class="actions-cell">
                <button @click="abrirModalEditar(punto)" class="btn-icon">✏️</button>
                <button @click="eliminar(punto)" class="btn-icon danger">🗑️</button>
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
          Página {{ page + 1 }} de {{ totalPages }} ({{ totalItems }} puntos)
        </span>
        <button @click="siguientePagina" :disabled="page >= totalPages - 1" class="btn secondary">
          Siguiente →
        </button>
      </div>
    </div>

    <!-- Modal -->
    <div v-if="showModal" class="modal-overlay" @click.self="showModal = false">
      <div class="modal">
        <h3>{{ editando ? 'Editar Punto' : 'Nuevo Punto' }}</h3>
        <form @submit.prevent="guardar" class="form">
          <div class="form-group">
            <label>Nombre *</label>
            <input v-model="puntoActual.nombre" required class="input" />
          </div>
          
          <div class="form-group">
            <label>Tipo *</label>
            <select v-model="puntoActual.tipo" required class="input">
              <option value="Escuela">Escuela</option>
              <option value="Hospital">Hospital</option>
              <option value="Parque">Parque</option>
              <option value="Otro">Otro</option>
            </select>
          </div>

          <div class="form-group">
            <label>📍 Ubicación en el Mapa</label>
            <MapPicker v-model="ubicacion" mode="point" :allZones="todasLasZonas" />
            <div v-if="zonaDetectada" style="margin-top: 8px; padding: 12px; background: rgba(46, 204, 113, 0.15); border-left: 3px solid #2ecc71; border-radius: 6px;">
              <div style="font-size: 13px; font-weight: 600; color: #2ecc71; margin-bottom: 4px;">✅ Zona detectada automáticamente</div>
              <div style="font-size: 12px; opacity: 0.9;">
                <strong>{{ zonaDetectada.nombre }}</strong> (ID: {{ zonaDetectada.id }})
              </div>
              <div style="font-size: 11px; opacity: 0.7; margin-top: 4px;">
                Tipo: {{ zonaDetectada.tipo }}
              </div>
            </div>
            <div v-else-if="ubicacion" style="margin-top: 8px; padding: 12px; background: rgba(231, 76, 60, 0.15); border-left: 3px solid #e74c3c; border-radius: 6px;">
              <div style="font-size: 13px; font-weight: 600; color: #e74c3c; margin-bottom: 4px;">⚠️ Punto fuera de zonas</div>
              <div style="font-size: 12px; opacity: 0.9;">
                El marcador está fuera de todas las zonas urbanas. Muévelo dentro de una zona (áreas de colores).
              </div>
            </div>
            <div v-else style="margin-top: 8px; padding: 12px; background: rgba(52, 152, 219, 0.15); border-left: 3px solid #3498db; border-radius: 6px;">
              <div style="font-size: 12px; opacity: 0.9;">
                👆 Haz clic en el mapa para seleccionar ubicación. Las áreas de colores son las zonas urbanas.
              </div>
            </div>
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
import { ref, onMounted, watch } from 'vue'
import PuntoInteresService from '@/services/PuntoInteresService'
import ZonaService from '@/services/ZonaService'
import MapPicker from '@/components/MapPicker.vue'

const puntos = ref([])
const cargando = ref(false)
const page = ref(0)
const size = ref(10)
const totalPages = ref(0)
const totalItems = ref(0)

const showModal = ref(false)
const editando = ref(false)
const puntoActual = ref({
  nombre: '',
  tipo: 'Escuela',
  id_zona: null
})

const ubicacion = ref(null)
const todasLasZonas = ref([])
const zonaDetectada = ref(null)

const cargar = async () => {
  cargando.value = true
  
  try {
    const response = await PuntoInteresService.obtenerPaginado(page.value, size.value)
    puntos.value = response.data.puntos
    page.value = response.data.currentPage
    totalPages.value = response.data.totalPages
    totalItems.value = response.data.totalItems
  } catch (e) {
    console.error('Error al cargar puntos:', e)
  } finally {
    cargando.value = false
  }
}

const abrirModalCrear = () => {
  editando.value = false
  puntoActual.value = {
    nombre: '',
    tipo: 'Escuela',
    id_zona: null
  }
  ubicacion.value = null
  zonaDetectada.value = null
  console.log('🆕 Modal de creación abierto')
  showModal.value = true
}

const abrirModalEditar = (punto) => {
  console.log('✏️ === ABRIENDO MODAL DE EDICIÓN ===')
  console.log('Punto:', punto)
  
  editando.value = true
  puntoActual.value = { ...punto }
  
  // Cargar coordenadas existentes en el mapa si existen
  if (punto.latitud && punto.longitud) {
    ubicacion.value = [punto.latitud, punto.longitud]
    console.log('📍 Ubicación cargada:', ubicacion.value)
  } else {
    ubicacion.value = null
    console.log('⚠️ Sin ubicación previa')
  }
  
  // Limpiar zona detectada al editar
  zonaDetectada.value = null
  
  console.log('🔔 === ABRIENDO MODAL ===')
  console.log('🔔 todasLasZonas al abrir modal:', todasLasZonas.value.length, 'zonas')
  console.log('🔔 Zonas:', JSON.stringify(todasLasZonas.value, null, 2))
  
  showModal.value = true
  
  // Forzar actualización después de que el modal se muestre
  setTimeout(() => {
    console.log('🔔 Modal montado, todasLasZonas:', todasLasZonas.value.length)
  }, 100)
}

const guardar = async () => {
  try {
    console.log('💾 === GUARDANDO PUNTO ===')
    console.log('Editando:', editando.value)
    console.log('Ubicación actual:', ubicacion.value)
    console.log('Punto actual:', puntoActual.value)
    
    // Validar ubicación solo si es creación Y no hay ubicación
    if (!editando.value) {
      // Creación: SIEMPRE requiere ubicación
      if (!ubicacion.value || ubicacion.value.length !== 2) {
        alert('⚠️ Debes seleccionar una ubicación en el mapa');
        console.warn('❌ Validación fallida: ubicacion.value =', ubicacion.value)
        return;
      }
    }

    const datos = {
      nombre: puntoActual.value.nombre,
      tipo: puntoActual.value.tipo,
      id_zona: puntoActual.value.id_zona === '' || puntoActual.value.id_zona === null 
        ? null 
        : Number(puntoActual.value.id_zona)
    }
    
    // Solo agregar coordenadas si hay ubicación nueva o es creación
    if (ubicacion.value && ubicacion.value.length === 2) {
      datos.latitud = ubicacion.value[0]
      datos.longitud = ubicacion.value[1]
      console.log('✅ Añadiendo coordenadas:', datos.latitud, datos.longitud)
    } else if (editando.value) {
      // Si estamos editando y no hay nueva ubicación, mantener la original
      datos.latitud = puntoActual.value.latitud
      datos.longitud = puntoActual.value.longitud
      console.log('♻️ Manteniendo coordenadas originales')
    }
    
    console.log('📤 Datos a enviar:', datos)
    
    if (editando.value) {
      const id = puntoActual.value.id_punto || puntoActual.value.id
      console.log('🔄 Actualizando punto ID:', id)
      await PuntoInteresService.actualizar(id, datos)
    } else {
      console.log('➕ Creando nuevo punto')
      await PuntoInteresService.crear(datos)
    }
    
    console.log('✅ Guardado exitoso')
    showModal.value = false
    await cargar()
  } catch (e) {
    console.error('❌ Error al guardar:', e)
    console.error('Response:', e.response?.data)
    console.error('Status:', e.response?.status)
    console.error('Headers:', e.response?.headers)
    
    const errorMsg = e.response?.data?.message || e.message || String(e);
    
    // Manejar error 403 específicamente
    if (e.response?.status === 403) {
      const token = localStorage.getItem('token')
      if (!token) {
        alert('❌ No hay token de autenticación. Por favor, inicia sesión nuevamente.');
        window.location.href = '/login';
      } else {
        console.error('Token presente pero rechazado. Token:', token.substring(0, 20) + '...')
        alert('❌ Error de autenticación (403 Forbidden).\n\n' +
              'El servidor rechazó la petición. Esto puede deberse a:\n' +
              '1. Tu sesión ha expirado\n' +
              '2. No tienes permisos para esta operación\n\n' +
              'Por favor, cierra sesión e inicia sesión nuevamente.');
      }
      return;
    }
    
    // Detectar error de validación de zona
    if (errorMsg.includes('debe estar dentro de la zona') || errorMsg.includes('validar_punto_en_zona')) {
      alert('🚫 El punto seleccionado debe estar DENTRO de la zona urbana asignada (ID Zona: ' + 
            puntoActual.value.id_zona + ').\n\n' +
            '💡 Soluciones:\n' +
            '1. Deja el campo "ID Zona" vacío para crear el punto sin zona\n' +
            '2. Selecciona una ubicación que esté dentro de la zona especificada');
    } else {
      alert('❌ Error al guardar el punto: ' + errorMsg);
    }
  }
}

const eliminar = async (punto) => {
  if (!confirm(`¿Está seguro de eliminar el punto "${punto.nombre}"?`)) return
  
  try {
    const id = punto.id_punto || punto.id
    await PuntoInteresService.eliminar(id)
    await cargar()
  } catch (e) {
    console.error('Error al eliminar:', e)
    alert('Error al eliminar el punto de interés')
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
  if (tipo === 'Escuela') return 'badge blue'
  if (tipo === 'Hospital') return 'badge red'
  if (tipo === 'Parque') return 'badge green'
  if (tipo === 'Otro') return 'badge gray'
  return 'badge'
}

// Cargar todas las zonas
const cargarZonas = async () => {
  try {
    console.log('� === DIAGNÓSTICO: INICIO CARGA DE ZONAS ===')
    console.log('📡 Llamando a ZonaService.getAll()...')
    const response = await ZonaService.getAll()
    console.log('📦 Respuesta completa del backend:', response)
    const zonas = response.data
    console.log('📊 Total de zonas recibidas:', zonas?.length || 0)
    console.log('📄 Zonas raw:', JSON.stringify(zonas, null, 2))
    
    todasLasZonas.value = zonas.map((zona, index) => {
      console.log(`\n🔎 Procesando zona ${index + 1}/${zonas.length}:`, zona.nombre)
      console.log('  - ID:', zona.id_zona || zona.id)
      console.log('  - coordenadas raw:', zona.coordenadas)
      console.log('  - geom:', zona.geom)
      
      let zoneData = null
      
      if (zona.coordenadas) {
        try {
          console.log('  📝 Intentando parsear coordenadas...')
          const parsed = typeof zona.coordenadas === 'string' 
            ? JSON.parse(zona.coordenadas) 
            : zona.coordenadas
          console.log('  ✅ Parsed:', parsed)
          
          // Nuevo formato: {center: [lat, lng], radius: km}
          if (parsed.center && parsed.radius) {
            console.log('  🎯 Formato círculo detectado - center:', parsed.center, 'radius:', parsed.radius)
            zoneData = {
              center: parsed.center,
              radius: parsed.radius
            }
          }
          // Legacy: array de coordenadas (polígono)
          else if (Array.isArray(parsed) && parsed.length >= 3) {
            console.log('  🔷 Formato polígono detectado -', parsed.length, 'puntos')
            zoneData = {
              coords: parsed
            }
          }
          else {
            console.warn('  ⚠️ Formato de coordenadas no reconocido:', parsed)
          }
        } catch (e) {
          console.error(`  ❌ Error al parsear coordenadas:`, e)
        }
      } else {
        console.warn('  ⚠️ Esta zona NO tiene campo coordenadas')
      }
      
      const zonaFinal = {
        id: zona.id_zona || zona.id,
        nombre: zona.nombre,
        tipo: zona.tipo_zona,
        ...zoneData
      }
      console.log('  📋 Zona procesada:', zonaFinal)
      return zonaFinal
    }).filter(z => {
      const valid = (z.center && z.radius) || (z.coords && z.coords.length >= 3)
      if (!valid) {
        console.log(`ℹ️ Zona "${z.nombre}" omitida (sin coordenadas válidas en el mapa)`)
      }
      return valid
    })
    
    console.log('\n✅ === RESULTADO FINAL ===')
    console.log('✅ Zonas válidas cargadas:', todasLasZonas.value.length)
    console.log('📊 Zonas que se enviarán al MapPicker:', JSON.stringify(todasLasZonas.value, null, 2))
    
    if (todasLasZonas.value.length > 0) {
      console.log('📍 Resumen de zonas:')
      todasLasZonas.value.forEach((z, i) => {
        console.log(`  ${i + 1}. ${z.nombre} (ID: ${z.id})`)
        console.log(`     - Tipo: ${z.center ? '🔵 círculo' : '🔷 polígono'}`)
        if (z.center) console.log(`     - Centro: [${z.center[0]}, ${z.center[1]}]`)
        if (z.radius) console.log(`     - Radio: ${z.radius} km`)
        if (z.coords) console.log(`     - Puntos: ${z.coords.length}`)
      })
      console.log('🎯 Estas zonas deberían aparecer en el mapa')
    } else {
      console.error('❌ NO HAY ZONAS VÁLIDAS')
      console.warn('⚠️ SOLUCIÓN: Ve a "Zonas Urbanas" → Edita una zona → Ingresa Área → Click en mapa → Guarda')
    }
    console.log('🔍 === FIN DIAGNÓSTICO ===\n')
  } catch (e) {
    console.error('❌ Error al cargar zonas:', e)
  }
}

// Detectar en qué zona está el punto
const detectarZona = (coords) => {
  if (!coords || coords.length !== 2) {
    zonaDetectada.value = null
    return
  }
  
  const [lat, lng] = coords
  
  // Buscar en qué zona está el punto
  for (const zona of todasLasZonas.value) {
    // Zona circular
    if (zona.center && zona.radius) {
      if (isPointInCircle(lat, lng, zona.center, zona.radius)) {
        zonaDetectada.value = zona
        puntoActual.value.id_zona = zona.id
        console.log('✅ Zona detectada:', zona.nombre, '(ID:', zona.id, ')')
        return
      }
    }
    // Zona poligonal (legacy)
    else if (zona.coords && isPointInPolygon(lat, lng, zona.coords)) {
      zonaDetectada.value = zona
      puntoActual.value.id_zona = zona.id
      console.log('✅ Zona detectada:', zona.nombre, '(ID:', zona.id, ')')
      return
    }
  }
  
  zonaDetectada.value = null
  puntoActual.value.id_zona = null
  console.log('⚠️ Punto fuera de todas las zonas')
}

// Verificar si un punto está dentro de un círculo
const isPointInCircle = (lat, lng, center, radiusKm) => {
  const [centerLat, centerLng] = center
  
  // Calcular distancia usando fórmula de Haversine
  const R = 6371 // Radio de la Tierra en km
  const dLat = (lat - centerLat) * Math.PI / 180
  const dLng = (lng - centerLng) * Math.PI / 180
  const a = Math.sin(dLat/2) * Math.sin(dLat/2) +
    Math.cos(centerLat * Math.PI / 180) * Math.cos(lat * Math.PI / 180) *
    Math.sin(dLng/2) * Math.sin(dLng/2)
  const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a))
  const distance = R * c
  
  return distance <= radiusKm
}

// Algoritmo para verificar si un punto está dentro de un polígono (legacy)
const isPointInPolygon = (lat, lng, polygon) => {
  let inside = false
  for (let i = 0, j = polygon.length - 1; i < polygon.length; j = i++) {
    const xi = polygon[i][0], yi = polygon[i][1]
    const xj = polygon[j][0], yj = polygon[j][1]
    
    const intersect = ((yi > lng) !== (yj > lng)) &&
      (lat < (xj - xi) * (lng - yi) / (yj - yi) + xi)
    if (intersect) inside = !inside
  }
  return inside
}

// Watch para detectar zona cuando cambian las coordenadas
watch(ubicacion, (newCoords) => {
  if (newCoords) {
    detectarZona(newCoords)
  }
})

// Watch para monitorear cambios en todasLasZonas
watch(todasLasZonas, (newVal) => {
  console.log('🔄 === todasLasZonas CAMBIÓ ===')
  console.log('🔄 Nuevas zonas:', newVal.length)
  console.log('🔄 Datos:', JSON.stringify(newVal, null, 2))
}, { deep: true })

onMounted(async () => {
  await cargarZonas()
  await cargar()
})
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

.badge.green {
  background: rgba(34, 197, 94, 0.2);
  color: rgb(74, 222, 128);
}

.badge.gray {
  background: rgba(156, 163, 175, 0.2);
  color: rgb(209, 213, 219);
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
