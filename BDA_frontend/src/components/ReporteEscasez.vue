<script setup>
import { ref, onMounted } from 'vue';
import ReporteService from '@/services/ReporteService';

const datos = ref([]);
const cargando = ref(true);

onMounted(async () => {
  try {
    // Corregido: llamada al método obtenerEscasez
    const response = await ReporteService.obtenerEscasez();
    datos.value = response.data;
  } catch (error) {
    console.error("Error cargando reporte de escasez:", error);
  } finally {
    cargando.value = false;
  }
});
</script>

<template>
  <div class="container">
    <h3>Reporte de Escasez de Servicios</h3>
    <div v-if="cargando">Cargando...</div>
    <table v-else class="styled-table">
      <thead>
        <tr>
          <!-- Ajusta estos encabezados según los campos de tu DTO -->
          <th>Zona</th>
          <th>Servicios Faltantes</th>
          <th>Índice</th>
        </tr>
      </thead>
      <tbody>
        <tr v-for="(item, index) in datos" :key="index">
          <!-- Ajusta estas propiedades según tu JSON de respuesta -->
          <td>{{ item.nombreZona || item.zona }}</td>
          <td>{{ item.cantidadFaltante || item.servicios }}</td>
          <td>{{ item.indiceEscazes || item.valor }}</td>
        </tr>
      </tbody>
    </table>
  </div>
</template>

<style scoped>
/* Reutiliza los estilos de tabla del componente anterior o crea un archivo CSS global */
.styled-table { width: 100%; border-collapse: collapse; margin: 20px 0; }
.styled-table th, .styled-table td { padding: 12px; border: 1px solid #ddd; text-align: left; }
.styled-table th { background-color: #e74c3c; color: white; }
</style>