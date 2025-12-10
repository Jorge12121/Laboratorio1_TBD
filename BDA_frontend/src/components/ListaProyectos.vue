<script setup>
import { ref, onMounted } from 'vue';
import ProyectoService from '@/services/ProyectoService';

const proyectos = ref([]);

onMounted(async () => {
  try {
    const response = await ProyectoService.obtenerTodos();
    proyectos.value = response.data;
  } catch (error) {
    console.error(error);
  }
});
</script>

<template>
  <div>
    <h3>Proyectos Urbanos</h3>
    <ul class="lista-proyectos">
      <li v-for="proy in proyectos" :key="proy.id" class="card">
        <h4>{{ proy.nombre }}</h4>
        <p>{{ proy.descripcion }}</p>
        <span class="estado">{{ proy.estado }}</span>
      </li>
    </ul>
  </div>
</template>

<style scoped>
.lista-proyectos { list-style: none; padding: 0; display: grid; grid-template-columns: repeat(auto-fill, minmax(250px, 1fr)); gap: 20px; }
.card { border: 1px solid #ddd; padding: 15px; border-radius: 8px; box-shadow: 0 2px 5px rgba(0,0,0,0.1); }
.estado { background: #3498db; color: white; padding: 3px 8px; border-radius: 12px; font-size: 0.8em; }
</style>