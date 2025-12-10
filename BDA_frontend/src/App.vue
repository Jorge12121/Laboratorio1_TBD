<script setup>
import { ref } from 'vue';
import ListaDensidad from './components/ListaDensidad.vue';
import ReporteEscasez from './components/ReporteEscasez.vue'; 
import ListaProyectos from './components/ListaProyectos.vue';

const vistaActual = ref('densidad');
</script>

<template>
  <header>
    <h1>Dashboard Urbanismo</h1>
    <nav>
      <button @click="vistaActual = 'densidad'" :class="{ active: vistaActual === 'densidad' }">Densidad</button>
      <button @click="vistaActual = 'escasez'" :class="{ active: vistaActual === 'escasez' }">Escasez Servicios</button>
      <button @click="vistaActual = 'proyectos'" :class="{ active: vistaActual === 'proyectos' }">Proyectos</button>
    </nav>
  </header>

  <main>
    <ListaDensidad v-if="vistaActual === 'densidad'" />
    <ReporteEscasez v-if="vistaActual === 'escasez'" />
    <ListaProyectos v-if="vistaActual === 'proyectos'" />
  </main>
</template>

<style scoped>
header { background-color: #2c3e50; color: white; padding: 1rem; text-align: center; }
nav { margin-top: 1rem; display: flex; justify-content: center; gap: 10px; }
button { padding: 8px 16px; border: none; background: rgba(255,255,255,0.2); color: white; cursor: pointer; border-radius: 4px; }
button.active { background: #42b983; font-weight: bold; }
button:hover { background: rgba(255,255,255,0.4); }
main { padding: 20px; max-width: 1000px; margin: 0 auto; }
</style>
