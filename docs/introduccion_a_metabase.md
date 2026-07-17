# Introducción a Metabase

### ¿Qué es Metabase?

**Metabase** es una plataforma de *Business Intelligence (BI)* de código abierto que permite explorar, visualizar y analizar información almacenada en bases de datos mediante una interfaz web intuitiva. A través de consultas, reportes, indicadores (*KPIs*), gráficos, tablas y paneles (*dashboards*), facilita el acceso a la información y el seguimiento de métricas clave sin necesidad de desarrollar aplicaciones adicionales. Esto permite transformar los datos operativos en información útil para el análisis, la supervisión y la toma de decisiones.


## Guía mínima de despliegue desde cero

### Paso 1. Levantar el entorno Docker

Iniciar los contenedores mediante Docker Compose:

```bash
docker compose up -d
```

### Paso 2. Desplegar la base de datos Celeste

Ejecutar el script de despliegue para crear la base de datos **Celeste** junto con sus seis módulos:

```bash
sqlcmd -S localhost -U sa -P 'YourStrong!Passw0rd' -i master_deploy.sql
```

### Paso 3. Acceder a Metabase

Una vez iniciado el servicio, abrir el navegador y acceder a:

```text
http://localhost:3001/
```

Credenciales:

- Dirección de Email: `admin@celeste.local`
- Contraseña: `Celeste2026!`

![Inicio de sesión en Metabase](https://i.ibb.co/Rk1gk7Wd/metabase-001.png)

### Paso 4. Verificar la conexión con la base de datos

En Metabase, dirigirse a la sección **Bases de datos**. Si la configuración es correcta, deberá aparecer la base de datos **Celeste SQL Server**, mostrando todas sus **tablas** y **vistas**. Metabase detecta estos objetos automáticamente durante el proceso de sincronización.

![Bases de Datos en Metabase](https://i.ibb.co/RKHsJDj/metabase-002.png)


![Tablas y Vistas de Celeste en Metabase](https://i.ibb.co/ymKzLdtF/metabase-003.png)

## Nuestra Analítica

La sección **Nuestra Analítica** (*Our Analytics*) representa la colección raíz de Metabase, donde se organizan dashboards, preguntas, modelos y demás recursos analíticos de la plataforma.

![Nuestra Analítica](https://i.ibb.co/jPkdGftq/metabase-004.png)

Dentro de esta sección se encuentra la colección **Celeste Dashboard**, que contiene los siguientes elementos:

| Elemento                 | Tipo                       |
| ------------------------ | -------------------------- |
| Aircraft by Fleet Status | Gráfico de torta (`pie`)   |
| Check-in Boarding Funnel | Gráfico de barras (`bar`)  |
| Crew by Role             | Gráfico de barras (`bar`)  |
| Daily Flight Trend       | Gráfico de líneas (`line`) |
| Flights by Status        | Gráfico de torta (`pie`)   |
| Invoices by Status       | Gráfico de torta (`pie`)   |
| KPI Active Aircraft      | Escalar (`scalar`)         |
| KPI Average Occupancy    | Escalar (`scalar`)         |
| KPI Boarded Passengers   | Escalar (`scalar`)         |
| KPI Paid Revenue         | Escalar (`scalar`)         |
| KPI Scheduled Flights    | Escalar (`scalar`)         |
| Occupancy Bands          | Gráfico de torta (`pie`)   |
| Operations Snapshot      | Tabla (`table`)            |
| Revenue by Flight        | Tabla (`table`)            |
| Revenue by Route         | Gráfico de barras (`bar`)  |
| Top Flight Occupancy     | Gráfico de barras (`bar`)  |

En la interfaz web:

![Celeste Dashboard](https://i.ibb.co/Hp7mtGpW/metabase-005.png)

### Tipos de visualización

Los elementos anteriores utilizan los siguientes tipos de visualización de Metabase:

* **Scalar:** muestra un único indicador o KPI.
* **Pie Chart:** representa la distribución porcentual de una categoría.
* **Line Chart:** muestra la evolución de una métrica a lo largo del tiempo.
* **Bar Chart:** compara valores entre distintas categorías.
* **Table:** presenta los datos en formato tabular para un análisis detallado.

## Definición de los elementos analíticos

La colección **Celeste Dashboard** y los elementos analíticos que contiene (KPIs, gráficos, tablas y demás recursos) se encuentran definidos en el archivo `celeste-db/docker/metabase/dashboard.yaml`. Durante el proceso de despliegue, este archivo es utilizado para crear automáticamente la estructura inicial de la colección en Metabase.

Una vez desplegada la plataforma, la colección también puede administrarse directamente desde la interfaz web de Metabase. Al ingresar a **Celeste Dashboard**, el botón **+ Nuevo** permite crear nuevos recursos, como preguntas (*Questions*), dashboards, modelos y colecciones, sin necesidad de modificar el archivo de configuración.

![Crear nuevo elemento analítico desde la interfaz web](https://i.ibb.co/tPTwWJpb/metabase-006.png)

Se recomienda utilizar el archivo `dashboard.yaml` para mantener una configuración versionada y reproducible del proyecto, reservando la creación de elementos desde la interfaz web para tareas de exploración, pruebas o personalizaciones posteriores.

---

**Referencias**

- [Metabase documentation](https://www.metabase.com/docs/latest/)
- [What is Our Analytics?](https://www.metabase.com/glossary/our-analytics)
- [Which chart should you use? | Metabase Learn](https://www.metabase.com/learn/metabase-basics/querying-and-dashboards/visualization/chart-guide)

**Videos**

- [What is Metabase? - YouTube](https://www.youtube.com/watch?v=png2aqQ5Kgk)
- [See what Metabase can do in 2 mins - YouTube](https://www.youtube.com/watch?v=j_4vI2bm6-8)
