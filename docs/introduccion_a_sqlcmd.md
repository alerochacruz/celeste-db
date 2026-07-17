# Introducción a SQL CMD

![SQL CMD](https://i.ibb.co/dJ0G8SRY/banner-sqlcmd.jpg)

## ¿Qué es sqlcmd y la versión go-sqlcmd?

`sqlcmd` es una utilidad de línea de comandos desarrollada por Microsoft que permite la ejecución interactiva y automatizada de consultas Transact-SQL (T-SQL), procedimientos almacenados y scripts de sistema de archivos.

Históricamente basada en controladores ODBC, la herramienta fue completamente reescrita en el lenguaje de programación Go (`go-sqlcmd`). Esta encarnación moderna elimina dependencias del sistema operativo como `unixODBC` y utiliza el controlador nativo `go-mssqldb`. Además de mantener compatibilidad con la sintaxis tradicional, la versión basada en Go introduce parámetros de estilo POSIX (por ejemplo, `--input-file` en lugar de `-i`), soporte integrado para contenedores (comandos como `sqlcmd create mssql`) y una gestión optimizada de la autenticación.

## Relevancia en entornos de desarrollo heterogéneos

En equipos de desarrollo donde coexisten sistemas operativos como Fedora, Ubuntu, macOS y Windows, la uniformidad de las herramientas es crítica para mitigar el sesgo de entorno ("funciona en mi máquina"). `go-sqlcmd` resuelve este problema debido a las siguientes características:

- **Multiplataforma nativa:** Se distribuye como un binario ligero y autónomo para arquitecturas x64 y ARM64 en Linux, macOS y Windows.
- **Consistencia de comandos:** El mismo script `.sql` o comando de terminal se ejecuta de forma idéntica en cualquier plataforma, facilitando el diagnóstico de errores.
- **Alineación con Docker:** Al trabajar con SQL Server 2022 Express en contenedores, `sqlcmd` puede ejecutarse tanto de forma nativa en el host como directamente dentro del ciclo de vida del contenedor, sin importar el sistema operativo base.

## Comparación: sqlcmd vs. SQL Server Management Studio (SSMS)

| Característica          | `sqlcmd` (Go)                            | SQL Server Management Studio (SSMS)                  |
| ----------------------- | ---------------------------------------- | ---------------------------------------------------- |
| **Interfaz**            | Línea de comandos (CLI) / Terminal.      | Interfaz gráfica de usuario (GUI).                   |
| **Portabilidad**        | Multiplataforma (Linux, macOS, Windows). | Exclusivo de Windows.                                |
| **Consumo de recursos** | Mínimo (binario ligero de ~20 MB).       | Alto (requiere instalación pesada de entorno).       |
| **Automatización**      | Diseñado para scripts, CI/CD y cronjobs. | Orientado a tareas manuales y administración visual. |
| **Dependencias**        | Ninguna (autónomo).                      | Dependiente del ecosistema .NET en Windows.          |

## Utilidad para la automatización

El valor principal de `sqlcmd` para un proyecto de desarrollo radica en su capacidad para automatizar el ciclo de vida de la base de datos mediante la opción `-i` (o `--input-file`). Esto permite:

- **Inicialización de entornos:** Automatizar la creación de esquemas, tablas y carga de datos semilla (seed data) inmediatamente después de levantar el contenedor de Docker.
- **Idempotencia:** Ejecución secuencial de múltiples archivos `.sql` para garantizar que la base de datos se encuentre siempre en el estado deseado.
- **Idoneidad en Pipelines de CI/CD:** Integración directa en flujos de validación automatizados para ejecutar migraciones sin intervención humana.

## Anatomía de un comando sqlcmd: ejemplo práctico

Para familiarizarse con el uso de la herramienta, se analiza a continuación la estructura de un comando típico utilizado para desplegar scripts en el entorno local de desarrollo:

```bash
sqlcmd -S localhost -U sa -P 'YourStrong!Passw0rd' -i master_deploy.sql
```
Cada uno de los parámetros (o banderas) cumple una función específica para establecer la sesión y ejecutar las instrucciones:

- **`-S localhost` (Server):** Especifica la instancia de SQL Server a la que se desea conectar. En este caso, al estar el motor corriendo en un contenedor de Docker en la misma máquina de desarrollo, se apunta a `localhost`. Si el contenedor expusiera un puerto no estándar (diferente al `1433`), se indicaría separándolo con una coma (por ejemplo, `localhost,14333`).
- **`-U sa` (User):** Define el nombre de usuario para la autenticación de SQL Server. Aquí se utiliza `sa` (*System Administrator*), la cuenta de administración predeterminada del motor.
- **`-P 'YourStrong!Passw0rd'` (Password):** Proporciona la contraseña correspondiente al usuario especificado.
> **Nota de seguridad:** Se recomienda el uso de comillas simples en sistemas basados en Unix (Linux/macOS) para evitar que el intérprete de comandos (Bash/Zsh) interprete caracteres especiales como el signo de exclamación (`!`). En entornos de producción, se sugiere omitir esta bandera para que el sistema solicite la contraseña de forma enmascarada, o bien utilizar la variable de entorno `SQLCMDPASSWORD`.

* **`-i master_deploy.sql` (Input File):** Indica la ruta del script de Transact-SQL que se desea ejecutar. `sqlcmd` leerá el archivo de forma secuencial y enviará los lotes de comandos al motor de base de datos de para su procesamiento.

---

**Referencias**

- [Run Transact-SQL Commands with the sqlcmd Utility - SQL Server | Microsoft Learn](https://learn.microsoft.com/en-us/sql/tools/sqlcmd/sqlcmd-utility)
- [Edit SQLCMD Scripts with Query Editor - SQL Server Management Studio | Microsoft Learn](https://learn.microsoft.com/en-us/ssms/scripting/sqlcmd-scripts-query-editor)
- [Download and Install the sqlcmd Utility - SQL Server | Microsoft Learn](https://learn.microsoft.com/en-us/sql/tools/sqlcmd/sqlcmd-download-install)
- [Just bumped into the new Go-based `sqlcmd` - why not C#? : r/dotnet](https://www.reddit.com/r/dotnet/comments/1tp31un/just_bumped_into_the_new_gobased_sqlcmd_why_not_c/)
- [What does a modern command line look like for sqlcmd/bcp? · microsoft/go-sqlcmd · Discussion #113](https://github.com/microsoft/go-sqlcmd/discussions/113)

**Videos**

- [What is go-sqlcmd? - YouTube](https://www.youtube.com/watch?v=4CPdFs74Pkg)
- [Quickly creating containers with the new, open-source SQLCMD | Data Exposed: MVP Edition - YouTube](https://www.youtube.com/watch?v=MlA1dAeE91A)
- [Old Name - New CLI - why you should take a look at sqlcmd - YouTube](https://www.youtube.com/watch?v=xCiLrPHmjkw)
