<script setup>
import { ref, onMounted } from 'vue'
import api from '@/services/api'

const zonas = ref([])
const error = ref('')
const cargando = ref(true)

const cargar = async () => {
  cargando.value = true
  error.value = ''

  try {
    const response = await api.get('/api/reportes/zonas-sin-planificacion')
    zonas.value = response.data
  } catch (e) {
    console.error(e)
    error.value = 'No se pudo obtener el reporte.'
  } finally {
    cargando.value = false
  }
}

onMounted(cargar)
</script>

<template>
  <div class="page">
    <div class="page-head">
      <div>
        <h3>Zonas sin Planificación Reciente</h3>
        <p>Zonas que no tienen proyectos en los últimos 2 años.</p>
      </div>

      <button class="btn" @click="cargar" :disabled="cargando">
        {{ cargando ? 'Cargando…' : 'Refrescar' }}
      </button>
    </div>

    <div v-if="error" class="alert error">{{ error }}</div>
    <div v-else-if="cargando" class="alert">Cargando datos…</div>

    <div v-else>
      <table class="table table--warn">
        <thead>
          <tr>
            <th>Zona</th>
            <th>Último Proyecto</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="(item, i) in zonas" :key="i">
            <td>{{ item.nombre_zona }}</td>
            <td>{{ item.ultima_fecha }}</td>
          </tr>

          <tr v-if="zonas.length === 0">
            <td colspan="2">Todas las zonas tienen planificación reciente.</td>
          </tr>
        </tbody>
      </table>
    </div>
  </div>
</template>

<style scoped>
.page { display: grid; gap: 12px; }
.page-head { display: flex; justify-content: space-between; align-items: flex-start; gap: 12px; }
</style>