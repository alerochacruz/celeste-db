# Introducción a Docker

## ¿Qué es Docker?

Docker es una plataforma de código abierto basada en la tecnología de contenedores que permite empaquetar, distribuir y ejecutar aplicaciones junto con todas sus dependencias (bibliotecas, variables de entorno y archivos de configuración) en un entorno aislado llamado contenedor.

A diferencia de los enfoques tradicionales de virtualización, Docker comparte el kernel del sistema operativo del host en lugar de emular un sistema operativo completo. Esto permite que los contenedores sean extremadamente ligeros, se inicien en cuestión de segundos y consuman una cantidad mínima de recursos de hardware.

## Relevancia en entornos de desarrollo heterogéneos

En un equipo de desarrollo donde coexisten sistemas operativos como Fedora 42, Ubuntu 24.04, macOS y Windows 11, Docker actúa como una capa de estandarización crítica que elimina el problema del sesgo de entorno ("funciona en mi máquina"). Su relevancia radica en los siguientes puntos:

- **Consistencia absoluta:** Permite que la instancia de SQL Server 2022 Express se ejecute exactamente bajo la misma configuración, arquitectura de archivos y comportamiento en cualquiera de las plataformas utilizadas por los desarrolladores.
- **Aislamiento del Host:** Evita la necesidad de instalar dependencias pesadas o servicios locales del motor de base de datos directamente en el sistema operativo anfitrión, manteniendo los sistemas limpios y libres de conflictos de puertos o versiones.
- **Portabilidad simplificada:** La infraestructura del proyecto se define mediante un archivo de configuración (`Dockerfile` o `compose.yaml`), lo que permite que cualquier nuevo desarrollador levante la base de datos completa con un único comando.

## Comparación: Docker vs. VirtualBox

| Característica          | Docker (Contenedores)                                                               | VirtualBox (Máquinas Virtuales)                                                                                |
| ----------------------- | ----------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------- |
| **Arquitectura**        | Comparte el kernel del sistema operativo del host; aislamiento a nivel de proceso.  | Emula hardware completo; requiere un sistema operativo invitado (_Guest OS_) independiente.                    |
| **Consumo de recursos** | Muy bajo. Los contenedores ocupan megabytes y comparten memoria de forma dinámica.  | Alto. Requiere asignar de forma fija gigabytes de RAM y espacio en disco por cada VM.                          |
| **Tiempo de arranque**  | Prácticamente instantáneo (segundos o milisegundos).                                | Lento (minutos, equivalente al arranque de un sistema operativo real).                                         |
| **Portabilidad**        | Alta y nativa entre Linux, macOS y Windows mediante abstracciones de la plataforma. | Media. Los archivos de imagen de disco (`.vdi`, `.ova`) son pesados y difíciles de versionar.                  |
| **Propósito principal** | Empaquetar y desplegar aplicaciones y microservicios de forma ágil.                 | Crear entornos de sistema operativo completamente aislados para pruebas de escritorio o desarrollo específico. |

## Anatomía de un comando Docker: despliegue de SQL Server

Para inicializar la base de datos en el entorno local, se ejecuta un contenedor a partir de la imagen oficial de Microsoft mediante el siguiente comando:

```bash
docker run \
  -e 'ACCEPT_EULA=Y' \
  -e 'SA_PASSWORD=YourStrong!Passw0rd' \
  -e 'MSSQL_PID=Express' \
  -p 1433:1433 \
  --name sqlserver-express \
  -d \
  mcr.microsoft.com/mssql/server:2022-latest
```

Cada línea del comando cumple una función específica dentro de la configuración del contenedor:

- **`docker run`:** Comando principal utilizado para crear y arrancar un nuevo contenedor.
- **`-e 'ACCEPT_EULA=Y'` (Environment):** Variable de entorno obligatoria que indica la aceptación de los términos de la Licencia de Usuario Final (*End User License Agreement*) de SQL Server.
- **`-e 'SA_PASSWORD=YourStrong!Passw0rd'`:** Define la contraseña del administrador del sistema (`sa`). Debe cumplir con los requisitos de complejidad predeterminados por SQL Server.
- **`-e 'MSSQL_PID=Express'`:** Especifica la edición del producto a ejecutar; en este caso, se selecciona la versión gratuita *Express*.
- **`-p 1433:1433` (Publish):** Vincula el puerto del host (izquierda) con el puerto interno del contenedor (derecha). Permite que herramientas como `sqlcmd` accedan al motor a través de `localhost:1433`.
- **`--name sqlserver-express`:** Asigna un nombre amigable al contenedor para facilitar su gestión y evitar tener que referenciarlo por su ID alfanumérico.
- **`-d` (Detached):** Ejecuta el contenedor en segundo plano (modo desatendido), liberando inmediatamente la terminal para continuar trabajando.
- **`mcr.microsoft.com/mssql/server:2022-latest`:** Especifica el registro de procedencia (Microsoft Artifact Registry), el repositorio y la etiqueta (*tag*) de la imagen que se va a descargar y ejecutar.

## Transición a infraestructura como código: Docker Compose

Para evitar la introducción manual de comandos extensos en la terminal y asegurar la repetibilidad del entorno, la configuración se extrae a un archivo de orquestación llamado `compose.yaml`. Las variables con credenciales y configuraciones específicas se delegan a un archivo oculto `.env` para mantener una separación clara entre la infraestructura y los datos sensibles.

### Archivo `.env`

Este archivo almacena de forma local las variables de entorno que Docker Compose inyectará automáticamente en el servicio:

```text
ACCEPT_EULA=Y
SA_PASSWORD=YourStrong!Passw0rd
MSSQL_PID=Express
```

### Archivo `compose.yaml`

Define la estructura del servicio empleando la sintaxis declarativa de Compose:

```yaml
services:
  sqlserver:
    image: mcr.microsoft.com/mssql/server:2022-latest
    container_name: sqlserver-express
    ports:
      - "1433:1433"
    environment:
      ACCEPT_EULA: ${ACCEPT_EULA}
      SA_PASSWORD: ${SA_PASSWORD}
      MSSQL_PID: ${MSSQL_PID}
    restart: unless-stopped
```

> **Nota de configuración:** La directiva `restart: unless-stopped` asegura que el contenedor de SQL Server se inicie de forma automática si el servicio Docker se reinicia (por ejemplo, al encender la computadora de desarrollo), a menos que el desarrollador lo haya detenido manualmente.

### Comando de ejecución

Una vez creados ambos archivos en el mismo directorio del proyecto, el entorno se inicializa ejecutando el siguiente comando en la terminal:

```bash
docker compose up -d
```

Este comando lee de forma automática el archivo `compose.yaml`, sustituye los valores interpolados `${VARIABLE}` con los definidos en el archivo `.env`, crea la red virtual interna y descarga y levanta el servicio en segundo plano con una sola instrucción.

---

**Referencias**

- [microsoft/mssql-server - Docker Image](https://hub.docker.com/r/microsoft/mssql-server)
- [What is a Container? | Docker](https://www.docker.com/resources/what-container/)
- [Docker Compose | Docker Docs](https://docs.docker.com/compose/)
