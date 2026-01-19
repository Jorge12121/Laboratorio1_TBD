<script setup>
import { ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'

const router = useRouter()

const userName = ref('Usuario')

onMounted(() => {
  userName.value = localStorage.getItem('userName') || 'Usuario-sin-nombre'
})

const logout = () => {
  localStorage.removeItem('token')
  localStorage.removeItem('userName')
  router.push('/login')
}
</script>

<template>
  <div class="app">
    <header class="topbar">
      <div class="topbar-inner">
        <div class="brand">
          <div class="logo">🏙️</div>
          <div>
            <div class="title">Dashboard Urbanismo</div>
            <div class="subtitle">Consultas y reportes</div>
          </div>
        </div>

        <div class="right">
          <div class="user-pill" :title="userName">
            <span class="user-dot"></span>
            <span class="user-name">{{ userName }}</span>
          </div>

          <button class="btn danger" @click="logout">Cerrar sesión</button>
        </div>
      </div>

      <nav class="tabs">
        <RouterLink class="tab" to="/mapa">Mapa</RouterLink>
        <RouterLink class="tab" to="/consultas">Consultas</RouterLink>
        <RouterLink class="tab" to="/proyectos">Proyectos</RouterLink>
        <RouterLink class="tab" to="/crud/proyectos">📝 Proyectos</RouterLink>
        <RouterLink class="tab" to="/crud/datos-demograficos">📊 Demografía</RouterLink>
        <RouterLink class="tab" to="/crud/usuarios">👥 Usuarios</RouterLink>
        <RouterLink class="tab" to="/crud/zonas">🏙️ Zonas</RouterLink>
        <RouterLink class="tab" to="/crud/puntos-interes">📍 Puntos</RouterLink>
      </nav>
    </header>

    <main class="content">
      <div class="card">
        <router-view />
      </div>
    </main>
  </div>
</template>

<style scoped>
.app { min-height: 100vh; }

.topbar {
  border-bottom: 1px solid rgba(255,255,255,.08);
  background: rgba(255,255,255,.03);
  backdrop-filter: blur(8px);
}

.topbar-inner {
  max-width: 1100px;
  margin: 0 auto;
  padding: 18px 16px;
  display: flex;
  justify-content: space-between;
  align-items: center;
  gap: 12px;
}

.brand { display: flex; gap: 12px; align-items: center; }

.logo {
  width: 38px;
  height: 38px;
  display:flex;
  align-items:center;
  justify-content:center;
  border-radius: 12px;
  background: rgba(66,185,131,.18);
}

.title { font-weight: 700; }
.subtitle { font-size: 12px; opacity: .75; margin-top: 2px; }

.tabs {
  max-width: 1100px;
  margin: 0 auto;
  padding: 0 16px 14px;
  display:flex;
  gap: 10px;
}

.tab {
  padding: 8px 12px;
  border-radius: 10px;
  text-decoration: none;
  color: inherit;
  background: rgba(255,255,255,.06);
  border: 1px solid rgba(255,255,255,.08);
}

.tab.router-link-active {
  background: rgba(66,185,131,.22);
  border-color: rgba(66,185,131,.35);
}

.content {
  max-width: 1100px;
  margin: 0 auto;
  padding: 18px 16px 28px;
}

.right{
  display: flex;
  align-items: center;
  gap: 10px;
}

.user-pill{
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 8px 10px;
  border-radius: 999px;
  border: 1px solid rgba(255,255,255,.10);
  background: rgba(255,255,255,.06);
  max-width: 220px;
}

.user-dot{
  width: 8px;
  height: 8px;
  border-radius: 999px;
  background: rgba(66,185,131,.95);
  box-shadow: 0 0 0 4px rgba(66,185,131,.18);
}

.user-name{
  font-size: 13px;
  font-weight: 650;
  opacity: .92;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}
</style>
