# Fisco.io

**Framework de Administración Tributaria** — Event-sourced tax administration.

Cloud-native, event-sourced tax accounting engine designed to replace legacy mainframe systems. Built for modern governments and tax authorities.

## Architecture

- **Event Sourcing**: Every state change is an event; events are the source of truth.
- **CQRS**: Separate write models (commands) from read models (queries and projections).
- **Domain-Driven Design**: Bounded contexts (Identity, Obligations, Declarations, Payments, Agents, Configuration) with ubiquitous language (Spanish/English bilingual).

## Technology Stack

- **Core Engine**: Ruby on Rails 8 — event store, aggregates, API.
- **Calculation Workers**: Python — heavy computation and data processing.
- **Event Store**: PostgreSQL (custom event sourcing tables).
- **Message Broker**: Apache Kafka (Redpanda for development).
- **Cache**: Redis.
- **Background Jobs**: Good Job (PostgreSQL-based).

## Repository Structure

```
fisco-io/
├── services/
│   ├── core-engine/     # Rails app — event store, aggregates, commands, projections
│   └── calculation-workers/  # Python workers — calculators, processors, consumers
├── docs/
│   ├── adr/             # Architecture Decision Records
│   └── asyncapi/         # Event API specification (AsyncAPI)
├── .cursorrules         # Architecture and conventions
└── DOMAIN_SPECIFICATION.md  # Business domain specification
```

## Requirements

- Ruby >= 3.2 (core-engine)
- Python >= 3.11 (calculation-workers)
- PostgreSQL 15+
- Redis 7
- Docker and Docker Compose (recommended for local development)

## Getting Started

1. Clone the repository.
2. Copy `.env.example` to `.env` and adjust variables (DATABASE_URL, REDIS_URL, KAFKA_BROKERS).
3. With Docker Compose:
   ```bash
   docker-compose up -d postgres redis redpanda
   cd services/core-engine && bundle install && bin/rails db:migrate
   docker-compose up core-engine calculation-workers
   ```
4. Without Docker: install PostgreSQL and Redis, set DATABASE_URL and REDIS_URL, then run migrations and start the Rails server from `services/core-engine`.

## Testing

- **Core Engine**: RSpec — run from `services/core-engine` with `bundle exec rspec`.
- **Calculation Workers**: pytest — run from `services/calculation-workers` with `pytest`.

## Documentation

- [.cursorrules](.cursorrules) — Architecture principles, naming conventions, and project structure.
- [DOMAIN_SPECIFICATION.md](DOMAIN_SPECIFICATION.md) — Complete business domain specification (subjects, obligations, payments, interest, prescription, collection agents).
- [docs/adr/](docs/adr/) — Architecture Decision Records.
- [docs/asyncapi/](docs/asyncapi/) — Event contracts (AsyncAPI).

## Contributing

Contributions are welcome. Please follow the conventions in `.cursorrules` (commit messages, test naming, bilingual comments).

## License

See LICENSE file.

---

Fisco.io — Framework de Administración Tributaria  
Built for modern governments.
