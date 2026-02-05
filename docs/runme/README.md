# Fisco.io - Scripts de apoyo al desarrollo

Scripts ejecutables para uso con [Runme](https://runme.dev). Cada bloque de código se puede ejecutar desde la UI de Runme o desde la terminal.

Requisitos recomendados: Docker, Ruby 3.2+, Python 3.11+, Node (para AsyncAPI CLI).

---

## Requisitos

<!-- runme
name: Verificar versiones
description: Comprueba Docker, Ruby, Python y Node
-->
```bash
echo "Docker: $(docker --version 2>/dev/null || echo 'no instalado')"
echo "Ruby:   $(ruby --version 2>/dev/null || echo 'no instalado')"
echo "Python: $(python3 --version 2>/dev/null || echo 'no instalado')"
echo "Node:   $(node --version 2>/dev/null || echo 'no instalado')"
```

---

## Entorno

<!-- runme
name: Copiar .env.example a .env
description: Crea .env desde la plantilla (desde la raíz del repo)
-->
```bash
cp .env.example .env && echo "Creado .env desde .env.example"
```

---

## Infraestructura

<!-- runme
name: Levantar solo infra (Postgres, Redis, Redpanda)
description: Servicios de apoyo sin core-engine ni workers
-->
```bash
docker compose up -d postgres redis redpanda
```

<!-- runme
name: Levantar todos los servicios
description: Postgres, Redis, Redpanda, core-engine, calculation-workers
-->
```bash
docker compose up -d
```

<!-- runme
name: Estado de contenedores
description: Lista contenedores del proyecto
-->
```bash
docker compose ps
```

---

## Core Engine

<!-- runme
name: Instalar dependencias (core-engine)
description: bundle install en services/core-engine
-->
```bash
cd services/core-engine && bundle install
```

<!-- runme
name: Migraciones (core-engine)
description: Ejecuta rails db:migrate (requiere Postgres y DATABASE_URL)
-->
```bash
cd services/core-engine && bundle exec rails db:migrate
```

<!-- runme
name: Tests RSpec (core-engine)
description: Ejecuta todos los specs del core-engine
-->
```bash
cd services/core-engine && bundle exec rspec --format documentation
```

<!-- runme
name: Lint RuboCop (core-engine)
description: Ejecuta RuboCop en services/core-engine
-->
```bash
cd services/core-engine && bundle exec rubocop --format simple
```

<!-- runme
name: Consola Rails (core-engine)
description: Abre rails console (requiere Postgres y DATABASE_URL)
-->
```bash
cd services/core-engine && bundle exec rails console
```

---

## Calculation Workers

<!-- runme
name: Instalar dependencias (calculation-workers)
description: pip install -r requirements.txt
-->
```bash
cd services/calculation-workers && pip install -r requirements.txt
```

<!-- runme
name: Tests pytest (calculation-workers)
description: Ejecuta pytest en services/calculation-workers
-->
```bash
cd services/calculation-workers && pytest -v
```

<!-- runme
name: Lint ruff (calculation-workers)
description: Ejecuta ruff check en src/
-->
```bash
cd services/calculation-workers && pip install -q ruff && ruff check src/
```

---

## AsyncAPI

<!-- runme
name: Validar spec AsyncAPI
description: Valida docs/asyncapi/events.yaml con AsyncAPI CLI
-->
```bash
npx -y @asyncapi/cli@latest validate docs/asyncapi/events.yaml
```

---

## CI local

<!-- runme
name: Ejecutar CI local (make ci)
description: Réplica del pipeline CI: lint + test + validate-asyncapi
-->
```bash
make ci
```

<!-- runme
name: Solo tests (make test)
description: Ejecuta RSpec y pytest
-->
```bash
make test
```

<!-- runme
name: Solo lint (make lint)
description: Ejecuta RuboCop y ruff
-->
```bash
make lint
```

---

Fisco.io — Framework de Administración Tributaria
