<script setup>
import { ref, onMounted } from 'vue'
import MapPicker from '@/components/MapPicker.vue'
import ZonaService from '@/services/ZonaService'
import PuntoInteresService from '@/services/PuntoInteresService'

const allZones = ref([])
const capaSeleccionada = ref('zonas')
const cargando = ref(false)
const puntos = ref([])

const cargarZonas = async () => {
  try {
    const response = await ZonaService.obtenerTodos()
    allZones.value = response.data
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
    console.log('✅ Zonas cargadas para mapa principal:', allZones.value.length)
  } catch (error) {
    console.error('❌ Error al cargar zonas:', error)
  }
}

const cargarPuntos = async () => {
  try {
    const response = await PuntoInteresService.obtenerTodos()
    puntos.value = response.data
    console.log('✅ Puntos cargados:', puntos.value.length)
  } catch (error) {
    console.error('❌ Error al cargar puntos:', error)
  }
}

const refrescar = async () => {
  cargando.value = true
  await cargarZonas()
  if (capaSeleccionada.value === 'puntos') {
    await cargarPuntos()
  }
  cargando.value = false
}

onMounted(async () => {
  await refrescar()
})
</script>

<template>
  <div class="page">
    <div class="page-head">
      <div>
        <h3>Mapa Principal</h3>
        <p>Visualización completa de zonas urbanas y puntos de interés.</p>
      </div>

      <div class="actions">
        <select v-model="capaSeleccionada" class="select" @change="refrescar">
          <option value="zonas">Capas: Zonas Urbanas</option>
          <option value="puntos">Capas: Puntos de Interés</option>
          <option value="ambas">Capas: Todo</option>
        </select>

        <button class="btn" type="button" @click="refrescar" :disabled="cargando">
          {{ cargando ? '⏳ Cargando...' : '🔄 Refrescar' }}
        </button>
      </div>
    </div>

    <div class="map-card">
      <MapPicker 
        mode="view" 
        :allZones="allZones" 
        style="height: 70vh; width: 100%; border-radius: 12px; overflow: hidden;"
      />
    </div>
  </div>
</template>

<style scoped>
.page{ display:grid; gap:12px; }

.page-head{
  display:flex;
  justify-content: space-between;
  align-items: flex-start;
  gap: 12px;
}

.actions{
  display:flex;
  gap:10px;
  align-items:center;
}

/* select parecido al de proyectos (si no lo tienes global) */
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

/* contenedor del mapa */
.map-card{
  position: relative;
  height: min(64vh, 560px);
  border-radius: 18px;
  border: 1px solid rgba(255,255,255,.10);
  background: rgba(255,255,255,.03);
  overflow: hidden;
  box-shadow: 0 10px 30px rgba(0,0,0,.25);
}

/* “grid” suave para simular mapa */
.map-grid{
  position:absolute;
  inset:0;
  background-image:
    linear-gradient(rgba(255,255,255,.06) 1px, transparent 1px),
    linear-gradient(90deg, rgba(255,255,255,.06) 1px, transparent 1px);
  background-size: 48px 48px;
  opacity: .35;
}

/* overlay tipo glass */
.map-overlay{
  position:absolute;
  left: 16px;
  top: 16px;
  padding: 12px 14px;
  border-radius: 14px;
  border: 1px solid rgba(255,255,255,.10);
  background: rgba(11,18,32,.55);
  backdrop-filter: blur(10px);
  max-width: 320px;
}

.map-title{
  display:flex;
  align-items:center;
  gap: 8px;
  font-weight: 700;
}

.dot{
  width: 10px;
  height: 10px;
  border-radius: 999px;
  background: rgba(66,185,131,.9);
  box-shadow: 0 0 0 4px rgba(66,185,131,.18);
}

.map-sub{
  margin-top: 6px;
  font-size: 12px;
  opacity: .8;
}

.hint{ margin-top: 2px; }
<style scoped>
.page { 
  display: grid; 
  gap: 16px;
}

.page-head {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  gap: 12px;
}

.actions {
  display: flex;
  gap: 10px;
  align-items: center;
}

.select {
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

.map-card {
  position: relative;
  border-radius: 16px;
  border: 1px solid rgba(255,255,255,.12);
  background: rgba(255,255,255,.05);
  overflow: hidden;
  box-shadow: 0 10px 40px rgba(0,0,0,.3);
}

.btn {
  height: 38px;
  padding: 0 18px;
  border-radius: 12px;
  border: 1px solid rgba(255,255,255,.12);
  background-color: rgba(255,255,255,.08);
  color: #eaf0ff;
  font-weight: 500;
  cursor: pointer;
  transition: all 0.2s;
}

.btn:hover:not(:disabled) {
  background-color: rgba(255,255,255,.12);
  border-color: rgba(255,255,255,.20);
}

.btn:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}
</style>
