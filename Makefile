# Fisco.io - Makefile autodocumentado
# Framework de Administración Tributaria - Infraestructura, build, CI/CD local, monitoreo
# Uso: make [target]. Por defecto: make help

.DEFAULT_GOAL := help

# docker compose (v2) o docker-compose (v1). Sobrescribir: make COMPOSE_CMD=docker-compose
COMPOSE_CMD ?= docker compose
COMPOSE_FILE ?= docker-compose.yml

.PHONY: help up up-d down down-v ps logs logs-f infra-only build build-core build-workers
.PHONY: db-migrate db-rollback db-reset test test-core test-workers lint lint-core lint-workers
.PHONY: validate-asyncapi ci health clean clean-volumes

help: ## Lista todos los targets con descripción
	@echo "Fisco.io - Targets disponibles (make <target>)"
	@echo ""
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-20s\033[0m %s\n", $$1, $$2}'

# --- Infraestructura (Docker Compose) ---

up: ## Levantar todos los servicios (foreground)
	$(COMPOSE_CMD) -f $(COMPOSE_FILE) up

up-d: ## Levantar todos los servicios (detached)
	$(COMPOSE_CMD) -f $(COMPOSE_FILE) up -d

down: ## Bajar servicios y redes (volúmenes se mantienen)
	$(COMPOSE_CMD) -f $(COMPOSE_FILE) down

down-v: ## Bajar servicios y eliminar volúmenes
	$(COMPOSE_CMD) -f $(COMPOSE_FILE) down -v

ps: ## Estado de contenedores del proyecto
	$(COMPOSE_CMD) -f $(COMPOSE_FILE) ps

logs: ## Logs de todos los servicios (ARGS=-f para follow)
	$(COMPOSE_CMD) -f $(COMPOSE_FILE) logs $(ARGS)

logs-f: ## Logs en tiempo real (follow)
	$(COMPOSE_CMD) -f $(COMPOSE_FILE) logs -f

infra-only: ## Levantar solo postgres, redis, redpanda (sin core-engine ni workers)
	$(COMPOSE_CMD) -f $(COMPOSE_FILE) up -d postgres redis redpanda

# --- Build ---

build: ## Build de todas las imágenes
	$(COMPOSE_CMD) -f $(COMPOSE_FILE) build

build-core: ## Build solo core-engine
	$(COMPOSE_CMD) -f $(COMPOSE_FILE) build core-engine

build-workers: ## Build solo calculation-workers
	$(COMPOSE_CMD) -f $(COMPOSE_FILE) build calculation-workers

# --- Base de datos ---

db-migrate: ## Ejecutar migraciones en core-engine (requiere contenedores up o Rails local)
	$(COMPOSE_CMD) -f $(COMPOSE_FILE) exec core-engine bin/rails db:migrate || (cd services/core-engine && bundle exec rails db:migrate)

db-rollback: ## Rollback última migración en core-engine
	$(COMPOSE_CMD) -f $(COMPOSE_FILE) exec core-engine bin/rails db:rollback || (cd services/core-engine && bundle exec rails db:rollback)

db-reset: ## Drop, create y migrate (útil para desarrollo)
	$(COMPOSE_CMD) -f $(COMPOSE_FILE) exec core-engine bin/rails db:drop db:create db:migrate || (cd services/core-engine && bundle exec rails db:drop db:create db:migrate)

# --- Tests y calidad (equivalente a CI local) ---

test: test-core test-workers ## Ejecutar todos los tests (core-engine RSpec + calculation-workers pytest)

test-core: ## RSpec en core-engine
	cd services/core-engine && bundle exec rspec --format documentation

test-workers: ## pytest en calculation-workers
	cd services/calculation-workers && pytest -v

lint: lint-core lint-workers ## Lint de todo (RuboCop + ruff)

lint-core: ## RuboCop en core-engine
	cd services/core-engine && bundle exec rubocop --format simple

lint-workers: ## ruff en calculation-workers
	cd services/calculation-workers && pip install -q ruff && ruff check src/

validate-asyncapi: ## Validar docs/asyncapi/events.yaml con AsyncAPI CLI
	npx -y @asyncapi/cli@latest validate docs/asyncapi/events.yaml

ci: lint test validate-asyncapi ## Réplica local del CI: lint + test + validate-asyncapi

# --- Monitoreo / salud ---

health: ## Comprobar que postgres, redis y (si está up) core-engine respondan
	@echo "Postgres:" && (pg_isready -h localhost -p 5432 -U fisco 2>/dev/null || docker compose -f $(COMPOSE_FILE) exec -T postgres pg_isready -U fisco) && echo "  OK" || echo "  No disponible"
	@echo "Redis:" && (redis-cli -h localhost -p 6379 ping 2>/dev/null | grep -q PONG || docker compose -f $(COMPOSE_FILE) exec -T redis redis-cli ping | grep -q PONG) && echo "  OK" || echo "  No disponible"
	@echo "Core Engine (si está up):" && (curl -sf http://localhost:3000/up >/dev/null && echo "  OK" || echo "  No disponible o no levantado")

# --- Limpieza ---

clean: down ## Parar contenedores y quitar containers huérfanos
	$(COMPOSE_CMD) -f $(COMPOSE_FILE) rm -f 2>/dev/null || true

clean-volumes: down-v ## Alias de down-v (bajar y eliminar volúmenes)
