<template>
  <div>
    <nav>
      <h1>Panel de Urbanismo</h1>
      <button @click="logout">Cerrar Sesión</button>
    </nav>
    
    <div class="dashboard">
       <h3>Bienvenido al sistema protegido</h3>
       </div>
  </div>
</template>

<script setup>
import { useRouter } from 'vue-router';
// import ListaDensidad from '../components/ListaDensidad.vue'; 

const router = useRouter();

const logout = () => {
  localStorage.removeItem('token');
  router.push('/login');
};
</script>

<style scoped>
nav { display: flex; justify-content: space-between; padding: 1rem; background: #f0f0f0; }
</style>