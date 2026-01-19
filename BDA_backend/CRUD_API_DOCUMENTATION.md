# API REST - Documentación de Endpoints CRUD

## 📋 Resumen

Se han implementado operaciones CRUD completas con paginación y queries simples para todas las tablas del modelo.

## 🚀 Nuevos Endpoints

### 1. Datos Demográficos (`/api/datos_demograficos`)

**CRUD Básico:**
- `GET /api/datos_demograficos` - Obtener todos
- `GET /api/datos_demograficos/paginated?page=0&size=10` - Con paginación
- `GET /api/datos_demograficos/{id}` - Obtener por ID
- `POST /api/datos_demograficos` - Crear nuevo
- `PUT /api/datos_demograficos/{id}` - Actualizar
- `DELETE /api/datos_demograficos/{id}` - Eliminar

**Queries Simples:**
- `GET /api/datos_demograficos/zona/{idZona}` - Por zona
- `GET /api/datos_demograficos/anio/{anio}` - Por año
- `GET /api/datos_demograficos/poblacion?min=1000&max=50000` - Por rango de población

**Existente:**
- `PATCH /api/datos_demograficos/simular_crecimiento/id_zona/{id}/casas/{n}` - Simular crecimiento

---

### 2. Proyectos Urbanos (`/api/proyectos`)

**CRUD Básico:**
- `GET /api/proyectos` - Obtener todos (objetos)
- `GET /api/proyectos/map` - Obtener todos (como Map, compatibilidad)
- `GET /api/proyectos/paginated?page=0&size=10` - Con paginación
- `GET /api/proyectos/{id}` - Obtener por ID
- `POST /api/proyectos` - Crear nuevo
- `PUT /api/proyectos/{id}` - Actualizar
- `DELETE /api/proyectos/{id}` - Eliminar

**Queries Simples:**
- `GET /api/proyectos/estado/{estado}` - Por estado (PLANEADO, EN CURSO, etc.)
- `GET /api/proyectos/zona/{idZona}` - Por zona
- `GET /api/proyectos/usuario/{idUsuario}` - Por usuario
- `GET /api/proyectos/nombre?nombre=texto` - Búsqueda parcial por nombre

**Existente:**
- `PATCH /api/proyectos/retrasos/id_usuario/{id}` - Actualizar proyectos retrasados

---

### 3. Puntos de Interés (`/api/puntos-interes`) ⭐ NUEVO

**CRUD Básico:**
- `GET /api/puntos-interes` - Obtener todos
- `GET /api/puntos-interes/paginated?page=0&size=10` - Con paginación
- `GET /api/puntos-interes/{id}` - Obtener por ID
- `POST /api/puntos-interes` - Crear nuevo
- `PUT /api/puntos-interes/{id}` - Actualizar
- `DELETE /api/puntos-interes/{id}` - Eliminar

**Queries Simples:**
- `GET /api/puntos-interes/tipo/{tipo}` - Por tipo (hospital, escuela, etc.)
- `GET /api/puntos-interes/zona/{idZona}` - Por zona
- `GET /api/puntos-interes/nombre?nombre=texto` - Búsqueda parcial
- `GET /api/puntos-interes/cercanos?latitud=-33.4&longitud=-70.6&radioKm=5` - Puntos cercanos

---

### 4. Usuarios (`/api/usuarios`)

**CRUD Básico:**
- `GET /api/usuarios` - Obtener todos
- `GET /api/usuarios/paginated?page=0&size=10` - Con paginación
- `GET /api/usuarios/{id}` - Obtener por ID
- `POST /api/usuarios` - Crear (encripta contraseña automáticamente)
- `PUT /api/usuarios/{id}` - Actualizar
- `DELETE /api/usuarios/{id}` - Eliminar

**Queries Simples:**
- `GET /api/usuarios/rol/{rol}` - Por rol (admin, planificador, etc.)
- `GET /api/usuarios/nombre?nombre=texto` - Búsqueda parcial

**Existente:**
- `POST /api/usuarios/registro` - Registro tradicional

---

### 5. Zonas Urbanas (`/api/zona`)

**CRUD Básico:**
- `GET /api/zona` - Obtener todas
- `GET /api/zona/paginated?page=0&size=10` - Con paginación
- `GET /api/zona/{id}` - Obtener por ID
- `POST /api/zona` - Crear nueva
- `PUT /api/zona/{id}` - Actualizar
- `DELETE /api/zona/{id}` - Eliminar

**Queries Simples:**
- `GET /api/zona/tipo/{tipoZona}` - Por tipo (residencial, comercial, etc.)
- `GET /api/zona/nombre?nombre=texto` - Búsqueda parcial
- `GET /api/zona/area?minArea=1.0&maxArea=10.0` - Por rango de área (km²)

**Existente:**
- `GET /api/zona/sin-planificacion` - Zonas sin planificación

---

## 📊 Formato de Paginación

Todos los endpoints con paginación devuelven:

```json
{
  "datos|proyectos|puntos|usuarios|zonas": [...],
  "currentPage": 0,
  "totalItems": 100,
  "totalPages": 10
}
```

**Parámetros:**
- `page`: Número de página (base 0)
- `size`: Tamaño de página (default: 10)

---

## 🔑 Cambios Importantes

### Campos ID en Modelos

Los objetos ahora incluyen sus IDs completos:
- `datos_demograficos.id_datos`
- `proyectos_urbanos.id_proyectos`
- `puntos_interes.id_punto`
- `usuarios.id_usuario`
- `zonas_urbanas.id_zona`

### Compatibilidad Frontend

El componente `ListaProyectos.vue` ahora acepta ambos formatos:
```vue
:key="proy.id_proyectos || proy.id"
```

---

## 📦 Servicios Frontend

Se han creado servicios completos en el frontend:

- `DatosDemograficosService.js` - CRUD + queries de datos demográficos
- `ProyectoService.js` - CRUD + queries de proyectos (actualizado)
- `PuntoInteresService.js` - CRUD + queries de puntos de interés ⭐
- `UsuarioService.js` - CRUD + queries de usuarios ⭐
- `ZonaService.js` - CRUD + queries de zonas ⭐

---

## 🎨 Vistas Frontend

### Nuevas vistas CRUD:
- `/crud/datos-demograficos` - Gestión de datos demográficos con filtros
- `/crud/proyectos` - CRUD completo de proyectos con modal

### Características:
✅ Paginación funcional
✅ Filtros por diferentes campos
✅ Crear, editar y eliminar
✅ Diseño responsive
✅ Manejo de errores

---

## 🔐 Seguridad

- Todos los endpoints requieren autenticación JWT
- Las contraseñas se encriptan automáticamente con BCrypt
- CORS habilitado para desarrollo

---

## 📝 Ejemplo de Uso

### Crear un proyecto:
```javascript
import ProyectoService from '@/services/ProyectoService'

const nuevoProyecto = {
  nombre: "Parque Central",
  descripcion: "Construcción de nuevo parque",
  fecha_inicio: "2024-01-15",
  fecha_fin: "2024-12-31",
  estado: "PLANEADO",
  id_zona: 1,
  id_usuario: 1,
  ubicacion: "Centro",
  latitud: -33.4372,
  longitud: -70.6506
}

const response = await ProyectoService.crear(nuevoProyecto)
console.log(response.data) // Retorna el proyecto con su ID asignado
```

### Buscar con paginación:
```javascript
const response = await ProyectoService.obtenerPaginado(0, 10)
console.log(response.data.proyectos) // Array de proyectos
console.log(response.data.totalPages) // Total de páginas
```

### Buscar por filtros:
```javascript
// Por estado
const enCurso = await ProyectoService.obtenerPorEstado("EN CURSO")

// Por nombre (búsqueda parcial)
const parques = await ProyectoService.obtenerPorNombre("parque")
```

---

## 🚨 Notas de Migración

Si tu código frontend usa el antiguo formato, considera:

1. **IDs:** Usar `proy.id_proyectos` en lugar de `proy.id`
2. **Compatibilidad:** Los componentes actuales aceptan ambos formatos
3. **Nuevos servicios:** Aprovechar los servicios CRUD completos
4. **Paginación:** Implementar paginación para mejorar performance

---

## ✅ Checklist de Implementación

- [x] Modelos actualizados con getters/setters de IDs
- [x] Repositories con RowMappers y operaciones CRUD
- [x] Services con lógica de negocio
- [x] Controllers con endpoints REST
- [x] Servicios frontend para todas las tablas
- [x] Vistas de ejemplo con paginación
- [x] Router actualizado
- [x] Compatibilidad con código existente
- [x] Documentación completa

---

¿Necesitas agregar más funcionalidades o customizar algo? Todos los endpoints están listos y funcionando! 🎉
