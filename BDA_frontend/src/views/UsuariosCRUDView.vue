<template>
  <div class="page">
    <div class="page-head">
      <h3>📋 Gestión de Usuarios</h3>
      
      <button @click="abrirModalCrear" class="btn primary">+ Nuevo Usuario</button>
    </div>

    <div class="card">
      <div class="table-container">
        <table class="table">
          <thead>
            <tr>
              <th>ID</th>
              <th>Nombre</th>
              <th>Email</th>
              <th>Rol</th>
              <th>Acciones</th>
            </tr>
          </thead>
          <tbody>
            <tr v-if="cargando">
              <td colspan="5" style="text-align: center; padding: 40px;">Cargando...</td>
            </tr>
            <tr v-else-if="usuarios.length === 0">
              <td colspan="5" style="text-align: center; padding: 40px;">No hay usuarios</td>
            </tr>
            <tr v-else v-for="usuario in usuarios" :key="usuario.id_usuario || usuario.id">
              <td>{{ usuario.id_usuario || usuario.id }}</td>
              <td>{{ usuario.nombre }}</td>
              <td>{{ usuario.email }}</td>
              <td><span class="badge">{{ usuario.rol }}</span></td>
              <td class="actions-cell">
                <button @click="abrirModalEditar(usuario)" class="btn-icon">✏️</button>
                <button @click="eliminar(usuario)" class="btn-icon danger">🗑️</button>
              </td>
            </tr>
          </tbody>
        </table>
      </div>

      <div class="pagination">
        <button @click="paginaAnterior" :disabled="page <= 0" class="btn secondary">
          ← Anterior
        </button>
        <span class="page-info">
          Página {{ page + 1 }} de {{ totalPages }} ({{ totalItems }} usuarios)
        </span>
        <button @click="siguientePagina" :disabled="page >= totalPages - 1" class="btn secondary">
          Siguiente →
        </button>
      </div>
    </div>

    <!-- Modal -->
    <div v-if="showModal" class="modal-overlay" @click.self="showModal = false">
      <div class="modal">
        <h3>{{ editando ? 'Editar Usuario' : 'Nuevo Usuario' }}</h3>
        <form @submit.prevent="guardar" class="form">
          <div class="form-group">
            <label>Nombre *</label>
            <input v-model="usuarioActual.nombre" required class="input" />
          </div>
          
          <div class="form-group">
            <label>Email *</label>
            <input type="email" v-model="usuarioActual.email" required class="input" />
          </div>

          <div class="form-group" v-if="!editando">
            <label>Contraseña *</label>
            <input type="password" v-model="usuarioActual.contrasena" required class="input" />
          </div>

          <div class="form-group">
            <label>Rol</label>
            <select v-model="usuarioActual.rol" class="input">
              <option value="planificador">Planificador</option>
              <option value="administrador">Administrador</option>
              <option value="analista">Analista</option>
            </select>
          </div>

          <div class="modal-actions">
            <button type="button" @click="showModal = false" class="btn">Cancelar</button>
            <button type="submit" class="btn primary">Guardar</button>
          </div>
        </form>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import UsuarioService from '@/services/UsuarioService'

const usuarios = ref([])
const cargando = ref(false)
const page = ref(0)
const size = ref(10)
const totalPages = ref(0)
const totalItems = ref(0)

const showModal = ref(false)
const editando = ref(false)
const usuarioActual = ref({
  nombre: '',
  email: '',
  contrasena: '',
  rol: 'planificador'
})

const cargar = async () => {
  cargando.value = true
  
  try {
    const response = await UsuarioService.obtenerPaginado(page.value, size.value)
    usuarios.value = response.data.usuarios
    page.value = response.data.currentPage
    totalPages.value = response.data.totalPages
    totalItems.value = response.data.totalItems
  } catch (e) {
    console.error('Error al cargar usuarios:', e)
  } finally {
    cargando.value = false
  }
}

const abrirModalCrear = () => {
  editando.value = false
  usuarioActual.value = {
    nombre: '',
    email: '',
    contrasena: '',
    rol: 'planificador'
  }
  showModal.value = true
}

const abrirModalEditar = (usuario) => {
  editando.value = true
  usuarioActual.value = { ...usuario }
  delete usuarioActual.value.contrasena
  showModal.value = true
}

const guardar = async () => {
  try {
    if (editando.value) {
      const id = usuarioActual.value.id_usuario || usuarioActual.value.id
      await UsuarioService.actualizar(id, usuarioActual.value)
    } else {
      await UsuarioService.crear(usuarioActual.value)
    }
    showModal.value = false
    await cargar()
  } catch (e) {
    console.error('Error al guardar:', e)
    alert('Error al guardar el usuario: ' + (e.response?.data?.message || e.message))
  }
}

const eliminar = async (usuario) => {
  if (!confirm(`¿Está seguro de eliminar al usuario "${usuario.nombre}"?`)) return
  
  try {
    const id = usuario.id_usuario || usuario.id
    await UsuarioService.eliminar(id)
    await cargar()
  } catch (e) {
    console.error('Error al eliminar:', e)
    alert('Error al eliminar el usuario')
  }
}

const siguientePagina = () => {
  if (page.value < totalPages.value - 1) {
    page.value++
    cargar()
  }
}

const paginaAnterior = () => {
  if (page.value > 0) {
    page.value--
    cargar()
  }
}

const formatearFecha = (fecha) => {
  if (!fecha) return '-'
  try {
    return new Date(fecha).toLocaleString('es-CL')
  } catch {
    return String(fecha)
  }
}

onMounted(cargar)
</script>

<style scoped>
.page { display: grid; gap: 16px; }

.page-head {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.card {
  border-radius: 16px;
  border: 1px solid rgba(255,255,255,.10);
  background: rgba(255,255,255,.03);
  overflow: hidden;
}

.btn {
  height: 38px;
  padding: 0 18px;
  border-radius: 10px;
  border: 1px solid rgba(255,255,255,.12);
  background-color: rgba(255,255,255,.06);
  color: #eaf0ff;
  cursor: pointer;
  font-weight: 500;
  transition: all 0.2s;
}

.btn:hover { background-color: rgba(255,255,255,.10); }
.btn.primary {
  background: linear-gradient(135deg, #42b983 0%, #35a372 100%);
  border-color: transparent;
}
.btn.secondary { opacity: 0.7; }
.btn:disabled { opacity: 0.3; cursor: not-allowed; }

.input {
  height: 38px;
  padding: 0 12px;
  border-radius: 8px;
  border: 1px solid rgba(255,255,255,.12);
  background-color: rgba(255,255,255,.06);
  color: #eaf0ff;
  outline: none;
  width: 100%;
}

select.input {
  cursor: pointer;
  appearance: none;
  background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='18' height='18' viewBox='0 0 24 24' fill='none' stroke='%23eaf0ff' stroke-width='2' stroke-linecap='round' stroke-linejoin='round'%3E%3Cpolyline points='6 9 12 15 18 9'/%3E%3C/svg%3E");
  background-repeat: no-repeat;
  background-position: right 12px center;
  background-size: 16px 16px;
  padding-right: 40px;
}

select.input option {
  background-color: #1e2333;
  color: #eaf0ff;
  padding: 10px;
}

.input:focus {
  border-color: rgba(66,185,131,.35);
  box-shadow: 0 0 0 3px rgba(66,185,131,.12);
}

.table-container { overflow-x: auto; }
.table {
  width: 100%;
  border-collapse: collapse;
  font-size: 13px;
}

.table th {
  text-align: left;
  padding: 12px;
  border-bottom: 1px solid rgba(255,255,255,.12);
  font-weight: 600;
  opacity: 0.9;
}

.table td {
  padding: 12px;
  border-bottom: 1px solid rgba(255,255,255,.08);
}

.table tbody tr:hover { background-color: rgba(255,255,255,.03); }

.actions-cell {
  display: flex;
  gap: 8px;
}

.btn-icon {
  background: none;
  border: none;
  cursor: pointer;
  font-size: 16px;
  padding: 4px 8px;
  border-radius: 6px;
  transition: background 0.2s;
}

.btn-icon:hover { background-color: rgba(255,255,255,.1); }
.btn-icon.danger:hover { background-color: rgba(239,68,68,.2); }

.pagination {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 16px;
  border-top: 1px solid rgba(255,255,255,.08);
}

.page-info {
  font-size: 13px;
  opacity: 0.8;
}

.badge {
  padding: 4px 10px;
  border-radius: 12px;
  font-size: 11px;
  font-weight: 600;
  background: rgba(66, 185, 131, 0.2);
  color: rgb(52, 211, 153);
}

.modal-overlay {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background-color: rgba(0, 0, 0, 0.7);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 1000;
}

.modal {
  background-color: #1a1f2e;
  padding: 24px;
  border-radius: 16px;
  max-width: 500px;
  width: 90%;
  max-height: 90vh;
  overflow-y: auto;
}

.modal h3 { margin: 0 0 20px; }

.form {
  display: grid;
  gap: 16px;
}

.form-group {
  display: flex;
  flex-direction: column;
  gap: 6px;
}

.form-group label {
  font-size: 13px;
  opacity: 0.9;
}

.modal-actions {
  display: flex;
  gap: 12px;
  justify-content: flex-end;
  margin-top: 8px;
}
</style>
