<template>
  <div class="page">
    <div class="page-head">
      <div>
        <h3>Mapa</h3>
        <p>Visualización geoespacial (placeholder).</p>
      </div>

      <div class="actions">
        <select class="select">
          <option>Capas: Ninguna</option>
          <option>Densidad</option>
          <option>Escasez</option>
          <option>Proyectos</option>
        </select>

        <button class="btn" type="button">Refrescar</button>
      </div>
    </div>

    <div class="map-card">
      <div class="map-grid" aria-hidden="true"></div>

      <div class="map-overlay">
        <div class="map-title">
          <span class="dot"></span>
          Área de mapa
        </div>
        <div class="map-sub">
          Aquí luego montamos Leaflet/Mapbox + capas PostGIS.
        </div>
      </div>
    </div>
  </div>
</template>

<style scoped>
.page{ display:grid; gap:12px; }

.page-head{
  display:flex;
  justify-content: space-between;
  align-items: flex-start;
  gap: 12px;
}

.actions{
  display:flex;
  gap:10px;
  align-items:center;
}

/* select parecido al de proyectos (si no lo tienes global) */
.select{
  height: 38px;
  padding: 0 38px 0 12px;
  border-radius: 12px;
  border: 1px solid rgba(255,255,255,.12);
  background-color: rgba(255,255,255,.06);
  color: #eaf0ff;
  outline: none;
  cursor: pointer;

  appearance: none;
  -webkit-appearance: none;
  -moz-appearance: none;

  background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='18' height='18' viewBox='0 0 24 24' fill='none' stroke='%23eaf0ff' stroke-width='2' stroke-linecap='round' stroke-linejoin='round'%3E%3Cpolyline points='6 9 12 15 18 9'/%3E%3C/svg%3E");
  background-repeat: no-repeat;
  background-position: right 12px center;
  background-size: 16px 16px;
}

/* contenedor del mapa */
.map-card{
  position: relative;
  height: min(64vh, 560px);
  border-radius: 18px;
  border: 1px solid rgba(255,255,255,.10);
  background: rgba(255,255,255,.03);
  overflow: hidden;
  box-shadow: 0 10px 30px rgba(0,0,0,.25);
}

/* “grid” suave para simular mapa */
.map-grid{
  position:absolute;
  inset:0;
  background-image:
    linear-gradient(rgba(255,255,255,.06) 1px, transparent 1px),
    linear-gradient(90deg, rgba(255,255,255,.06) 1px, transparent 1px);
  background-size: 48px 48px;
  opacity: .35;
}

/* overlay tipo glass */
.map-overlay{
  position:absolute;
  left: 16px;
  top: 16px;
  padding: 12px 14px;
  border-radius: 14px;
  border: 1px solid rgba(255,255,255,.10);
  background: rgba(11,18,32,.55);
  backdrop-filter: blur(10px);
  max-width: 320px;
}

.map-title{
  display:flex;
  align-items:center;
  gap: 8px;
  font-weight: 700;
}

.dot{
  width: 10px;
  height: 10px;
  border-radius: 999px;
  background: rgba(66,185,131,.9);
  box-shadow: 0 0 0 4px rgba(66,185,131,.18);
}

.map-sub{
  margin-top: 6px;
  font-size: 12px;
  opacity: .8;
}

.hint{ margin-top: 2px; }
</style>
