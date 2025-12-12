<script setup>
import { ref, onMounted } from 'vue';
// 1. Importamos el componente de Login
import Login from './components/LoginView.vue';

// Tus componentes originales
import ListaDensidad from './components/ListaDensidad.vue';
import ReporteEscasez from './components/ReporteEscasez.vue'; 
import ListaProyectos from './components/ListaProyectos.vue';

// Estado de la vista del dashboard
const vistaActual = ref('densidad');

// 2. Estado de autenticación
const estaLogueado = ref(false);

// Al cargar la página, verificamos si ya existe un token guardado
onMounted(() => {
  if (localStorage.getItem('token')) {
    estaLogueado.value = true;
  }
});

// Función que se ejecuta cuando el Login tiene éxito
const onLoginSuccess = () => {
  estaLogueado.value = true;
};

// Función para cerrar sesión
const logout = () => {
  localStorage.removeItem('token');
  estaLogueado.value = false;
  vistaActual.value = 'densidad'; // Resetear vista
};
</script>

<template>
  <Login v-if="!estaLogueado" @login-success="onLoginSuccess" />

  <div v-else class="dashboard-container">
    <header>
      <div class="header-content">
        <h1>Dashboard Urbanismo</h1>
        <button class="btn-logout" @click="logout">Cerrar Sesión</button>
      </div>
      
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
  </div>
</template>

<style scoped>
/* Estilos del contenedor principal */
.dashboard-container { min-height: 100vh; }

/* Header ajustado para incluir el botón de salir */
header { background-color: #2c3e50; color: white; padding: 1rem; }

.header-content {
  display: flex;
  justify-content: space-between;
  align-items: center;
  max-width: 1000px;
  margin: 0 auto;
}

h1 { margin: 0; font-size: 1.5rem; }

/* Botón de Logout específico */
.btn-logout {
  background-color: #e74c3c; /* Rojo para salir */
  font-size: 0.9rem;
}
.btn-logout:hover { background-color: #c0392b; }

/* Tu navegación original */
nav { margin-top: 1rem; display: flex; justify-content: center; gap: 10px; }

/* Tus botones generales */
button { padding: 8px 16px; border: none; background: rgba(255,255,255,0.2); color: white; cursor: pointer; border-radius: 4px; transition: background 0.3s; }
button.active { background: #42b983; font-weight: bold; }
button:hover { background: rgba(255,255,255,0.4); }

main { padding: 20px; max-width: 1000px; margin: 0 auto; }
</style>