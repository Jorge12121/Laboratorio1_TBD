# Plataforma de Urbanismo y Planificación de Ciudades

**Universidad de Santiago de Chile**
**Facultad de Ingeniería - Departamento de Ingeniería Informática**
**Asignatura:** Taller de Base de Datos (2-2025)

Este proyecto es una herramienta digital diseñada para planificadores urbanos y autoridades municipales. Permite analizar y visualizar el crecimiento de la ciudad integrando datos demográficos, infraestructura y uso de suelo mediante un mapa interactivo y reportes estadísticos.

---

## Requisitos Previos

Para ejecutar este proyecto necesitas tener instalado:

*   **Base de Datos:** PostgreSQL (v13 o superior) con la extensión **PostGIS** habilitada.
*   **Backend:** Java JDK 17+ y Maven.
*   **Frontend:** Node.js (v16+) y npm.
*   **IDE Recomendado:** Visual Studio Code o IntelliJ IDEA.

---

## Instrucciones de Instalación y Ejecución

### 1. Configuración de Base de Datos

1.  Abre tu cliente de PostgreSQL (pgAdmin o terminal).
2.  Crea una base de datos llamada `urbanismo_ciudades`.
3.  Ejecuta los scripts SQL en el siguiente orden estricto:
    *   **Paso 1:** Ejecutar `script_creacion_urbanismo.sql` (Crea tablas, funciones, triggers y vistas).
    *   **Paso 2:** Ejecutar `poblacion_urbanismo.sql` (Inserta los datos de prueba).

> **Nota:** El script de creación intenta habilitar la extensión PostGIS automáticamente (`CREATE EXTENSION IF NOT EXISTS postgis;`).

### 2. Configuración del Backend (Spring Boot)

1.  Navega a la carpeta del backend:
    ```bash
    cd BDA_backend
    ```
2.  Abre el archivo `src/main/resources/application.properties`.
3.  Verifica y actualiza las credenciales de tu base de datos:
    ```properties
    spring.datasource.url=jdbc:postgresql://localhost:5432/urbanismo_ciudades
    spring.datasource.username=tu_usuario_postgres
    spring.datasource.password=tu_contraseña_postgres
    ```
4.  Ejecuta la aplicación:
    ```bash
    ./mvnw spring-boot:run
    ```
    El servidor iniciará en `http://localhost:8090`.

### 3. Configuración del Frontend (Vue.js)

1.  Abre una nueva terminal y navega a la carpeta del frontend:
    ```bash
    cd BDA_frontend
    ```
2.  Instala las dependencias:
    ```bash
    npm install
    ```
3.  Ejecuta el servidor de desarrollo:
    ```bash
    npm run dev
    ```
4.  Abre tu navegador en la URL que muestra la terminal (usualmente `http://localhost:5173`).

---

## Documentación de la Base de Datos

El sistema utiliza **PostgreSQL** con **PostGIS** para el manejo de datos espaciales. A continuación se describe la arquitectura de datos implementada.

### 1. Tablas Principales

*   **`usuarios`**: Almacena la información de autenticación (email, hash de contraseña) y roles (Admin/Planificador).
*   **`zonas_urbanas`**: Define los polígonos geográficos de los barrios o sectores.
    *   *Geometría:* `geometry(POLYGON, 4326)` (WGS84).
*   **`puntos_interes`**: Ubicaciones puntuales como hospitales, escuelas o parques.
    *   *Geometría:* `geometry(POINT, 4326)`.
    *   *Relación:* FK hacia `zonas_urbanas`.
*   **`datos_demograficos`**: Historial de población, densidad y edad promedio por zona y año.
*   **`proyectos_urbanos`**: Proyectos de construcción planificados o en curso.
    *   *Geometría:* `geometry(POLYGON, 4326)`.
    *   *Relación:* FK hacia `zonas_urbanas` y `usuarios`.

### 2. Lógica de Negocio (PL/pgSQL)

#### Triggers
*   **`trg_validar_fechas_proyecto`**:
    *   *Función asociada:* `validar_fechas_proyecto()`
    *   *Descripción:* Se dispara `BEFORE INSERT OR UPDATE` en la tabla `proyectos_urbanos`. Valida que la fecha de término no sea anterior a la fecha de inicio para mantener la integridad temporal de los datos.

#### Procedimientos Almacenados
*   **`simular_crecimiento_poblacion(id_z, nuevas_viviendas)`**:
    *   *Descripción:* Permite simular el impacto de nuevos desarrollos habitacionales. Actualiza la población de una zona específica sumando un estimado de 3 habitantes por cada nueva vivienda proyectada.
*   **`actualizar_proyectos_retrasados(p_id_usuario)`**:
    *   *Descripción:* Automatización para mantenimiento. Busca proyectos de un usuario específico cuya fecha de fin ya pasó (`CURRENT_DATE`) y no están completados, cambiando su estado automáticamente a 'Retrasado'.

#### Vistas Materializadas
Se utilizan para optimizar el rendimiento de reportes complejos, evitando cálculos costosos en tiempo real.

*   **`vista_cobertura_infraestructura`**:
    *   Pre-calcula el conteo de Hospitales, Escuelas y Parques por cada Zona Urbana.
*   **`vista_resumen_proyectos_estado_zona`**:
    *   Agrupa y cuenta los proyectos según su estado (En Curso, Planeado, etc.) y el tipo de zona (Residencial, Industrial).

### 3. Índices y Optimización

*   **Índices Espaciales (GIST):** Implementados en las columnas `geom` de `zonas_urbanas`, `puntos_interes` y `proyectos_urbanos` para acelerar consultas geográficas como intersecciones (`ST_Intersects`) y búsquedas por proximidad.
*   **Índices B-Tree:** Creados en claves foráneas (`id_zona`, `id_usuario`) y campos de filtrado frecuente (`estado`, `tipo`, `anio`) para optimizar los `JOIN` y cláusulas `WHERE`.

---

## Tecnologías Utilizadas

*   **Backend:** Spring Boot 3, Spring Security (JWT), JDBC Template (SQL Nativo).
*   **Frontend:** Vue 3, Vite, Axios, Leaflet (Mapas interactivos).
*   **Base de Datos:** PostgreSQL 14+, PostGIS 3+.

---