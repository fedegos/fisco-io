# Operaciones de negocio CQRS/DDD

# Business Operations (CQRS/DDD)

## Principio rector

**Los agregados no exponen CRUD genérico.** Toda operación tiene un **nombre de negocio**, un **comando**, un **evento** y (donde aplique) un **endpoint** específico, con validaciones e invariantes propias. Esto permite distinguir en el futuro contextos distintos (ej. alta de oficio vs alta voluntaria) aunque la firma sea similar.

**Regla de código:** El código se mantiene en **inglés** (nombres de comandos, eventos, clases, métodos). La documentación de dominio y la API pública pueden usar términos en español (ej. rutas `/api/sujetos/empadronar`); internamente las clases son `EnrollSubject`, `SubjectEnrolled`, etc.

---

## 1. Sujetos (Identity) – Agregado Subject

| Operación de negocio (nombre negocio) | Comando (código, inglés)       | Evento (código, inglés)          | Parámetros permitidos | Invariantes / validaciones | Endpoint API |
| ------------------------------------ | ------------------------------ | -------------------------------- | ----------------------- | -------------------------- | ------------ |
| **Empadronar** (alta)                 | `EnrollSubject`                | `SubjectEnrolled`                | tax_id, legal_name, trade_name (opcional) | tax_id y legal_name obligatorios | POST /api/sujetos/empadronar |
| **Actualizar datos de contacto**      | `UpdateSubjectContactData`     | `SubjectContactDataUpdated`      | legal_name, trade_name | — | PATCH /api/sujetos/:id/datos_contacto |
| **Mudar domicilio**                   | `ChangeSubjectDomicile`        | `SubjectDomicileChanged`         | digital_domicile_id     | — | PATCH /api/sujetos/:id/domicilio |
| **Cesar**                             | `CeaseSubject`                 | `SubjectCeased`                  | —                       | Sujeto activo | PATCH /api/sujetos/:id/cesar |
| **Corregir por fuerza mayor**         | `CorrectSubjectByForceMajeure` | `SubjectCorrectedByForceMajeure` | Campos permitidos (legal_name, trade_name, digital_domicile_id) + **operator_observations** (obligatorio) | operator_observations no vacío; al menos un atributo a corregir | PATCH /api/sujetos/:id/corregir_fuerza_mayor |

### Read model (Subject)

- Tabla: `subjects` (SubjectReadModel).
- Campos: subject_id, tax_id, legal_name, trade_name, digital_domicile_id, status, created_at, updated_at, etc.
- Proyección: `Identity::Projections::SubjectProjection` aplica SubjectEnrolled, SubjectContactDataUpdated, SubjectDomicileChanged, SubjectCeased, SubjectCorrectedByForceMajeure.

---

## 2. Partidas (Obligations) – Agregado TaxObligation

| Operación de negocio          | Comando (código, inglés)             | Evento (código, inglés)               | Parámetros permitidos | Invariantes / validaciones | Endpoint API |
| ----------------------------- | ------------------------------------ | ------------------------------------- | --------------------- | -------------------------- | ------------ |
| **Abrir partida** (alta)      | `OpenObligation`                     | `ObligationOpened`                    | primary_subject_id, tax_type, role, external_id (opcional), obligation_id (opcional, UUID) | primary_subject_id y tax_type obligatorios | POST /api/partidas/abrir |
| **Registrar revalúo**         | `RegisterRevaluation`                | `RevaluationRegistered`               | obligation_id, year, value, operator_observations (opcional) | year y value válidos; obligación existente | POST /api/partidas/:id/revaluos |
| **Cerrar partida**            | `CloseObligation`                     | `ObligationClosed`                    | obligation_id (vía :id) | Partida abierta | PATCH /api/partidas/:id/cerrar |
| **Corregir por fuerza mayor** | `CorrectObligationByForceMajeure`    | `ObligationCorrectedByForceMajeure`   | external_id (u otros permitidos) + **operator_observations** (obligatorio) | operator_observations no vacío | PATCH /api/partidas/:id/corregir_fuerza_mayor |

### Revalúos

- Persistencia: modelo `FiscalValuation` (obligation_id, year, value).
- Proyección: `Obligations::Projections::FiscalValuationProjection` aplica RevaluationRegistered; si ya existe registro para obligation_id + year, se actualiza (revalúo reemplaza valor vigente para ese período).

### Read model (Obligation)

- Tabla: `tax_account_balances` (TaxAccountBalance).
- Proyección: `Obligations::Projections::TaxAccountBalanceProjection` aplica ObligationOpened, ObligationClosed, ObligationCorrectedByForceMajeure (y eventos de liquidaciones/pagos).

---

## 3. Modificación por fuerza mayor (regla transversal)

- **Siempre** que se permita una corrección excepcional (error material, datos de origen incorrectos, etc.):
  - Comando/evento específico: `CorrectSubjectByForceMajeure` / `CorrectObligationByForceMajeure`.
  - **operator_observations** obligatorio en el comando y persistido en el evento (y opcionalmente en metadata o tabla de auditoría).
  - Validación: rechazar si observaciones están vacías.
  - En eventos: incluir `operator_observations` en `data` (y opcionalmente `corrected_fields` para trazabilidad).

---

## 4. Eventos y trazabilidad

- Cada evento lleva en `data` los campos relevantes para la operación y para las proyecciones.
- Para fuerza mayor: `data` debe incluir `operator_observations` y, si se implementa, lista de campos modificados.
- Opcional: `metadata` del evento con operator_id, timestamp, para auditoría.

---

## 5. Catálogo de operaciones por agregado (resumen)

- **Subject:** Enroll, UpdateContactData, ChangeDomicile, Cease, CorrectByForceMajeure.
- **TaxObligation (partida):** Open, RegisterRevaluation, Close, CorrectByForceMajeure.

La UI (listado de acciones, menús, rutas) puede generarse o configurarse a partir de este catálogo para mantener consistencia y ampliabilidad.
