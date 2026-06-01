# Sistema de gestión de aerolínea

—PROYECTO 15

Este documento es un borrador inicial y está en desarrollo; a medida que se avance en el proyecto, se actualizará con más detalles y ejemplos.

## Sobre el repositorio

El objetivo de este repositorio es proveer una instancia limpia de SQL Server dentro de un contenedor de Docker. Luego, cada desarrollador puede decidir qué archivos `.sql` ejecutar para ensamblar una determinada versión o estado de la base de datos del proyecto.

### La Base de Datos como Código (IaC)

En este repositorio, el estado de la base de datos **vive exclusivamente en los scripts `.sql` y no en archivos de Backup (por ejemplo `.bak`)**. El código es la única fuente de verdad. Esto garantiza que la base de datos siempre pueda ser reconstruida exactamente al mismo estado por cualquier miembro del equipo, en cualquier momento y desde cero.

### Ventajas de este abordaje

1. **Trazabilidad total con Git:** Al usar scripts de texto plano (`.sql`) en lugar de backups binarios, podemos ver exactamente qué cambió línea por línea, hacer *code reviews* de la estructura de datos y resolver conflictos de fusión de manera transparente.
2. **Reconstrucción determinista:** Garantiza que si el script `master_deploy.sql` corre en tu máquina, correrá exactamente igual en la de tus compañeros y en el entorno de producción. El proyecto es 100% reproducible.
3. **Ejecución controlada:** Los developers solo ejecutan los módulos o componentes que necesitan cuando lo necesitan.
4. **Iteración rápida:** La instancia de SQL Server se puede destruir y levantar desde cero en segundos si se corrompen los datos de prueba o se quiere probar una migración limpia.
5. **Aislamiento:** Cada developer se puede enfocar en su módulo para hacer cambios, revertirlos y despreocuparse de gestionar o afectar el trabajo de los demás integrantes.

## Requisitos previos

Antes de comenzar, asegúrate de tener instalado en tu máquina:

- [Docker / Docker Desktop](https://www.docker.com/get-started/) (con soporte para Docker Compose).
- [Microsoft SQLCMD CLI](https://github.com/microsoft/go-sqlcmd) instalado localmente para ejecutar los scripts de despliegue.

> **Nota:** La versión más reciente de `sqlcmd` fue reescrita en Go y cuenta con soporte nativo multiplataforma para Windows, Linux y macOS, lo que facilita su instalación en cualquier entorno.

## Guía de inicio rápido

Sigue estos pasos para levantar el entorno local y desplegar la base de datos:

### 1. Configurar las variables de entorno

El archivo `docker/compose.yaml` requiere ciertas variables para inicializar el contenedor. Crea una copia del archivo `.env.example` y dale como nuevo nombre `.env`.

### 2. Levantar el contenedor de SQL Server

Navega hasta la carpeta donde se encuentra el archivo `compose.yaml` y ejecuta:

```bash
docker compose up -d
```

> **Nota:** Esto descargará la imagen oficial de SQL Server 2022 y levantará el servicio en el puerto `1433`.

### 3. Despliegue de la Base de Datos (`master_deploy.sql`)

Una vez que el contenedor esté corriendo, regresa a la raíz del proyecto (`cd ..`) y ejecuta el script maestro. Este script se encarga de orquestar la creación de la base de datos, los logins, las tablas de los módulos y la carga de semillas (*seeds*).

Ejecuta el siguiente comando en tu terminal (reemplaza el password si lo cambiaste en el `.env`):

```bash
sqlcmd -S localhost -U sa -P 'YourStrong!Passw0rd' -i master_deploy.sql
```

### 4. Destruir el contenedor de SQL Server

Para detener y eliminar el contenedor de la base de datos, ejecuta:

```bash
docker compose down
```

> **Importante:** Al destruir el contenedor, todos los datos almacenados en la base de datos local se perderán de forma permanente. Recuerda que los cambios que te interese preservar en la estructura (tablas, funciones, etc.) o los datos de prueba deben estar guardados previamente en sus respectivos archivos `.sql` dentro del repositorio para no perder el progreso. El código es la única fuente de verdad.

## Estructura del proyecto

```
celeste-db/
├── docker/
│   ├── compose.yaml
│   └── init/
│       ├── create_database.sql
│       ├── create_login.sql
│       └── create_user.sql
├── docs/
│   ├── introduccion_a_docker.md
│   └── introduccion_a_sqlcmd.md
├── master_deploy.sql
├── modules/
│   └── module2/
│       ├── definitions/
│       │   ├── constraints/
│       │   ├── indexes/
│       │   └── tables/
│       │       ├── tbl_airports.sql
│       │       ├── tbl_routes.sql
│       │       └── tbl_terminals.sql
│       ├── functions/
│       ├── procedures/
│       ├── README.md
│       ├── seeds/
│       │   ├── csv/
│       │   │   ├── seed_airports.csv
│       │   │   ├── seed_routes.csv
│       │   │   └── seed_terminals.csv
│       │   └── sql/
│       │       ├── seed_airports.sql
│       │       ├── seed_routes.sql
│       │       └── seed_terminals.sql
│       ├── tests/
│       ├── triggers/
│       └── views/
└── README.md
```

El repositorio está organizado por módulos independientes para facilitar el trabajo en equipo de los 5 integrantes:

- **`docker/`**: Configuración del contenedor y scripts de inicialización del sistema (`init/`).
- **`modules/`**: Contiene la lógica de negocio dividida por módulos (ej. `module2`). Cada módulo cuenta con sus propias definiciones de tablas, funciones, procedimientos, triggers y datos de prueba (*seeds*).
- **`master_deploy.sql`**: Script principal encargado de unificar y ejecutar secuencialmente todos los scripts del proyecto.

> **Nota:** Para crear la carpeta de tu módulo puedes uitilzar `module2` como plantilla.

## Convenciones

- **Código:** Los scripts `.sql` y cualquier otro código (nombres de tablas, variables, funciones, archivos, carpeta, etc.) se escriben estrictamente en **inglés**.
- **Comentarios:** Los comentarios dentro de los scripts se pueden escribir en **castellano** o **inglés**, según la preferencia del desarrollador.
- **Documentación:** Toda la documentación oficial (archivos `README.md`, guías y especificaciones en la carpeta `docs/`) se escribe enteramente en **castellano**.

