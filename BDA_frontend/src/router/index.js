import { createRouter, createWebHistory } from 'vue-router'

import DashboardLayout from '../layouts/DashboardLayout.vue'
import LoginPage from '../views/LoginView.vue'
import NotFoundView from '../views/NotFoundView.vue'

// IMPORTANTE: Importamos el componente de registro que creamos
// (Asegúrate de que la ruta coincida con donde guardaste el archivo)
import RegisterView from '../views/RegisterView.vue'

import MapaView from '../views/MapaView.vue'
import ConsultasHubView from '../views/ConsultasHubView.vue'
import DensidadView from '../views/DensidadView.vue'
import EscasezView from '../views/EscasezView.vue'
import ProyectosView from '../views/ProyectosView.vue'
import EscuelasView from '../views/EscuelasView.vue'
import CrecimientoView from '../views/CrecimientoView.vue'
import SimulacionView from '../views/SimulacionView.vue'
import CoberturaView from '../views/CoberturaView.vue'
import ActualizarRetrasadosView from '../views/ActualizarRetrasadosView.vue'
import ZonasSinPlanView from '../views/ZonasSinPlanView.vue'
import SuperposicionView from '../views/SuperposicionView.vue'
import ResumenProyectosView from '../views/ResumenProyectosView.vue'

// Nuevas vistas de consultas espaciales
import DensidadRealView from '../views/DensidadRealView.vue'
import EscuelasCercanasView from '../views/EscuelasCercanasView.vue'
import ProyectosSuperpuestosView from '../views/ProyectosSuperpuestosView.vue'
import CoberturaHospitalesView from '../views/CoberturaHospitalesView.vue'

// Nuevas vistas CRUD
import DatosDemograficosView from '../views/DatosDemograficosView.vue'
import ProyectosCRUDView from '../views/ProyectosCRUDView.vue'
import UsuariosCRUDView from '../views/UsuariosCRUDView.vue'
import ZonasCRUDView from '../views/ZonasCRUDView.vue'
import PuntosInteresCRUDView from '../views/PuntosInteresCRUDView.vue'
import DiagnosticoView from '../views/DiagnosticoView.vue'

const router = createRouter({
  history: createWebHistory(),
  routes: [
    // Ruta de Login (Solo para invitados)
    { path: '/login', component: LoginPage, meta: { guestOnly: true } },

    // ---> NUEVA RUTA DE REGISTRO <---
    // También es 'guestOnly' para que usuarios logueados no entren aquí
    { path: '/registro', component: RegisterView, meta: { guestOnly: true } },

    {
      path: '/',
      component: DashboardLayout,
      meta: { requiresAuth: true },
      children: [
        { path: '', redirect: '/login' },

        { path: 'mapa', component: MapaView },
        { path: 'consultas', component: ConsultasHubView },
        
        { path: 'consultas/densidad', component: DensidadView },
        { path: 'consultas/escasez', component: EscasezView },
        { path: 'consultas/escuelas', component: EscuelasView },
        { path: 'consultas/crecimiento', component: CrecimientoView },
        { path: 'consultas/cobertura', component: CoberturaView },
        { path: 'consultas/simulacion', component: SimulacionView },
        { path: 'consultas/actualizar-retrasados', component: ActualizarRetrasadosView },
        { path: 'consultas/zonas-sin-plan', component: ZonasSinPlanView },
        { path: 'consultas/superposicion', component: SuperposicionView },
        { path: 'consultas/resumen-proyectos', component: ResumenProyectosView },

        // Nuevas rutas de consultas espaciales
        { path: 'consultas/densidad-real', component: DensidadRealView },
        { path: 'consultas/escuelas-cercanas', component: EscuelasCercanasView },
        { path: 'consultas/proyectos-superpuestos', component: ProyectosSuperpuestosView },
        { path: 'consultas/cobertura-hospitales', component: CoberturaHospitalesView },

        // Gestión CRUD
        { path: 'crud/datos-demograficos', component: DatosDemograficosView },
        { path: 'crud/proyectos', component: ProyectosCRUDView },
        { path: 'crud/usuarios', component: UsuariosCRUDView },
        { path: 'crud/zonas', component: ZonasCRUDView },
        { path: 'crud/puntos-interes', component: PuntosInteresCRUDView },
        
        // Diagnóstico
        { path: 'diagnostico', component: DiagnosticoView },

        { path: 'proyectos', component: ProyectosView },
      ],
    },

    { path: '/densidad', redirect: '/consultas/densidad' },
    { path: '/escasez', redirect: '/consultas/escasez' },

    { path: '/:pathMatch(.*)*', component: NotFoundView },
  ],
})

router.beforeEach((to) => {
  const token = localStorage.getItem('token')

  // Si requiere auth y no hay token -> va al Login
  if (to.meta.requiresAuth && !token) {
    return { path: '/login', query: { redirect: to.fullPath } }
  }

  // Si es solo para invitados y hay token -> limpia y permite
  if (to.meta.guestOnly && token) {
    localStorage.removeItem('token')
    localStorage.removeItem('userName')
    return true
  }

  return true
})

export default router