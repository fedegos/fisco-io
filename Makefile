# Fisco.io - Makefile
# Framework de Administración Tributaria - Event-sourced tax administration
#
# Convención: Rails, bundle, pip, pytest, migraciones, etc. se ejecutan SIEMPRE
# dentro de los contenedores (core-engine o calculation-workers) vía docker compose.

COMPOSE = docker compose
CORE = $(COMPOSE) run --rm core-engine
WORKERS = $(COMPOSE) run --rm calculation-workers

.PHONY: help up down build build-core-engine restart restart-postgres restart-redis restart-redpanda restart-core-engine restart-calculation-workers logs logs-postgres logs-redis logs-redpanda logs-core-engine logs-calculation-workers bundle migrate console routes test-db test-core test-workers test lint-core lint-workers lint validate-asyncapi pip-install

.DEFAULT_GOAL := help

help: ## Muestra esta ayuda (extrae descripciones de cada target)
	@echo "-----------------------------------------------------------------------"
	@echo "Fisco.io - Comandos disponibles (todos corren en Docker)"
	@echo "-----------------------------------------------------------------------"
	@grep -Eh '^[a-zA-Z0-9_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-28s\033[0m %s\n", $$1, $$2}'

up: ## Levantar stack (postgres, redis, redpanda, core-engine) en segundo plano
	$(COMPOSE) up -d postgres redis redpanda
	$(COMPOSE) up -d core-engine

down: ## Bajar stack (detiene y elimina contenedores)
	$(COMPOSE) down

build: ## Construir/actualizar imágenes Docker de core-engine y calculation-workers (hacer tras cambiar Gemfile)
	$(COMPOSE) build

build-core-engine: ## Reconstruir solo la imagen core-engine (hacer tras cambiar Gemfile/Gemfile.lock)
	$(COMPOSE) build core-engine

# --- Restart por servicio y conjunto ---
restart: ## Reiniciar todos los servicios del stack
	$(COMPOSE) restart

restart-postgres: ## Reiniciar solo el servicio postgres
	$(COMPOSE) restart postgres

restart-redis: ## Reiniciar solo el servicio redis
	$(COMPOSE) restart redis

restart-redpanda: ## Reiniciar solo el servicio redpanda (Kafka)
	$(COMPOSE) restart redpanda

restart-core-engine: ## Reiniciar solo la app Rails (core-engine)
	$(COMPOSE) restart core-engine

restart-calculation-workers: ## Reiniciar solo el servicio calculation-workers
	$(COMPOSE) restart calculation-workers

# --- Logs por servicio y conjunto (-f para seguir en tiempo real) ---
logs: ## Ver logs de todos los servicios (seguir en tiempo real)
	$(COMPOSE) logs -f

logs-postgres: ## Logs del servicio postgres (seguir con -f)
	$(COMPOSE) logs -f postgres

logs-redis: ## Logs del servicio redis (seguir con -f)
	$(COMPOSE) logs -f redis

logs-redpanda: ## Logs del servicio redpanda (seguir con -f)
	$(COMPOSE) logs -f redpanda

logs-core-engine: ## Logs de la app Rails - core-engine (seguir con -f)
	$(COMPOSE) logs -f core-engine

logs-calculation-workers: ## Logs del servicio calculation-workers (seguir con -f)
	$(COMPOSE) logs -f calculation-workers

# --- Core Engine (Rails) - siempre en contenedor ---
bundle: ## bundle install en core-engine (instala gems; usa vendor/bundle si está configurado)
	$(CORE) bundle install

migrate: ## Ejecutar migraciones de Rails (entorno development)
	$(CORE) bundle exec rails db:migrate

console: ## Abrir consola Rails en el contenedor core-engine
	$(CORE) bundle exec rails console

routes: ## Listar rutas definidas en la app Rails
	$(CORE) bundle exec rails routes

test-db: ## Crear DB de test y correr migraciones; instala gems en vendor/bundle si hace falta
	$(CORE) sh -c "bundle config set --local path vendor/bundle && bundle install && env RAILS_ENV=test bundle exec rails db:create db:migrate"

test-core: test-db ## Ejecutar specs RSpec del core-engine
	$(CORE) env RAILS_ENV=test bundle exec rspec --format documentation

lint-core: ## Lint Ruby (RuboCop) en core-engine
	$(CORE) bundle exec rubocop --format simple

# --- Calculation Workers (Python) - siempre en contenedor ---
pip-install: ## Instalar dependencias Python en calculation-workers (requirements.txt)
	$(WORKERS) pip install -r requirements.txt

test-workers: ## Ejecutar tests pytest de calculation-workers
	$(WORKERS) pytest -v

lint-workers: ## Lint Python (ruff) en calculation-workers
	$(WORKERS) ruff check src/

# --- Agregados ---
test: test-core test-workers  ## Ejecutar todos los tests (core-engine + calculation-workers)

lint: lint-core lint-workers  ## Ejecutar lint en ambos servicios (RuboCop + ruff)

validate-asyncapi: ## Validar spec AsyncAPI con npx (requiere npx en el host)
	npx -y @asyncapi/cli@latest validate docs/asyncapi/events.yaml
