<template>
  <div class="page">
    <div class="page-head">
      <div>
        <h3>Consultas</h3>
        <p>Accede a reportes y análisis urbanos.</p>
      </div>
    </div>

    <div class="section">
      <h4 class="section-title">Servicios / Infraestructura</h4>
      <div class="grid">
        <RouterLink class="card link-card" to="/consultas/escasez">
          <h4>2) Escasez de servicios</h4>
          <p>Hospitales / servicios faltantes por zona.</p>
        </RouterLink>

        <RouterLink class="card link-card" to="/consultas/escuelas">
          <h4>3) Escuelas</h4>
          <p>Escuelas cercanas a proyectos en curso.</p>
        </RouterLink>

        <RouterLink class="card link-card" to="/consultas/cobertura">
          <h4>5) Cobertura (VM)</h4>
          <p>Vista materializada de infraestructura por zona.</p>
        </RouterLink>
      </div>
    </div>

    <div class="section">
      <h4 class="section-title">Demografía</h4>
      <div class="grid">
        <RouterLink class="card link-card" to="/consultas/densidad">
          <h4>1) Densidad poblacional</h4>
          <p>Reporte por zona urbana.</p>
        </RouterLink>

        <RouterLink class="card link-card" to="/consultas/crecimiento">
          <h4>4) Zonas en rápido crecimiento</h4>
          <p>Reporte de crecimiento (según backend).</p>
        </RouterLink>

        <RouterLink class="card link-card" to="/consultas/simulacion">
          <h4>6) Simulación crecimiento (SP)</h4>
          <p>Proyectar impacto de nuevas viviendas.</p>
        </RouterLink>
      </div>
    </div>

    <div class="section">
      <h4 class="section-title">Planificación / Proyectos</h4>
      <div class="grid">
        <RouterLink class="card link-card" to="/consultas/actualizar-retrasados">
          <h4>7) Actualizar "Retrasado" (SP)</h4>
          <p>Marcar proyectos vencidos.</p>
        </RouterLink>

        <RouterLink class="card link-card" to="/consultas/zonas-sin-plan">
          <h4>8) Zonas sin planificación</h4>
          <p>Zonas sin proyectos en 2 años.</p>
        </RouterLink>

        <RouterLink class="card link-card" to="/consultas/superposicion">
          <h4>9) Superposición de proyectos</h4>
          <p>Detectar conflictos geográficos.</p>
        </RouterLink>

        <RouterLink class="card link-card" to="/consultas/resumen-proyectos">
          <h4>10) Resumen (VM)</h4>
          <p>Proyectos por estado y tipo de zona.</p>
        </RouterLink>
      </div>
    </div>

    <div class="section">
      <h4 class="section-title">🗺️ Consultas Espaciales (PostGIS)</h4>
      <div class="grid">
        <RouterLink class="card link-card spatial-card" to="/consultas/densidad-real">
          <h4>📐 Densidad Real</h4>
          <p>Cálculo con ST_Area (población / área real en km²).</p>
        </RouterLink>

        <RouterLink class="card link-card spatial-card" to="/consultas/escuelas-cercanas">
          <h4>🏫 Escuelas Cercanas</h4>
          <p>Análisis de proximidad con ST_DWithin (< 500m).</p>
        </RouterLink>

        <RouterLink class="card link-card spatial-card" to="/consultas/proyectos-superpuestos">
          <h4>⚠️ Superposición de Proyectos</h4>
          <p>Conflictos con ST_Intersects y ST_Intersection.</p>
        </RouterLink>

        <RouterLink class="card link-card spatial-card" to="/consultas/cobertura-hospitales">
          <h4>🏥 Cobertura Hospitales</h4>
          <p>Buffer de 1km con ST_Buffer y ST_Intersection.</p>
        </RouterLink>
      </div>
    </div>
  </div>
</template>

<style scoped>
.page{ display:grid; gap:16px; }

.page-head{
  display:flex;
  justify-content:space-between;
  align-items:flex-start;
  gap:12px;
}

.section{ display:grid; gap:10px; }

.section-title{
  margin: 0;
  font-size: 13px;
  letter-spacing: .2px;
  opacity: .85;
}

.grid{
  display:grid;
  grid-template-columns: repeat(auto-fill, minmax(260px, 1fr));
  gap: 14px;
}

.link-card{
  text-decoration: none;
  color: inherit;
  display: grid;
  gap: 6px;
}

.spatial-card {
  background: linear-gradient(135deg, #667eea22 0%, #764ba222 100%);
  border: 1px solid #667eea44;
}

.spatial-card:hover {
  border-color: #667eea;
  background: linear-gradient(135deg, #667eea33 0%, #764ba233 100%);
}

.muted-card{
  opacity: .70;
}
</style>
