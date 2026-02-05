# ADR 001: Event Sourcing as Source of Truth

**Estado / Status**: Accepted

**Fecha / Date**: 2025-02-05

## Contexto / Context

Fisco.io is a tax administration framework that must support auditability, traceability, reprocessing of historical data, and evolution of the domain model over time. Traditional CRUD and state-based persistence make it difficult to answer "what happened when" and to rebuild read models from a single source of truth.

## Decisión / Decision

Fisco.io adopts **Event Sourcing** as the source of truth for all state changes. Every state change is represented as an immutable event; current state is derived by replaying events. Events are stored in an append-only event store (PostgreSQL); projections consume events to build optimized read models (CQRS).

This aligns with the architecture described in `.cursorrules`: Event Sourcing First, CQRS, and Domain-Driven Design.

## Consecuencias / Consequences

### Positivas / Positive

- **Auditoría**: Full history of every change; no data loss.
- **Trazabilidad**: "What happened when" is always answerable from the event stream.
- **Reproceso**: Projections can be rebuilt from events; new read models can be added without migrating legacy data.
- **Evolución del modelo**: Event versioning and upcasting allow schema evolution while preserving history.
- **Múltiples proyecciones**: Same event stream can feed multiple read models (balances, history, analytics).

### Negativas / Negative

- **Complejidad**: Developers must think in events and projections; learning curve.
- **Almacenamiento**: Event store grows over time; snapshots and retention policies may be needed.
- **Consistencia eventual**: Read models are eventually consistent; queries may lag behind writes.
- **Consultas ad-hoc**: Querying "current state" requires projections or replay; no direct SQL over raw events for arbitrary queries.

## Referencias / References

- Fisco.io `.cursorrules` — Event Sourcing Implementation Guide, Event Store Schema.
- DOMAIN_SPECIFICATION.md — Domain model and event catalog.
- Martin Fowler — [Event Sourcing](https://martinfowler.com/eaaDev/EventSourcing.html).
- Vaughn Vernon — "Implementing Domain-Driven Design".

---

Fisco.io — Framework de Administración Tributaria
