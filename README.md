# Plataforma de Urbanismo y Planificación de Ciudades

**Universidad de Santiago de Chile**  
**Facultad de Ingeniería - Departamento de Ingeniería Informática**  
**Asignatura:** Taller de Base de Datos (2-2025)

Este proyecto es una herramienta web completa para planificación urbana que permite analizar y visualizar el crecimiento de ciudades mediante datos demográficos, infraestructura y proyectos urbanos. La plataforma integra consultas SQL avanzadas, datos geoespaciales con PostGIS, y una interfaz interactiva para toma de decisiones informadas.

## Características Principales

- **10 Consultas SQL Analíticas** implementadas (simples, vistas materializadas y stored procedures)
- **Autenticación JWT** con roles de usuario (Admin/Planificador)
- **Datos Geoespaciales** con PostGIS para análisis territorial
- **Arquitectura en 3 Capas** (Frontend Vue.js, Backend Spring Boot, PostgreSQL)
- **SQL Nativo** sin ORM, usando JdbcTemplate
- **Interfaz Moderna** con navegación intuitiva entre consultas

---

## Requisitos Previos

- **PostgreSQL** v13+ con extensión **PostGIS** habilitada
- **Java JDK** 17+
- **Maven** 3.6+
- **Node.js** v16+ y npm
- **pgAdmin** o cliente PostgreSQL (opcional)

---

## Instalación y Ejecución

### 1️Configuración de Base de Datos

1. Crear base de datos:
   ```sql
   CREATE DATABASE urbanismo_ciudades;
   ```

2. Conectarse a la base de datos y ejecutar los scripts **en orden**:
   ```bash
   # Script 1: Estructura (tablas, triggers, procedures, vistas)
   psql -U postgres -d urbanismo_ciudades -f script_creacion_urbanismo.sql
   
   # Script 2: Datos de prueba
   psql -U postgres -d urbanismo_ciudades -f poblacion_urbanismo.sql
   ```

> **IMPORTANTE:** El script `poblacion_urbanismo.sql` incluye comandos `REFRESH MATERIALIZED VIEW` al final. Si las vistas materializadas (consultas 5 y 10) aparecen vacías, ejecutar manualmente:
> ```sql
> REFRESH MATERIALIZED VIEW vista_cobertura_infraestructura;
> REFRESH MATERIALIZED VIEW vista_resumen_proyectos_estado_zona;
> ```

### Configuración del Backend

1. Navegar a la carpeta:
   ```bash
   cd BDA_backend
   ```

2. Configurar credenciales en `src/main/resources/application.properties`:
   ```properties
   spring.datasource.url=jdbc:postgresql://localhost:5432/urbanismo_ciudades
   spring.datasource.username=postgres
   spring.datasource.password=tu_contraseña
   server.port=8090
   ```

3. Ejecutar el backend:
   ```bash
   ./mvnw spring-boot:run
   ```
   
   Backend corriendo en: `http://localhost:8090`

### Configuración del Frontend

1. Navegar a la carpeta:
   ```bash
   cd BDA_frontend
   ```

2. Instalar dependencias:
   ```bash
   npm install
   ```

3. Ejecutar servidor de desarrollo:
   ```bash
   npm run dev
   ```
   
   Frontend corriendo en: `http://localhost:5173`

### Acceder a la Aplicación

Abrir navegador en `http://localhost:5173`

**Credenciales de prueba:**
- Email: `test@usach.cl`
- Contraseña: `123456` 

- Email: `test2@usach.cl`
- Contraseña: `1234` 
---

si no funcionan las credenciales ejecutar esto en la base de datos:

INSERT INTO usuarios (nombre, email, contrasena_hash, rol) 
VALUES ('Prueba', 'test@usach.cl', '$2a$12$HZRwLDqKU0NH4Y1TjwjA3.3tnJhiOtojepRFW.WMU0sS3yisMlUDu', 'USER');

INSERT INTO usuarios (nombre, email, contrasena_hash, rol) 
VALUES ('Prueba', 'test2@usach.cl', '$2a$12$VPahmO67snF6IdOLopAow.Jrn1YyXUm7vI2yKDaYUk..OKFkDdsF.', 'USER');

##  Las 10 Consultas SQL Implementadas

### **Consultas Simples (1-4)**

| # | Nombre | Descripción | Endpoint | Vista |
|---|--------|-------------|----------|-------|
| 1 | **Densidad Poblacional** | Calcula habitantes/km² por zona usando `area_km2` | `GET /api/reportes/densidad` | `DensidadView.vue` |
| 2 | **Escasez de Servicios** | Identifica zonas con baja cobertura de hospitales | `GET /api/reportes/escasez` | `EscasezView.vue` |
| 3 | **Escuelas Cercanas** | Encuentra escuelas a menos de 500m de proyectos usando `ST_Distance` | `GET /api/reportes/escuelas` | `EscuelasView.vue` |
| 4 | **Crecimiento Rápido** | Zonas con >15% aumento poblacional anual | `GET /api/reportes/crecimiento` | `CrecimientoView.vue` |

### **Consultas Avanzadas (5-10)**

| # | Tipo | Nombre | Descripción | Endpoint | Vista |
|---|------|--------|-------------|----------|-------|
| 5 | **Vista Materializada** | Cobertura Infraestructura | Pre-calcula conteo de servicios por zona | `GET /api/reportes/cobertura` | `CoberturaView.vue` |
| 6 | **Stored Procedure** | Simulación Crecimiento | Simula impacto de nuevas viviendas (3 hab/casa) | `PATCH /api/datos_demograficos/simular_crecimiento` | `SimulacionView.vue` |
| 7 | **Stored Procedure** | Actualizar Retrasados | Marca proyectos vencidos como "Retrasado" | `PATCH /api/proyectos/retrasos` | `ActualizarRetrasadosView.vue` |
| 8 | **SQL Nativo** | Zonas Sin Planificación | Zonas sin proyectos en últimos 2 años | `GET /api/reportes/zonas-sin-planificacion` | `ZonasSinPlanView.vue` |
| 9 | **SQL Espacial** | Superposición Proyectos | Detecta proyectos con `ST_Intersects` | `GET /api/reportes/superposicion-proyectos` | `SuperposicionView.vue` |
| 10 | **Vista Materializada** | Resumen por Estado | Agrupa proyectos por estado y tipo de zona | `GET /api/reportes/resumen-proyectos` + `POST /api/reportes/refrescar-resumen` | `ResumenProyectosView.vue` |

>  **Nota sobre Vistas Materializadas:** Las consultas 5 y 10 usan vistas materializadas que requieren refresh manual. ResumenProyectosView incluye un botón " Actualizar Vista" que ejecuta `REFRESH MATERIALIZED VIEW`.

---

##  Arquitectura del Sistema

```
┌─────────────────────────────────────────┐
│         FRONTEND (Vue.js 3)             │
│         Puerto: 5173                    │
├─────────────────────────────────────────┤
│  • Router (10 rutas)                    │
│  • Components (Login, Lista, Reportes)  │
│  • Services (api.js, ReporteService.js) │
│  • Axios + JWT Interceptor              │
└──────────────┬──────────────────────────┘
               │ HTTP REST + JWT Token
               ▼
┌─────────────────────────────────────────┐
│      BACKEND (Spring Boot 3)            │
│         Puerto: 8090                    │
├─────────────────────────────────────────┤
│  Controllers (@RestController)          │
│    ├─ AuthController (login)            │
│    ├─ ReporteController (10 consultas)  │
│    ├─ ProyectoController                │
│    └─ DatosDemograficosController       │
│                                         │
│  Services (@Service)                    │
│    └─ Lógica de negocio                 │
│                                         │
│  Repositories (@Repository)             │
│    └─ JdbcTemplate (SQL nativo)         │
│                                         │
│  Security                               │
│    ├─ JwtFilter (valida tokens)         │
│    ├─ JwtUtil (genera/valida JWT)       │
│    └─ SecurityConfig                    │
└──────────────┬──────────────────────────┘
               │ JDBC + SQL Nativo
               ▼
┌─────────────────────────────────────────┐
│   DATABASE (PostgreSQL 13+ PostGIS)     │
├─────────────────────────────────────────┤
│  Tablas:                                │
│    • usuarios                           │
│    • zonas_urbanas (POLYGON)            │
│    • puntos_interes (POINT)             │
│    • datos_demograficos                 │
│    • proyectos_urbanos (POLYGON)        │
│                                         │
│  Vistas Materializadas:                 │
│    • vista_cobertura_infraestructura    │
│    • vista_resumen_proyectos_estado_zona│
│                                         │
│  Stored Procedures:                     │
│    • simular_crecimiento_poblacion()    │
│    • actualizar_proyectos_retrasados()  │
│                                         │
│  Triggers:                              │
│    • trg_validar_fechas_proyecto        │
└─────────────────────────────────────────┘
```

---

## Base de Datos

### Tablas Principales

| Tabla | Descripción | Geometría PostGIS |
|-------|-------------|-------------------|
| `usuarios` | Autenticación y roles (admin/planificador) | - |
| `zonas_urbanas` | Polígonos de barrios/sectores con área en km² | `POLYGON, 4326` |
| `puntos_interes` | Hospitales, escuelas, parques | `POINT, 4326` |
| `datos_demograficos` | Historial poblacional por zona/año | - |
| `proyectos_urbanos` | Proyectos con estado, fechas y ubicación | `POLYGON, 4326` |

### Objetos PL/pgSQL

**Triggers:**
- `trg_validar_fechas_proyecto`: Valida que `fecha_fin >= fecha_inicio`

**Stored Procedures:**
- `simular_crecimiento_poblacion(id_zona, nuevas_casas)`: Incrementa población (+3 hab/casa) y recalcula densidad
- `actualizar_proyectos_retrasados(id_usuario)`: Marca como "Retrasado" proyectos vencidos

**Vistas Materializadas:**
- `vista_cobertura_infraestructura`: Conteo de servicios por zona (optimiza consulta 5)
- `vista_resumen_proyectos_estado_zona`: Agrupación por estado y tipo (optimiza consulta 10)

### Índices

- **Espaciales (GIST):** En columnas `geom` para operaciones `ST_Intersects`, `ST_Distance`
- **B-Tree:** En FK (`id_zona`, `id_usuario`) y campos de filtrado (`estado`, `tipo`, `anio`)

---

## Stack Tecnológico

**Backend:**
- Spring Boot 3.2
- Spring Security + JWT
- JdbcTemplate (SQL nativo, sin ORM)
- Maven

**Frontend:**
- Vue.js 3 (Composition API)
- Vue Router
- Axios
- Vite

**Base de Datos:**
- PostgreSQL 13+
- PostGIS 3+ (datos geoespaciales)

---

## Seguridad

- **Autenticación:** JWT (JSON Web Tokens) con expiración de 10 horas
- **Endpoints protegidos:** Todos excepto `/auth/login`
- **Roles:** Admin y Planificador
- **Hash de contraseñas:** BCrypt (implementado en registro)

---