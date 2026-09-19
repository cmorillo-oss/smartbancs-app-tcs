# Declaración de uso de Inteligencia Artificial

**Proyecto:** SmartBancs App (reto técnico)
**Autora:** Cielo Morillo
**Fecha de la declaración:** 2026-09-19

> **Cómo leer este documento.** Lo redactó Claude Code a partir del historial del repositorio y de los datos que la autora dio (el 19/09/2026) sobre cómo trabajó.
> Lo que dice sobre lo que hizo la autora viene **solo de lo que ella declaró**. Lo que sigue marcado con **[COMPLETAR]** es lo que la autora **no aportó** y debe rellenar (o borrar) ella misma.

---

## 1. Resumen honesto

Este proyecto se hizo **con mucho apoyo de IA**, y aquí se dice con claridad:

- La **implementación del código** (servicios, SQL, pruebas, scripts, documentación) la escribió **Claude Code**, siguiendo un brief por fases (`CLAUDE_CODE_BRIEF.md`).
- El **análisis del reto, la planificación y el aprendizaje** se hicieron conversando con **Claude (chat)**.
- La **autora** definió el alcance y las restricciones, revisó el resultado de cada fase, probó la API a mano desde Swagger, ejecutó ella misma las pruebas unitarias y de integración y subió casi todos los cambios al repositorio. **No escribió ni modificó código ni documentación a mano.**

La autora es responsable de todo lo que se entrega y debe poder defenderlo oralmente. Por eso el código lleva comentarios en español que explican el **porqué** de cada decisión.

---

## 2. Herramientas usadas

| Herramienta | Modelo / versión | Para qué se usó |
|---|---|---|
| **Claude** (chat, claude.ai) | Plan Pro. **[COMPLETAR: modelo exacto y fechas aproximadas]** | Análisis del enunciado, plan de trabajo por fases, redacción de `CLAUDE_CODE_BRIEF.md`, guía para instalar el entorno (WSL2, Docker, Git, Python), explicaciones y *quizzes* para aprender el código, revisión de los resultados de cada fase y preparación de la defensa |
| **Claude Code** (CLI) | **v2.1.277, modelo Claude Sonnet 5** (plan Pro) | Implementación completa del código, las pruebas, los scripts y la documentación, fase por fase, siguiendo el brief |
| Otras herramientas de IA | **Ninguna** | – |

---

## 3. Qué hizo cada herramienta, por etapa

### 3.1 Claude (chat): análisis, planificación y aprendizaje
- Análisis del enunciado del reto y de sus tres restricciones (concurrencia, Bancs legado, latencia).
- Planificación: se decidió el **orden de las fases** y las **reglas de oro** (nunca llamar a servicios externos dentro de una transacción, bloquear cuentas en orden determinista, etc.).
- Elaboración del brief `CLAUDE_CODE_BRIEF.md`, que sirvió como especificación para Claude Code.
- Explicaciones de conceptos para que la autora pudiera **defenderlos**.

Además de lo anterior, el chat se usó para **guiar la instalación del entorno** (WSL2, Docker, Git y Python), para **explicaciones y *quizzes*** con los que la autora aprendió el código, para **revisar los resultados de cada fase** y para **preparar la defensa**. Las decisiones técnicas de fondo (Python/FastAPI y PostgreSQL) las tomó la autora (ver sección 4).

**[COMPLETAR: número aproximado de conversaciones en el chat y fechas; la autora no lo indicó.]**

### 3.2 Claude Code: implementación por fases
El trabajo se hizo **una fase por vez**, con detención al final de cada una para que la autora verificara (regla del brief). Cada fase quedó en un commit propio:

| Fase | Contenido | Commit |
|---|---|---|
| 1 | Fundaciones, esquema de BD, docker-compose y API base | `519aa29` |
| 2 | Observabilidad (logs JSON, métricas y trazas) | `2ca5d3f` |
| 3 | Transferencia con control de concurrencia | `c68ca0f` |
| 4 | Pruebas de concurrencia y demo de la condición de carrera | `b329672` |
| 5 | Servicio de IA, circuit breaker, worker del outbox, prueba de resiliencia | `9e43e0c` |
| 6 | Bancs mock, sincronización por lotes, conciliación y ETL | `9773503` |
| 7 | Incidente simulado, diagnóstico, alertas y prueba de carga | `916a8ff` |
| 8 | Documentación y entrega (este documento incluido) | commit de la Fase 8 |

Componentes implementados con Claude Code: los tres servicios (`transaction-api`, `ai-service`, `bancs-mock`), el worker, el esquema y los índices SQL, el ETL, las pruebas (`tests/`), los scripts, las alertas de Prometheus, los 9 ADR y los documentos de la Fase 8.

### 3.3 Documentación de la Fase 8
`README.md`, `docs/DOCUMENTO_TECNICO.md`, `docs/POSTMORTEM.md`, `docs/diagrams/DIAGRAMAS.md` y **este archivo** los redactó Claude Code a partir del código, de los archivos de `evidence/` y del historial de git. Las cifras se copiaron de la evidencia guardada; las **proyecciones** (10.000 TPS) y los **diseños no implementados** (ciclo de vida del modelo de IA) están rotulados como tales dentro de los documentos.

---

## 4. Qué hizo la autora

Datos aportados por la autora el 19/09/2026:

| Qué | Detalle |
|---|---|
| **Alcance y restricciones** | Los definió ella. En particular, **eligió Python/FastAPI y PostgreSQL en lugar de Firebase**. |
| **Revisión** | Revisó el resultado de **cada fase** (con ayuda del chat, ver 3.1). |
| **Pruebas manuales** | Probó la API **a mano desde Swagger** (`/docs`). |
| **Pruebas automáticas** | Ejecutó ella misma las **pruebas unitarias (12/12)** y de **integración (2/2)** el **19/09/2026**. |
| **Código** | **No escribió ni modificó código ni documentación a mano.** Todo lo escribió Claude Code. |
| **Subida al repositorio (`git push`)** | El **primer push lo hizo ella**, con token. Las **fases 2 a 4 las subió Claude Code**. **Desde la fase 5 todos los push los hizo ella.** La regla que prohíbe a Claude Code hacer push (`CLAUDE.md`) se añadió después de la Fase 5 (commit `8836b32`). |
| **Código que leyó con explicación guiada** | `transfer_service.py`, `account_repository.py` y `demo_race_condition.py`. No declaró haber leído otras partes con explicación guiada. |

**Conceptos que la autora declara dominar:** bloqueo pesimista con orden fijo y prevención de deadlocks · idempotencia · patrón outbox · condición de carrera (demo inseguro vs. seguro) · circuit breaker · sincronización por lotes con Bancs · detección y respuesta al incidente de pool agotado.

**Conceptos que la autora declara que aún NO domina en detalle:** OpenTelemetry y trazas · reglas de alertas de Prometheus · detalles internos del ETL · configuración de la prueba de carga con Locust.

**Las demás demos y pruebas** (`make demo-race`, `make deadlock-demo`, `make load`, etc.) **no figuran entre las que la autora declaró haber ejecutado**: la última prueba de carga (Fase 8) la ejecutó Claude Code.

---

## 5. Qué se revisó y validó manualmente

Lo que **está verificado en el repositorio** (y cualquiera puede repetirlo):

| Qué | Cómo se validó | Evidencia |
|---|---|---|
| No hay race conditions | Pruebas de concurrencia: 100 transferencias simultáneas de 50,00 sobre 1.000,00 → exactamente 20 triunfan, saldo 0,00; suma cero; idempotencia; ledger | `evidence/test-data/test_concurrency_output.txt` (4/4) |
| El código inseguro sí falla | Demo comparativo contra una versión sin `FOR UPDATE` | `evidence/test-data/demo_race_condition_output.txt` |
| El orden de bloqueo evita deadlocks | 29 deadlocks vs. 0, contados en PostgreSQL | `evidence/incident/deadlock_demo.txt` |
| La IA no afecta a las transferencias | Medición con IA encendida, apagada y colgada | `evidence/ai-resilience/comparison.txt` |
| Bancs no se satura con lotes | Medición de degradación y demo de caída | `evidence/bancs/` |
| El pool agotado se detecta y diagnostica | Reproducción del incidente | `evidence/incident/exhaust_pool.txt` |
| Capacidad real | Prueba de carga con Locust | `evidence/load-test-results/` |

**Errores de la IA encontrados al probar** (evidencia de que se verificó y no se aceptó todo a ciegas):
1. La primera versión del endpoint `blocking-tree` tenía coste exponencial y **consumió 2,5 GB de RAM y congeló la API** durante el incidente; se corrigió y se añadió un test de regresión (ver `docs/POSTMORTEM.md`, Incidente 2).
2. La alerta `DatabasePoolExhausted` **no disparaba** en su primera versión; se descubrió al ejecutar el incidente real (ADR 0009).
3. Los `.sql` del directorio de inicialización de Postgres **no se ejecutaban** al montar carpetas enteras; se descubrió al verificar (comentario en `docker-compose.yml`).
4. En el modo `BackgroundTasks` de la IA se midieron efectos de latencia por DNS; se cambió el diseño por defecto (ADR 0006).
5. Un script de carga se quedaba girando 20 minutos por `set -e` + `pipefail` con Locust (comentario en `scripts/load_test.sh`).

**Limitaciones de esta validación (dicho con honestidad):**
- Las pruebas unitarias y de integración las ejecutó la autora el 19/09/2026 y sus salidas están guardadas en `evidence/test-data/test_unit_output.txt` y `test_integration_output.txt` (commit `7b36ab4`).
- La prueba de carga se ejecutó con el código final (tres corridas en total; el TPS sostenido varió 47 → 41,8 → 36,8), así que hay ruido de medición.
- **[COMPLETAR: si la autora encontró ella misma otros errores, o afirmaciones de la IA que no eran ciertas, listarlos aquí; no aportó ninguno.]** Los cinco errores de arriba los encontró la propia IA al ejecutar las pruebas, no la autora, hasta donde consta.

---

## 6. Qué NO se hizo con IA / qué no se delegó

Según lo que declaró la autora:

- **Las decisiones de alcance y de tecnología** (Python/FastAPI y PostgreSQL en lugar de Firebase) las tomó ella.
- **La revisión de cada fase, las pruebas manuales en Swagger y la ejecución de las pruebas unitarias y de integración** las hizo ella.
- **La subida al repositorio** la hizo ella (salvo las fases 2 a 4, que subió Claude Code).

Lo que **sí se delegó por completo en la IA:** escribir todo el código, las pruebas, los scripts y la documentación. La autora **no escribió ni modificó nada a mano**.

---

## 7. Riesgos y cómo se mitigaron

| Riesgo de usar IA | Mitigación aplicada |
|---|---|
| Código correcto "en apariencia" pero con fallos de concurrencia | Pruebas empíricas de concurrencia y demo contra la versión insegura; deadlocks contados en PostgreSQL, no en el script |
| Que la autora no entienda lo entregado | Comentarios en español que explican el **porqué**; ADR por cada decisión; documento técnico con la defensa; una fase por vez con revisión |
| Cifras inventadas o infladas | Toda cifra de la documentación sale de un archivo de `evidence/`; las proyecciones están rotuladas; hay una sección de limitaciones |
| Que la IA haga cambios irreversibles | Desde después de la Fase 5 hay una regla en `CLAUDE.md` (commit `8836b32`): **Claude Code nunca hace `git push`**; la autora sube los cambios. (Antes de esa regla, las fases 2 a 4 las subió Claude Code.) |
| Alucinaciones en la documentación | La autora revisó el resultado de cada fase; **[COMPLETAR: confirmar si revisó específicamente los documentos de la Fase 8 contra el código; no lo indicó]** |

> **Nota de transparencia sobre los commits.** Por instrucción de la autora (`CLAUDE.md`), los commits del proyecto **no incluyen** líneas `Co-Authored-By` ni atribución a Claude. Esa decisión es de estilo del repositorio y **no oculta** el uso de IA: este archivo existe justamente para declararlo.

---

## 8. Declaración final

Declaro que el uso de herramientas de IA en este proyecto es el descrito arriba, que no escribí ni modifiqué código ni documentación a mano, que revisé el resultado de cada fase y que puedo explicar y defender los conceptos que declaro dominar en la sección 4.

**Firma:** Cielo Morillo
**Fecha:** 19 de septiembre de 2026
