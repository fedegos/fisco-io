# Runme - Scripts y comandos

Los comandos de Rails, bundle, pip y tests se ejecutan **siempre dentro de los contenedores Docker**, no en el host.

## Cómo probar lo que hicimos hasta ahora

Desde la **raíz del repo** (`fisco-io/`):

1. **Levantar el stack** (Postgres, Redis, Redpanda, Rails):
   ```bash
   make up
   ```
   La primera vez puede tardar si tenés que construir imágenes: `make build` y luego `make up`.

2. **Migrar y cargar datos de demo**:
   ```bash
   make migrate
   make seed
   ```
   Para **borrar datos de demo y volver a cargar** (p. ej. tras cambiar los seeds): `make seed-replant`.

3. **Probar la web**:
   - Abrí en el navegador: **http://localhost:3000**
   - Redirige a **http://localhost:3000/contribuyente/obligaciones** (lista de obligaciones; con seeds verás 3 obligaciones con saldos).
   - Navegá a **Operadores** → **http://localhost:3000/operadores** (panel de operadores).

4. **Probar la API** (desde otra terminal o con Postman/curl):
   ```bash
   # Listar obligaciones
   curl -s http://localhost:3000/api/obligations | jq

   # Listar sujetos
   curl -s http://localhost:3000/api/subjects | jq

   # Una obligación por ID (usar un obligation_id del listado anterior)
   curl -s http://localhost:3000/api/obligations/<OBLIGATION_ID> | jq

   # Crear sujeto
   curl -s -X POST http://localhost:3000/api/subjects \
     -H "Content-Type: application/json" \
     -d '{"tax_id":"30-11111111-1","legal_name":"Nuevo SA","trade_name":"Nuevo"}' | jq

   # Crear liquidación en una obligación
   curl -s -X POST "http://localhost:3000/api/obligations/<OBLIGATION_ID>/liquidations" \
     -H "Content-Type: application/json" \
     -d '{"period":"2024-03","amount":5000}' | jq

   # Registrar pago en una obligación
   curl -s -X POST "http://localhost:3000/api/obligations/<OBLIGATION_ID>/payments" \
     -H "Content-Type: application/json" \
     -d '{"amount":1000}' | jq
   ```
   Si no tenés `jq`, podés omitirlo: `curl -s http://localhost:3000/api/obligations`.

5. **Tests**:
   ```bash
   make test
   ```

6. **Bajar todo**:
   ```bash
   make down
   ```

## Uso recomendado del Makefile

Desde la raíz del repo:

```bash
make bundle        # bundle install (core-engine)
make migrate       # rails db:migrate (core-engine)
make seed          # rails db:seed (datos de demo)
make seed-replant  # borrar datos de demo y volver a db:seed
make console       # rails console (core-engine)
make routes        # listar rutas Rails
make test          # rspec + pytest
make lint          # rubocop + ruff
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
