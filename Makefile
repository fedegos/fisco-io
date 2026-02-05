# Fisco.io - Makefile
# Framework de Administración Tributaria - Event-sourced tax administration
#
# Convención: Rails, bundle, pip, pytest, migraciones, etc. se ejecutan SIEMPRE
# dentro de los contenedores (core-engine o calculation-workers) vía docker compose.

COMPOSE = docker compose
CORE = $(COMPOSE) run --rm core-engine
WORKERS = $(COMPOSE) run --rm calculation-workers

.PHONY: help up down build

help:
	@echo "Fisco.io - Comandos disponibles (todos corren en Docker):"
	@echo "  make up          - Levantar stack (postgres, redis, redpanda, core-engine)"
	@echo "  make down        - Bajar stack"
	@echo "  make build       - Construir imágenes"
	@echo "  make bundle      - bundle install (core-engine)"
	@echo "  make migrate     - rails db:migrate (core-engine)"
	@echo "  make console     - rails console (core-engine)"
	@echo "  make test        - rspec + pytest"
	@echo "  make test-core   - rspec (core-engine)"
	@echo "  make test-workers - pytest (calculation-workers)"
	@echo "  make lint        - rubocop + ruff"
	@echo "  make lint-core   - rubocop (core-engine)"
	@echo "  make lint-workers - ruff (calculation-workers)"
	@echo "  make validate-asyncapi - Validar spec AsyncAPI (npx, host)"

up:
	$(COMPOSE) up -d postgres redis redpanda
	$(COMPOSE) up -d core-engine

down:
	$(COMPOSE) down

build:
	$(COMPOSE) build

# --- Core Engine (Rails) - siempre en contenedor ---
bundle:
	$(CORE) bundle install

migrate:
	$(CORE) bundle exec rails db:migrate

console:
	$(CORE) bundle exec rails console

routes:
	$(CORE) bundle exec rails routes

# Prepara la DB de test (bundle, crear y migrar) y corre RSpec
test-core: test-db
	$(CORE) env RAILS_ENV=test bundle exec rspec --format documentation

# Instala gems en vendor/bundle (volumen) y crea/migra DB de test
test-db:
	$(CORE) sh -c "bundle config set --local path vendor/bundle && bundle install && env RAILS_ENV=test bundle exec rails db:create db:migrate"

lint-core:
	$(CORE) bundle exec rubocop --format simple

# --- Calculation Workers (Python) - siempre en contenedor ---
pip-install:
	$(WORKERS) pip install -r requirements.txt

test-workers:
	$(WORKERS) pytest -v

lint-workers:
	$(WORKERS) ruff check src/

# --- Agregados ---
test: test-core test-workers

lint: lint-core lint-workers

# AsyncAPI (npx suele correr en host si no hay servicio Node)
validate-asyncapi:
	npx -y @asyncapi/cli@latest validate docs/asyncapi/events.yaml
