# Introducción a BrokoliSQL

## ¿Qué es BrokoliSQL?

`brokolisql` es una herramienta de interfaz de línea de comandos (CLI) desarrollada originalmente en Python (y con variantes portadas a otros lenguajes como Go) diseñada como un convertidor universal de datos estructurados a instrucciones SQL.

Su función principal es facilitar la migración, transformación e ingesta de datos mediante la conversión automatizada de archivos planos (como CSV, Excel, JSON o XML) en scripts de comandos `INSERT` limpios y ejecutables. La utilidad normaliza los nombres de las columnas, infiere automáticamente los tipos de datos de SQL y permite aplicar transformaciones de datos previas a la generación del archivo final.

## Relevancia en entornos de desarrollo heterogéneos

Para un equipo de desarrollo distribuido en sistemas operativos heterogéneos como Fedora, Ubuntu, macOS y Windows, el uso de herramientas multiplataforma es un requisito operativo. `brokolisql` aporta valor en este escenario gracias a los siguientes factores:

- **Independencia del ecosistema:** Al distribuirse como una utilidad ligera de línea de comandos basada en Python/Go, funciona exactamente igual en arquitecturas Unix y Windows, eliminando la necesidad de emuladores o capas de compatibilidad complejas.
- **Consistencia en el pipeline:** El archivo `.sql` generado por un desarrollador en un sistema operativo se comportará de manera idéntica al ser ejecutado por otro compañero en un entorno diferente.
- **Integración nativa con contenedores:** Al no poseer dependencias de interfaz gráfica, complementa de forma directa el flujo de trabajo basado en contenedores Docker y herramientas de terminal como `sqlcmd`.

## Comparativa de enfoques para la importación de datos

Cuando se requiere poblar una base de datos con datos provenientes de un archivo CSV, existen diferencias metodológicas marcadas entre el uso combinado de `brokolisql` + `sqlcmd` y el asistente gráfico (*Import Wizard*) de SQL Server Management Studio (SSMS):

| Criterio | Enfoque: `brokolisql` + `sqlcmd` | Enfoque: SSMS Import Wizard |
| --- | --- | --- |
| **Dependencia de SO** | Ninguna. Funciona de manera nativa en Linux, macOS y Windows. | Alta. Limitado exclusivamente al ecosistema Windows. |
| **Automatización** | Alta. El proceso se ejecuta mediante scripts, ideal para pipelines de CI/CD o inicialización de Docker. | Nula. Requiere la intervención manual de un operador a través de ventanas y menús dinámicos. |
| **Control de versiones** | El resultado es un archivo de texto plano (`.sql`) que puede ser auditado, versionado y almacenado en Git. | No genera un artefacto de código fácilmente legible o reproducible de forma directa en el repositorio. |
| **Idempotencia** | Los scripts generados pueden incluir cláusulas de verificación para ejecutarse múltiples veces sin duplicar datos. | Cada ejecución del asistente es un evento único y manual propicio al error humano. |

## Utilidad para la generación rápida de seeds

En el ciclo de desarrollo de un proyeco de base de datos, contar con datos de prueba estandarizados (conocidos como *seeds* o semillas) es fundamental para validar las reglas de negocio. `brokolisql` optimiza este proceso a través de las siguientes capacidades:

- **Inyección rápida de datos de prueba:** Convierte listados masivos de datos mock (frecuentemente generados por analistas en formatos CSV o Excel) en sentencias estructuradas en cuestión de segundos.
- **Transformación al vuelo:** Permite preprocesar la información antes de escribir el archivo final mediante reglas definidas en un archivo de configuración (`transforms.json`), tales como normalización de cadenas de texto, formateo correcto de fechas o sanitización de datos sensibles.
- **Mantenimiento simplificado:** Si la estructura de los datos semilla cambia, basta con actualizar el origen de datos CSV y volver a ejecutar el comando de conversión, agilizando la actualización del entorno de desarrollo global.

## Anatomía de un comando BrokoliSQL: generación de scripts

El siguiente comando de `brokolisql` transforma el archivo `seed_airports.csv` —el cual contiene columnas como `id`, `name` y `country`— en un script de base de datos compatible con SQL Server:

```bash
brokolisql \
  --input seed_airports.csv \
  --output seed_airports.sql \
  --table airports \
  --dialect mssql \
  --batch-size 100
```

Cada parámetro (o bandera) define una regla específica para la conversión del archivo CSV:

- **`--input seed_airports.csv`:** Especifica el archivo origen que contiene los datos en bruto. En este escenario, corresponde a un archivo de texto plano con formato de valores separados por comas (CSV).
- **`--output tbl_airports.sql`:** Determina el nombre y la ruta del archivo de salida que generará la herramienta. El resultado será un script de texto con extensión `.sql` listo para ser procesado por `sqlcmd`.
- **`--table airports`:** Define el nombre exacto de la tabla de destino dentro de la base de datos de la aerolínea. Las instrucciones de inserción generadas apuntarán explícitamente a esta entidad (por ejemplo: `INSERT INTO airports (...) VALUES (...);`).
- **`--dialect mssql`:** Indica el motor de base de datos objetivo. Esta bandera es crucial, ya que instruye a `brokolisql` para que adapte la sintaxis del script a las especificaciones y limitantes de Transact-SQL (T-SQL) propio de SQL Server 2022, asegurando la compatibilidad de tipos y formatos de fecha.
- **`--batch-size 100`:** Segmenta la inserción de registros en bloques estructurados. En lugar de generar una instrucción `INSERT` individual por cada fila del CSV o intentar insertar miles de registros en una sola sentencia masiva, la herramienta agrupa las filas de cien en cien utilizando la sintaxis optimizada de múltiples valores:
```sql
INSERT INTO airports (id, code, name) VALUES 
(1, 'MEX', 'Aeropuerto de CDMX'),
... -- (Hasta 100 filas)
(100, 'JFK', 'John F. Kennedy Intl');
```

> **Nota de optimización:** Esta segmentación previene errores de desbordamiento de memoria en el búfer de comandos de SQL Server y acelera significativamente el tiempo de procesamiento cuando el script final es ejecutado a través del pipeline de `sqlcmd`.

## Guía rápida: preparación del entorno de Python

Antes de utilizar la librería `brokolisql` en Python, es necesario configurar el entorno local con las dependencias requeridas para garantizar una ejecución exitosa.

### 1. Definición de dependencias

Cree un archivo denominado `requirements.txt` en la raíz del proyecto con las versiones exactas de las librerías a utilizar:

```text
brokolisql==0.2.0
pandas==2.2.3
```

La necesidad de especificar versiones se debe a un conflicto actual entre `brokolisql` y las versiones más recientes de `pandas`, lo que demanda conciliar una compatibilidad explícita entre ambas librerías.

### 2. Inicialización e instalación

Ejecute la siguiente secuencia de comandos en la terminal para aislar el entorno de desarrollo e instalar los paquetes definidos:

```bash
# Crear el entorno virtual en la carpeta .venv
python -m venv .venv

# Activar el entorno virtual (Linux / macOS)
source .venv/bin/activate

# Instalar las dependencias del proyecto
pip install -r requirements.txt
```

> **Nota para usuarios de Windows 11:** En la terminal de PowerShell, la activación del entorno virtual se realiza mediante el comando: `.\.venv\Scripts\Activate.ps1`.

---

**Referencias**

- [brokolisql · PyPI](https://pypi.org/project/brokolisql/)
