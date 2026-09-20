# Declaración de uso de Inteligencia Artificial

**Proyecto:** SmartBancs App (reto técnico)
**Autora:** Cielo Morillo

## Resumen

En este proyecto usé inteligencia artificial de forma intensiva y lo declaro con transparencia, como pide el reto. El código, las pruebas, los scripts y la documentación fueron generados con **Claude Code**, trabajando por fases a partir de una especificación que preparé con **Claude (chat)**. Mi trabajo fue definir el alcance y las decisiones técnicas, dirigir la construcción fase por fase, verificar los resultados, ejecutar las pruebas, publicar los cambios y aprender el funcionamiento del sistema para poder defenderlo.

## 1. Herramientas empleadas

| Herramienta | Versión / modelo | Uso principal |
|---|---|---|
| Claude (chat, claude.ai) | Plan Pro | Análisis del reto, planificación, especificación, guía de instalación y aprendizaje |
| Claude Code (CLI) | v2.1.277, Claude Sonnet 5 | Implementación del código, pruebas, scripts y documentación |
| Gemini | — | Consulta de explicaciones de algunos conceptos; no lo usé para generar código ni documentación |

Además usé Gemini para consultar explicaciones de algunos conceptos; no lo usé para generar código ni documentación.

## 2. Cómo se utilizaron

**Claude (chat)**
- Análisis del enunciado y de sus tres restricciones: alta concurrencia, core legado Bancs y latencia menor a 2 segundos.
- Definición del plan de trabajo en 8 fases y de las reglas técnicas del proyecto (por ejemplo: bloquear cuentas en orden fijo y no llamar a servicios externos dentro de una transacción).
- Redacción de `CLAUDE_CODE_BRIEF.md`, la especificación que siguió Claude Code.
- Guía para instalar el entorno de desarrollo (WSL2, Docker, Git y Python).
- Explicaciones y cuestionarios para aprender el código, revisión de los resultados de cada fase y preparación de la defensa.

**Claude Code**
- Implementación de una fase a la vez, deteniéndose al final de cada una para mi revisión. Cada fase quedó en su propio commit:

| Fase | Contenido | Commit |
|---|---|---|
| 1 | Fundaciones, esquema de BD, docker-compose y API base | `519aa29` |
| 2 | Observabilidad: logs JSON, métricas y trazas | `2ca5d3f` |
| 3 | Transferencia con control de concurrencia | `c68ca0f` |
| 4 | Pruebas de concurrencia y demo de condición de carrera | `b329672` |
| 5 | Servicio de IA, circuit breaker y worker del outbox | `9e43e0c` |
| 6 | Bancs mock, sincronización por lotes, conciliación y ETL | `9773503` |
| 7 | Incidente simulado, diagnóstico, alertas y prueba de carga | `916a8ff` |
| 8 | Documentación de entrega | `807c7c9` y siguientes |

## 3. Componentes y entregables en los que se aplicó

| Entregable | Herramienta | Mi participación |
|---|---|---|
| Servicios (`transaction-api`, `ai-service`, `bancs-mock`) y worker | Claude Code | Revisión por fase; lectura guiada del núcleo de la transferencia |
| Base de datos (esquema, índices, datos de prueba) | Claude Code | Elección de PostgreSQL y revisión |
| ETL | Claude Code | Revisión de resultados |
| Pruebas y scripts de demostración | Claude Code | Ejecución de las pruebas unitarias e integración |
| Infraestructura (Docker Compose, Prometheus) | Claude Code | Instalación del entorno y ejecución |
| Documentación (README, documento técnico, post mortem, ADR, diagramas) | Claude Code | Revisión |
| Plan de trabajo y especificación | Claude (chat) | Definición del alcance y validación |

## 4. Mi participación

- **Decisiones técnicas:** elegí Python con FastAPI y PostgreSQL. Descarté Firebase porque el reto exige scripts DDL/DML, control de concurrencia y la reproducción de deadlocks, que una base NoSQL no permite demostrar.
- **Dirección y revisión:** revisé el resultado de cada fase antes de continuar con la siguiente.
- **Pruebas:** probé la API manualmente desde Swagger (`/docs`) y ejecuté yo misma las pruebas unitarias (12/12) y de integración (2/2). Sus salidas están en `evidence/test-data/`.
- **Publicación:** hice el primer push y todos los push desde la fase 5. Las fases 2 a 4 las publicó Claude Code, antes de que estableciera en `CLAUDE.md` la regla de que solo yo publico cambios.
- **Aprendizaje:** estudié con explicación guiada `transfer_service.py`, `account_repository.py` y `demo_race_condition.py`.
- No escribí ni modifiqué código o documentación manualmente; mi aporte fue de dirección, verificación y validación.

## 5. Cómo se verificó el trabajo de la IA

No se aceptó nada sin evidencia. Cada afirmación relevante del proyecto está respaldada por una prueba o medición guardada en el repositorio:

| Qué se verificó | Evidencia |
|---|---|
| No hay condiciones de carrera (100 transferencias simultáneas, suma cero, idempotencia, partida doble) | `evidence/test-data/` |
| El código inseguro sí falla, y el seguro no | `evidence/test-data/demo_race_condition_output.txt` |
| El orden fijo de bloqueo elimina los deadlocks (29 frente a 0) | `evidence/incident/` |
| La IA caída no afecta a las transferencias | `evidence/ai-resilience/` |
| Bancs no se satura gracias al envío por lotes | `evidence/bancs/` |
| El agotamiento del pool se detecta y diagnostica | `evidence/incident/` |
| Capacidad real bajo carga | `evidence/load-test-results/` |

Durante esta verificación se detectaron y corrigieron errores en el código generado. El más relevante: la primera versión del endpoint de diagnóstico `blocking-tree` consumió 2,5 GB de memoria y congeló la API durante el incidente simulado; se corrigió y se añadió una prueba de regresión (ver `docs/POSTMORTEM.md`). Otros casos están documentados en los ADR y en los comentarios del código.

Los commits del repositorio no incluyen la línea `Co-Authored-By`; el uso de IA se declara de forma completa en este documento.

## 6. Lo que domino y lo que sigo aprendiendo

**Domino:** el bloqueo pesimista con orden fijo y la prevención de deadlocks, la idempotencia, el patrón outbox, las condiciones de carrera, el circuit breaker, la sincronización por lotes con Bancs y la detección y respuesta al incidente de agotamiento del pool.

**Sigo aprendiendo en detalle:** OpenTelemetry y trazas distribuidas, la escritura de reglas de alertas en Prometheus, el funcionamiento interno del ETL y la configuración de pruebas de carga con Locust.

## Declaración

Declaro que el uso de inteligencia artificial en este proyecto es el descrito en este documento, que revisé el resultado de cada fase y que asumo la responsabilidad de todo lo entregado.

**Cielo Morillo**
