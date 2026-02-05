# Runme - Scripts y comandos

Los comandos de Rails, bundle, pip y tests se ejecutan **siempre dentro de los contenedores Docker**, no en el host.

## Uso recomendado

Desde la raíz del repo, usá el **Makefile**:

```bash
make bundle        # bundle install (core-engine)
make migrate      # rails db:migrate (core-engine)
make console      # rails console (core-engine)
make test         # rspec + pytest
make lint         # rubocop + ruff
```

## Ejecutar comandos ad hoc en Docker

- **Core Engine** (Rails, bundle, rspec, rubocop):
  ```bash
  docker compose run --rm core-engine bundle exec <comando>
  ```
  Ejemplo: `docker compose run --rm core-engine bundle exec rails db:migrate`

- **Calculation Workers** (pip, pytest, ruff):
  ```bash
  docker compose run --rm calculation-workers <comando>
  ```
  Ejemplo: `docker compose run --rm calculation-workers pytest -v`

Cualquier script en este directorio que invoque Rails o Python debe usar estos contenedores (o `make`) para mantener consistencia con el resto del proyecto.
