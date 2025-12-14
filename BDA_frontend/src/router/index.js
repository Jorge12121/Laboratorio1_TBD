import { createRouter, createWebHistory } from 'vue-router'

import DashboardLayout from '../layouts/DashboardLayout.vue'
import LoginPage from '../views/LoginView.vue'
import NotFoundView from '../views/NotFoundView.vue'

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

const router = createRouter({
  history: createWebHistory(),
  routes: [
    { path: '/login', component: LoginPage, meta: { guestOnly: true } },

    {
      path: '/',
      component: DashboardLayout,
      meta: { requiresAuth: true },
      children: [
        { path: '', redirect: '/mapa' },

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

  if (to.meta.requiresAuth && !token) {
    return { path: '/login', query: { redirect: to.fullPath } }
  }

  if (to.meta.guestOnly && token) {
    return { path: '/mapa' }
  }

  return true
})

export default router
