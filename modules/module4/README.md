# M4: Tripulación y Asignaciones

Este módulo gestiona la información de la tripulación, sus certificaciones para operar diferentes tipos de aeronaves y sus asignaciones a las instancias de vuelo. Adicionalmente, implementa reglas regulatorias para la seguridad operacional mediante triggers automáticos.

## Estructura de Datos (Tablas)

El módulo se compone de las siguientes tablas:

1. **`crew_roles`**: Catálogo de roles disponibles en la aerolínea (ej. *Captain*, *First Officer*, *Purser*, *Cabin Crew*).
2. **`crew_members`**: Registro del personal de tripulación con su rol principal, fecha de contratación y datos de contacto.
3. **`crew_certifications`**: Certificaciones habilitantes por tipo de aeronave (ej. Boeing 737, Airbus A320) para los pilotos, con fecha de emisión y vencimiento.
4. **`crew_assignments`**: Tabla intermedia que vincula a los tripulantes con instancias específicas de vuelo (`flight_instances`).

---

## Reglas de Negocio (Trigger `trg_validate_crew_assignment`)

Para garantizar el cumplimiento de las regulaciones aéreas, el trigger `trg_validate_crew_assignment` intercepta las inserciones y actualizaciones en la tabla `crew_assignments` y valida las siguientes condiciones:

### 1. Certificación de Aeronave (Pilotos)
- Aplica únicamente a tripulantes con rol de piloto (`Captain` o `First Officer`).
- El piloto asignado a una instancia de vuelo debe contar con un registro en `crew_certifications` para el tipo de aeronave (`aircraft_type_id`) asignado a ese vuelo.
- La certificación debe estar vigente en la fecha programada del vuelo (`flight_date`).
- Si el piloto no cuenta con certificación o esta se encuentra vencida, se cancela la transacción con un error.

### 2. Descanso Regulatorio y Evitación de Superposiciones
- Un tripulante no puede ser asignado a un vuelo si este coincide en horario (se superpone) con otro vuelo al que ya está asignado.
- Se exige un descanso mínimo de **10 horas (600 minutos)** entre vuelos.
  - Para calcular el intervalo se utilizan las horas reales de operación (`actual_departure_time` / `actual_arrival_time`) si están disponibles; de lo contrario, se calcula en base a los horarios programados (`scheduled_departure_time` / `scheduled_arrival_time`).
  - La diferencia entre el fin de un vuelo previo y el inicio del nuevo vuelo debe ser de al menos 10 horas.
  - La diferencia entre el fin del nuevo vuelo y el inicio de un vuelo posterior asignado también debe ser de al menos 10 horas.

---

## Consultas y Vistas

### Vista `vw_crew_schedule`
Esta vista proporciona el itinerario de vuelos para cada miembro de la tripulación. Muestra detalles legibles del tripulante, el número de vuelo, aeropuertos de origen y destino, fecha y horarios tanto planificados como reales.
