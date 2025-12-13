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
          <p>Reporte relacionado a escuelas (según backend).</p>
        </RouterLink>

        <div class="card muted-card">
          <h4>5) Cobertura (VM)</h4>
          <p>Próximamente.</p>
        </div>
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

        <div class="card muted-card">
          <h4>6) Simulación crecimiento (SP)</h4>
          <p>Próximamente.</p>
        </div>
      </div>
    </div>

    <div class="section">
      <h4 class="section-title">Planificación / Proyectos</h4>
      <div class="grid">
        <div class="card muted-card">
          <h4>7) Actualizar “Retrasado” (SP)</h4>
          <p>Próximamente.</p>
        </div>

        <div class="card muted-card">
          <h4>8) Zonas sin planificación</h4>
          <p>Próximamente.</p>
        </div>

        <div class="card muted-card">
          <h4>9) Superposición de proyectos</h4>
          <p>Próximamente.</p>
        </div>

        <div class="card muted-card">
          <h4>10) Resumen (VM)</h4>
          <p>Próximamente.</p>
        </div>
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

.muted-card{
  opacity: .70;
}
</style>
