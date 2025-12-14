<script setup>
import { ref } from 'vue'
import api from '@/services/api'

const idUsuario = ref('')
const mensaje = ref('')
const error = ref('')
const cargando = ref(false)

const actualizar = async () => {
  if (!idUsuario.value) {
    error.value = 'Debes ingresar un ID de usuario'
    return
  }

  cargando.value = true
  error.value = ''
  mensaje.value = ''

  try {
    await api.patch(`/api/proyectos/retrasos/id_usuario/${idUsuario.value}`)
    mensaje.value = `✓ Proyectos del usuario ${idUsuario.value} actualizados correctamente`
    idUsuario.value = ''
  } catch (e) {
    console.error(e)
    error.value = 'No se pudo actualizar los proyectos.'
  } finally {
    cargando.value = false
  }
}
</script>

<template>
  <div class="page">
    <div class="page-head">
      <div>
        <h3>Actualizar Proyectos Retrasados</h3>
        <p>Marca como "Retrasado" los proyectos vencidos de un usuario.</p>
      </div>
    </div>

    <form @submit.prevent="actualizar" class="form-card">
      <label class="label">
        ID de Usuario
        <input v-model.number="idUsuario" class="input" type="number" min="1" placeholder="Ej: 2" required />
      </label>

      <button class="btn primary" type="submit" :disabled="cargando">
        {{ cargando ? 'Actualizando…' : 'Actualizar Estado' }}
      </button>

      <div v-if="mensaje" class="alert success">{{ mensaje }}</div>
      <div v-if="error" class="alert error">{{ error }}</div>
    </form>
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
</style>