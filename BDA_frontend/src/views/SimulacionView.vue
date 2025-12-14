<!-- BDA_frontend/src/views/SimulacionView.vue -->
<script setup>
import { ref } from 'vue'
import api from '@/services/api'

const idZona = ref('')
const nuevasViviendas = ref('')
const mensaje = ref('')
const error = ref('')
const cargando = ref(false)

const simular = async () => {
  if (!idZona.value || !nuevasViviendas.value) {
    error.value = 'Debes completar ambos campos'
    return
  }

  cargando.value = true
  error.value = ''
  mensaje.value = ''

  try {
    await api.patch(`/api/datos_demograficos/simular_crecimiento/id_zona/${idZona.value}/casas/${nuevasViviendas.value}`)
    mensaje.value = `✓ Simulación exitosa: ${nuevasViviendas.value} viviendas agregadas a la zona ${idZona.value}`
    idZona.value = ''
    nuevasViviendas.value = ''
  } catch (e) {
    console.error(e)
    error.value = 'No se pudo realizar la simulación.'
  } finally {
    cargando.value = false
  }
}
</script>

<template>
  <div class="page">
    <div class="page-head">
      <div>
        <h3>Simulación de Crecimiento Poblacional</h3>
        <p>Calcula el impacto de nuevas viviendas en una zona.</p>
      </div>
    </div>

    <form @submit.prevent="simular" class="form-card">
      <label class="label">
        ID de Zona
        <input v-model.number="idZona" class="input" type="number" min="1" placeholder="Ej: 5" required />
      </label>

      <label class="label">
        Nuevas Viviendas
        <input v-model.number="nuevasViviendas" class="input" type="number" min="1" placeholder="Ej: 100" required />
      </label>

      <button class="btn primary" type="submit" :disabled="cargando">
        {{ cargando ? 'Simulando…' : 'Simular Crecimiento' }}
      </button>

      <div v-if="mensaje" class="alert success">{{ mensaje }}</div>
      <div v-if="error" class="alert error">{{ error }}</div>
    </form>

    <div class="hint">
      <strong>Nota:</strong> Se asume un promedio de 3 personas por vivienda.
    </div>
  </div>
</template>

<style scoped>
.page { display: grid; gap: 12px; }
.page-head { display: flex; justify-content: space-between; align-items: flex-start; gap: 12px; }

.form-card {
  background: rgba(255,255,255,.03);
  border: 1px solid rgba(255,255,255,.10);
  border-radius: 18px;
  padding: 20px;
  display: grid;
  gap: 14px;
  max-width: 480px;
}

.label {
  display: grid;
  gap: 6px;
  font-size: 12px;
  color: rgba(234,240,255,.85);
}

.hint {
  font-size: 12px;
  opacity: .75;
  padding: 12px;
  background: rgba(255,255,255,.03);
  border-radius: 12px;
  border: 1px solid rgba(255,255,255,.08);
}
</style>