<script setup>
import { ref, onMounted } from 'vue'
import api from '@/services/api'

const superposiciones = ref([])
const error = ref('')
const cargando = ref(true)

const cargar = async () => {
  cargando.value = true
  error.value = ''

  try {
    const response = await api.get('/api/reportes/superposicion-proyectos')
    superposiciones.value = response.data
  } catch (e) {
    console.error(e)
    error.value = 'No se pudo obtener el reporte.'
  } finally {
    cargando.value = false
  }
}

onMounted(cargar)

const formatearNumero = (n) => {
  if (n === null || n === undefined) return '-'
  return Number(n).toLocaleString('es-CL')
}
</script>

<template>
  <div class="page">
    <div class="page-head">
      <div>
        <h3>Superposición de Proyectos</h3>
        <p>Proyectos que se solapan geográficamente.</p>
      </div>

      <button class="btn" @click="cargar" :disabled="cargando">
        {{ cargando ? 'Cargando…' : 'Refrescar' }}
      </button>
    </div>

    <div v-if="error" class="alert error">{{ error }}</div>
    <div v-else-if="cargando" class="alert">Cargando datos…</div>

    <div v-else>
      <table class="table table--danger">
        <thead>
          <tr>
            <th>Proyecto A</th>
            <th>Proyecto B</th>
            <th>Área Superpuesta (m²)</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="(item, i) in superposiciones" :key="i">
            <td>{{ item.proyecto_a }}</td>
            <td>{{ item.proyecto_b }}</td>
            <td>{{ formatearNumero(item.area_m2) }}</td>
          </tr>

          <tr v-if="superposiciones.length === 0">
            <td colspan="3">No se detectaron superposiciones.</td>
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