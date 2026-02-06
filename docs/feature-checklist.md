# Checklist por feature / Feature checklist

Para cada plan de feature o cambio de dominio, incluir explícitamente los siguientes ítems. Este documento es la referencia; los planes concretos deben listar qué aplica en cada caso.

## TDD (Test-Driven Development)

- **Paso "Tests (TDD)" antes de implementación**: en el plan, indicar qué comportamientos se testean (dominio, handlers, API) y en qué orden.
- Orden recomendado: tests unitarios de dominio (agregados, value objects, comandos) → handlers y proyecciones → integración/API si aplica.
- No saltar a implementación sin test que documente el comportamiento.

## Eventos (AsyncAPI)

- **Si hay eventos nuevos o modificados**: incluir en el plan "Actualizar [docs/asyncapi/events.yaml](asyncapi/events.yaml): listar eventos/campos/canales".
- Añadir o actualizar en `channels` y `components.messages` (y schemas si se detalla payload).
- Validar con `make validate-asyncapi` (o `npx @asyncapi/cli validate docs/asyncapi/events.yaml`).

## API REST (OpenAPI)

- **Si hay endpoints nuevos o modificados**: incluir en el plan "Actualizar OpenAPI: listar paths y operaciones".
- Especificación en [docs/openapi/openapi.yaml](openapi/openapi.yaml).
- Incluir paths, operaciones, request/response schemas, códigos HTTP y ejemplos para comandos/consultas principales.

## ADR (Architecture Decision Records)

- **Si hay decisión arquitectónica o de diseño**: incluir en el plan "Crear/actualizar ADR en [docs/adr/](adr/): título y resumen".
- No es obligatorio un ADR por cada feature pequeña; solo cuando el cambio implique decisión relevante (nueva tecnología, patrón estructural, modelo de consistencia, integración externa, etc.).
- Formato: Contexto, Decisión, Consecuencias (positivas/negativas), Referencias; estado Accepted/Deprecated/etc.

---

## Resumen en tabla

| Área        | Inclusión en el plan                                                                 |
| ----------- | ------------------------------------------------------------------------------------- |
| **TDD**     | Paso "Tests (TDD)" antes de implementación: qué se testea (dominio, handlers, API).   |
| **Eventos** | Si hay eventos nuevos/modificados → Actualizar AsyncAPI: listar eventos/campos/canales. |
| **API REST**| Si hay endpoints nuevos/modificados → Actualizar OpenAPI: listar paths y operaciones.  |
| **ADR**     | Si hay decisión arquitectónica → Crear/actualizar ADR: título y resumen.              |

---

Fisco.io — Framework de Administración Tributaria
