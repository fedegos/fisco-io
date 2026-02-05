# CI/CD - Fisco.io

## Pipeline

El CI (GitHub Actions) ejecuta:

- **Core Engine**: RuboCop, RSpec (Ruby 3.2, PostgreSQL, Redis en el job).
- **Calculation Workers**: Ruff, pytest (Python 3.12).
- **AsyncAPI**: Validación del spec con `@asyncapi/cli`.

## Cómo reproducir localmente

Las mismas pruebas y lint se pueden ejecutar en local **sin instalar Ruby ni Python en el host**: todo corre dentro de los contenedores Docker.

### Requisitos

- Docker
- Docker Compose

### Comandos

Desde la raíz del repo:

```bash
# 1. Levantar dependencias (postgres, redis, redpanda)
make up
# o solo infra: docker compose up -d postgres redis redpanda

# 2. Core Engine: tests (crea/migra DB de test y corre RSpec)
make test-core    # RAILS_ENV=test, db:create db:migrate + rspec

# 3. Lint
make lint-core    # RuboCop
make lint-workers # Ruff
make test-workers # pytest

# Todo junto
make test         # test-core + test-workers
make lint         # lint-core + lint-workers
```

Cada comando usa `docker compose run --rm core-engine ...` o `... calculation-workers ...`, así que no hace falta tener `bundle`, `rails`, `pip` ni `pytest` instalados en la máquina.

### Validar AsyncAPI

La validación del spec AsyncAPI usa `npx` en el host (no hay servicio Node en el Compose):

```bash
make validate-asyncapi
```

Si no tenés Node instalado, el job de CI sigue siendo la referencia.
