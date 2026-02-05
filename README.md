# Fisco.io

**Framework de Administración Tributaria** — Event-sourced tax administration.

Framework de motor tributario basado en event sourcing y CQRS, pensado para reemplazar sistemas legacy en administraciones fiscales.

## Stack

- **Core Engine**: Ruby on Rails 8 — event store, agregados, comandos, proyecciones.
- **Calculation Workers**: Python — cálculos pesados y consumidores Kafka.
- **Infra**: PostgreSQL, Redis, Redpanda (Kafka), Docker Compose.

## Primeros pasos

Requisitos: **Docker** y **Docker Compose**. No hace falta tener Ruby ni Python instalados en el host.

1. Clonar el repo y (opcional) copiar `.env.example` a `.env`.
2. Levantar el stack:
   ```bash
   docker compose up -d postgres redis redpanda
   docker compose up -d core-engine
   ```
   O usar el Makefile:
   ```bash
   make up
   ```
3. Instalar dependencias y migrar (dentro de los contenedores):
   ```bash
   make bundle
   make migrate
   ```
4. La API Rails queda en `http://localhost:3000`.

## Comandos comunes

Todos los comandos de Rails, bundle, pip y tests se ejecutan **dentro de los contenedores** vía `make` o `docker compose run --rm <servicio> ...`.

| Acción              | Comando              |
|---------------------|----------------------|
| Levantar stack      | `make up`            |
| Bajar stack         | `make down`          |
| Instalar deps Ruby  | `make bundle`        |
| Migraciones         | `make migrate`       |
| Consola Rails       | `make console`       |
| Tests (todo)        | `make test`          |
| Tests core-engine   | `make test-core`     |
| Tests workers       | `make test-workers`  |
| Lint (todo)         | `make lint`          |
| Validar AsyncAPI    | `make validate-asyncapi` |

Ejemplos directos con Docker:

```bash
# Un comando en core-engine
docker compose run --rm core-engine bundle exec rails db:migrate

# Un comando en calculation-workers
docker compose run --rm calculation-workers pytest -v
```

## Documentación

- [Especificación de dominio](DOMAIN_SPECIFICATION.md)
- [ADR 001: Event Sourcing](docs/adr/001-event-sourcing-choice.md)
- [CI/CD y cómo reproducir localmente](docs/cicd.md)

## Licencia

Por definir.
