<script setup>
import { ref, onMounted } from 'vue';
import ReporteService from '@/services/ReporteService';

const reportes = ref([]);
const error = ref(null);
const cargando = ref(true);

const obtenerDatos = async () => {
  try {
    const response = await ReporteService.obtenerDensidad();
    reportes.value = response.data;
  } catch (e) {
    console.error(e);
    error.value = "Error al conectar.";
  } finally {
    cargando.value = false;
  }
};

onMounted(() => {
  obtenerDatos();
});
</script>

<template>
  <div class="tabla-container">
    <h3>Densidad Poblacional</h3>
    <div v-if="cargando">Cargando...</div>
    <div v-if="error" class="error">{{ error }}</div>

    <table v-if="!cargando && !error" class="styled-table">
      <thead>
        <tr>
          <th>Zona</th>
          <th>Densidad (Hab/km²)</th>
        </tr>
      </thead>
      <tbody>
        <tr v-for="(item, index) in reportes" :key="index">
          <td>{{ item.nombre }}</td>
          <td>{{ item.densidad }}</td>
        </tr>
      </tbody>
    </table>
  </div>
</template>

<style scoped>
.styled-table { width: 100%; border-collapse: collapse; margin: 20px 0; }
.styled-table th, .styled-table td { padding: 12px; border: 1px solid #ddd; text-align: left; }
.styled-table th { background-color: #2c3e50; color: white; }
.error { color: red; }
</style>