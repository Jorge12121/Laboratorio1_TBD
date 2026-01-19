<template>
  <div class="map-picker">
    <div ref="mapContainer" class="map-container"></div>
    <div class="map-info" v-if="mode !== 'view'">
      <span v-if="mode === 'circle' && coordinates">
        📍 Centro: {{ coordinates[0].toFixed(6) }}, {{ coordinates[1].toFixed(6) }} | Radio: {{ radius }}km
      </span>
      <span v-else-if="coordinates">📍 Lat: {{ coordinates[0].toFixed(6) }}, Lng: {{ coordinates[1].toFixed(6) }}</span>
      <span v-else>👆 Haz clic en el mapa para seleccionar {{ mode === 'circle' ? 'centro del círculo' : mode === 'polygon' ? 'puntos del polígono' : 'ubicación' }}</span>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted, watch } from 'vue'
import L from 'leaflet'
import 'leaflet/dist/leaflet.css'

const props = defineProps({
  modelValue: {
    type: Array,
    default: null
  },
  center: {
    type: Array,
    default: () => [-33.4489, -70.6693] // Santiago, Chile
  },
  zoom: {
    type: Number,
    default: 12
  },
  mode: {
    type: String,
    default: 'point' // 'point', 'polygon', 'circle' o 'view' (solo visualización)
  },
  radius: {
    type: Number,
    default: 1 // Radio en kilómetros para modo circle
  },
  referencePolygon: {
    type: Array,
    default: null // Array de coordenadas para mostrar zona de referencia
  },
  allZones: {
    type: Array,
    default: () => [] // Array de todas las zonas [{id, nombre, tipo, center, radius}]
  }
})

const emit = defineEmits(['update:modelValue'])

const mapContainer = ref(null)
const coordinates = ref(props.modelValue)
const radius = ref(props.radius)
const map = ref(null)
const marker = ref(null)
const polygon = ref(null)
const circle = ref(null)
const polygonPoints = ref([])
const referenceLayer = ref(null)
const zoneLayers = ref([])

onMounted(() => {
  // Inicializar mapa
  map.value = L.map(mapContainer.value).setView(props.center, props.zoom)

  // Agregar capa de OpenStreetMap
  L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
    attribution: '© OpenStreetMap contributors',
    maxZoom: 19
  }).addTo(map.value)

  // Si hay coordenadas iniciales, mostrar marcador/polígono
  if (props.modelValue) {
    if (props.mode === 'point') {
      showMarker(props.modelValue)
    } else if (props.mode === 'polygon' && Array.isArray(props.modelValue[0])) {
      showPolygon(props.modelValue)
    }
  }

  // Evento de clic en el mapa (solo si NO es modo view)
  if (props.mode !== 'view') {
    map.value.on('click', (e) => {
      if (props.mode === 'point') {
        handlePointClick(e)
      } else if (props.mode === 'circle') {
        handleCircleClick(e)
      } else {
        handlePolygonClick(e)
      }
    })
  }

  // Arreglar iconos de Leaflet
  delete L.Icon.Default.prototype._getIconUrl
  L.Icon.Default.mergeOptions({
    iconRetinaUrl: 'https://unpkg.com/leaflet@1.9.4/dist/images/marker-icon-2x.png',
    iconUrl: 'https://unpkg.com/leaflet@1.9.4/dist/images/marker-icon.png',
    shadowUrl: 'https://unpkg.com/leaflet@1.9.4/dist/images/marker-shadow.png',
  })

  // Mostrar polígono de referencia si existe
  if (props.referencePolygon) {
    showReferencePolygon(props.referencePolygon)
  }
  
  // 🎯 SOLUCIÓN: Dibujar zonas DESPUÉS de que el mapa esté inicializado
  console.log('🗺️ Mapa inicializado, verificando allZones...')
  if (props.allZones && props.allZones.length > 0) {
    console.log('✅ Zonas disponibles al montar, dibujando ahora:', props.allZones.length)
    showAllZones(props.allZones)
  } else {
    console.log('⚠️ No hay zonas disponibles al montar el mapa')
  }
})

const handlePointClick = (e) => {
  const lat = e.latlng.lat
  const lng = e.latlng.lng
  coordinates.value = [lat, lng]
  showMarker([lat, lng])
  emit('update:modelValue', [lat, lng])
}

const handleCircleClick = (e) => {
  const lat = e.latlng.lat
  const lng = e.latlng.lng
  coordinates.value = [lat, lng]
  showCircle([lat, lng], props.radius)
  emit('update:modelValue', [lat, lng])
}

const handlePolygonClick = (e) => {
  const lat = e.latlng.lat
  const lng = e.latlng.lng
  polygonPoints.value.push([lat, lng])
  
  // Si hay al menos 3 puntos, dibujar polígono
  if (polygonPoints.value.length >= 3) {
    showPolygon(polygonPoints.value)
    emit('update:modelValue', polygonPoints.value)
  } else {
    // Agregar marcador temporal
    L.marker([lat, lng]).addTo(map.value)
  }
}

const showMarker = (coords) => {
  if (marker.value) {
    map.value.removeLayer(marker.value)
  }
  marker.value = L.marker(coords).addTo(map.value)
  map.value.setView(coords, props.zoom)
}

const showCircle = (center, radiusKm) => {
  // Limpiar círculo anterior
  if (circle.value) {
    map.value.removeLayer(circle.value)
  }
  if (marker.value) {
    map.value.removeLayer(marker.value)
  }
  
  // Dibujar marcador en el centro
  marker.value = L.marker(center).addTo(map.value)
  
  // Dibujar círculo (radio en metros)
  circle.value = L.circle(center, {
    radius: radiusKm * 1000, // Convertir km a metros
    color: '#42b983',
    fillColor: '#42b983',
    fillOpacity: 0.2,
    weight: 2
  }).addTo(map.value)
  
  // Centrar mapa en el círculo
  map.value.fitBounds(circle.value.getBounds())
}

const showPolygon = (points) => {
  if (polygon.value) {
    map.value.removeLayer(polygon.value)
  }
  polygon.value = L.polygon(points, {
    color: '#42b983',
    fillColor: '#42b983',
    fillOpacity: 0.3
  }).addTo(map.value)
  
  // Centrar mapa en el polígono
  map.value.fitBounds(polygon.value.getBounds())
}

const clearPolygon = () => {
  polygonPoints.value = []
  if (polygon.value) {
    map.value.removeLayer(polygon.value)
    polygon.value = null
  }
  // Limpiar marcadores temporales
  map.value.eachLayer((layer) => {
    if (layer instanceof L.Marker) {
      map.value.removeLayer(layer)
    }
  })
  emit('update:modelValue', null)
}

const showReferencePolygon = (coords) => {
  if (!map.value) return
  
  // Limpiar polígono de referencia anterior
  if (referenceLayer.value) {
    map.value.removeLayer(referenceLayer.value)
  }
  
  if (coords && coords.length > 0) {
    // Crear polígono de referencia con estilo distintivo
    referenceLayer.value = L.polygon(coords, {
      color: '#ff9966',
      fillColor: '#ff9966',
      fillOpacity: 0.15,
      weight: 3,
      dashArray: '10, 5'
    }).addTo(map.value)
    
    // Agregar popup informativo
    referenceLayer.value.bindPopup('<b>⚠️ Zona Asignada</b><br>Coloca el marcador DENTRO de esta área')
    
    // Centrar mapa en el polígono
    map.value.fitBounds(referenceLayer.value.getBounds())
  }
}

const showAllZones = (zones) => {
  if (!map.value) {
    console.error('❌ MapPicker: Mapa no está inicializado')
    return
  }
  
  console.log('🗺️ === MapPicker.showAllZones() LLAMADO ===')
  console.log('📥 Zonas recibidas:', zones?.length || 0)
  console.log('📦 Zonas completas:', JSON.stringify(zones, null, 2))
  
  // Limpiar zonas anteriores de forma segura
  zoneLayers.value.forEach(layer => {
    try {
      // Remover event listeners antes de eliminar la capa
      layer.off()
      map.value.removeLayer(layer)
    } catch (e) {
      console.warn('⚠️ Error al remover capa:', e)
    }
  })
  zoneLayers.value = []
  
  if (!zones || zones.length === 0) {
    console.warn('⚠️ No hay zonas para mostrar')
    return
  }
  
  const colors = ['#3498db', '#e74c3c', '#2ecc71', '#f39c12', '#9b59b6', '#1abc9c', '#e67e22', '#95a5a6']
  
  zones.forEach((zone, index) => {
    console.log(`\n🔹 Dibujando zona ${index + 1}/${zones.length}: ${zone.nombre}`)
    const color = colors[index % colors.length]
    let layer = null
    
    // Soportar tanto círculos como polígonos
    if (zone.center && zone.radius) {
      console.log('  ➡️ Tipo: CÍRCULO')
      console.log('  📍 Centro:', zone.center)
      console.log('  📏 Radio:', zone.radius, 'km')
      // Zona circular
      try {
        layer = L.circle(zone.center, {
          radius: zone.radius * 1000, // Convertir km a metros
          color: color,
          fillColor: color,
          fillOpacity: 0.2,
          weight: 2,
          interactive: false // 🔥 DESACTIVAR INTERACCIÓN - No captura clics
        }).addTo(map.value)
        console.log('  ✅ Círculo dibujado exitosamente')
      } catch (e) {
        console.error('  ❌ Error al dibujar círculo:', e)
      }
    } else if (zone.coords && Array.isArray(zone.coords) && zone.coords.length > 0) {
      console.log('  ➡️ Tipo: POLÍGONO')
      console.log('  📍 Puntos:', zone.coords.length)
      // Zona poligonal (legacy)
      try {
        layer = L.polygon(zone.coords, {
          color: color,
          fillColor: color,
          fillOpacity: 0.2,
          weight: 2,
          interactive: false // 🔥 DESACTIVAR INTERACCIÓN - No captura clics
        }).addTo(map.value)
        console.log('  ✅ Polígono dibujado exitosamente')
      } catch (e) {
        console.error('  ❌ Error al dibujar polígono:', e)
      }
    } else {
      console.warn('  ⚠️ Zona sin coordenadas válidas:', zone)
    }
    
    if (layer) {
      // Las zonas son NO interactivas (interactive: false), por lo tanto:
      // - NO capturan clics
      // - NO muestran popups al hacer clic
      // - Solo sirven como referencia visual
      
      // Tooltip PERMANENTE con estilo personalizado - MUY VISIBLE
      layer.bindTooltip(zone.nombre, {
        permanent: true,
        direction: 'center',
        className: 'zone-label-bright'
      })
      
      zoneLayers.value.push(layer)
      console.log('  ✅ Layer agregado al mapa (NO interactivo)')
    }
  })
  
  console.log(`\n✅ Total de capas dibujadas: ${zoneLayers.value.length}`)
  
  // Ajustar vista para mostrar todas las zonas con padding y maxZoom
  if (zoneLayers.value.length > 0) {
    try {
      const group = L.featureGroup(zoneLayers.value)
      map.value.fitBounds(group.getBounds(), { padding: [50, 50], maxZoom: 13 })
      console.log('✅ Vista ajustada a los bounds de las zonas')
    } catch (e) {
      console.error('❌ Error al ajustar bounds:', e)
    }
  } else {
    console.error('❌ NO SE DIBUJÓ NINGUNA ZONA EN EL MAPA')
  }
  console.log('🗺️ === FIN showAllZones() ===\n')
}

watch(() => props.radius, (newVal) => {
  if (coordinates.value && props.mode === 'circle' && newVal) {
    showCircle(coordinates.value, newVal)
  }
})

watch(() => props.modelValue, (newVal) => {
  if (newVal && props.mode === 'point') {
    coordinates.value = newVal
    showMarker(newVal)
  } else if (newVal && props.mode === 'circle') {
    coordinates.value = newVal
    showCircle(newVal, props.radius)
  }
})

watch(() => props.referencePolygon, (newVal) => {
  if (newVal) {
    showReferencePolygon(newVal)
  } else if (referenceLayer.value) {
    map.value.removeLayer(referenceLayer.value)
    referenceLayer.value = null
  }
})

// Watch para modelValue - actualizar el mapa cuando cambien las coordenadas
watch(() => props.modelValue, (newVal) => {
  console.log('👁️ modelValue cambió:', newVal)
  if (newVal && props.mode === 'point' && Array.isArray(newVal) && newVal.length === 2) {
    console.log('✅ Mostrando marcador en:', newVal)
    coordinates.value = newVal
    showMarker(newVal)
  }
})

// Watch SIN immediate - se ejecutará solo cuando cambien las zonas DESPUÉS del montaje
watch(() => props.allZones, (newVal) => {
  console.log('👁️ === WATCH allZones DISPARADO ===')
  console.log('👁️ Número de zonas:', newVal?.length || 0)
  console.log('👁️ Datos completos:', JSON.stringify(newVal, null, 2))
  if (newVal && newVal.length > 0) {
    console.log('✅ Llamando a showAllZones()...')
    showAllZones(newVal)
  } else {
    console.warn('⚠️ Watch: No hay zonas para mostrar')
  }
}, { deep: true })

defineExpose({
  clearPolygon
})
</script>

<style scoped>
.map-picker {
  position: relative;
  width: 100%;
  height: 400px;
  border-radius: 12px;
  overflow: hidden;
  border: 1px solid rgba(255,255,255,.12);
}

.map-container {
  width: 100%;
  height: 100%;
}

.map-info {
  position: absolute;
  top: 12px;
  left: 50%;
  transform: translateX(-50%);
  background: rgba(26, 31, 46, 0.95);
  padding: 8px 16px;
  border-radius: 8px;
  font-size: 12px;
  font-weight: 500;
  z-index: 1000;
  box-shadow: 0 4px 12px rgba(0,0,0,0.3);
  border: 1px solid rgba(255,255,255,.12);
  backdrop-filter: blur(8px);
}

:deep(.leaflet-control-attribution) {
  font-size: 10px;
  background: rgba(255,255,255,0.8) !important;
}

/* TOOLTIPS MEJORADOS - MUY VISIBLES CON FONDO BLANCO */
:deep(.zone-label-bright) {
  background: white !important;
  border: 2px solid #2c3e50 !important;
  color: #2c3e50 !important;
  font-weight: 700 !important;
  font-size: 13px !important;
  padding: 6px 12px !important;
  border-radius: 6px !important;
  box-shadow: 0 3px 10px rgba(0,0,0,0.4) !important;
  opacity: 1 !important;
}

:deep(.leaflet-tooltip-top:before),
:deep(.leaflet-tooltip-bottom:before),
:deep(.leaflet-tooltip-left:before),
:deep(.leaflet-tooltip-right:before) {
  display: none !important;
}

/* POPUPS MEJORADOS */
:deep(.leaflet-popup-content-wrapper) {
  background: white !important;
  color: #2c3e50 !important;
  border-radius: 8px !important;
  box-shadow: 0 4px 12px rgba(0,0,0,0.3) !important;
}

:deep(.leaflet-popup-tip) {
  background: white !important;
}

:deep(.zone-label) {
  background: rgba(26, 31, 46, 0.9);
  border: 1px solid rgba(255,255,255,0.2);
  border-radius: 4px;
  padding: 4px 8px;
  font-size: 11px;
  font-weight: 600;
  box-shadow: 0 2px 8px rgba(0,0,0,0.3);
}
</style>
