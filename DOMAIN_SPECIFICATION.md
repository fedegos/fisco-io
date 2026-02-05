# Fisco.io - Especificación de Dominio

# Domain Specification

## 1. Sujeto (Subject) y Obligaciones Múltiples

### Concepto Central

Un **Sujeto** puede tener **múltiples Obligaciones Tributarias** simultáneas:

- Mismo impuesto, diferentes objetos (Inmobiliario: sucursal A, sucursal B)
- Diferentes impuestos (Ingresos Brutos, Inmobiliario, Automotor)
- Diferentes roles (Contribuyente, Agente de Recaudación, Responsable Sustituto)
- Diferentes regímenes como agente (SIRCREB, General Percepción, General Retención)

### Ejemplo: Banco Genérico

| Obligación | Tipo | Rol | Objeto/Regimen |
|-----------|------|-----|----------------|
| Ingresos Brutos - Casa Central | ingresos_brutos | taxpayer | sucursal_001 |
| Ingresos Brutos - Sucursal Norte | ingresos_brutos | taxpayer | sucursal_002 |
| Inmobiliario - Edificio HQ | inmobiliario | taxpayer | property_123 |
| Inmobiliario - Sucursal Centro | inmobiliario | taxpayer | property_456 |
| Automotor - Flota Ejecutiva | automotor | taxpayer | fleet_001 |
| SIRCREB | ingresos_brutos | collection_agent | sircreb |
| General Percepciones | ingresos_brutos | collection_agent | general_percepcion |
| General Retenciones | ingresos_brutos | collection_agent | general_retencion |
| Sellos - Entidad Registradora | sellos | collection_agent | entidad_registradora |
| Sellos - Contratos Propios | sellos | taxpayer | contratos_banco |
| Inmobiliario - Créditos Hipotecarios | inmobiliario | collection_agent | creditos_hipotecarios |
| Automotor - Leasing | automotor | collection_agent | contratos_leasing |

### Modelo de Dominio

```ruby
# Aggregate: Subject (Identity)
class Subject
  attribute :subject_id, Types::UUID
  attribute :tax_id, Types::String  # CUIT/CUIL
  
  # NO contiene obligations (relación 1:N, obligations son aggregates separados)
  # Solo datos de identidad, segmentación y representación
  
  attribute :legal_name, Types::String
  attribute :trade_name, Types::String.optional
  
  # Segmentación
  attribute :legal_segments, Types::Array.of(LegalSegment)
  attribute :administrative_segments, Types::Array.of(AdministrativeSegment)
  
  # Representación (quién me representa)
  attribute :representatives, Types::Array.of(Representative)
  
  # Contacto
  attribute :digital_domicile_id, Types::UUID.optional
  
  attribute :status, Types::SubjectStatus
  attribute :registration_date, Types::Date
end

# Aggregate: TaxObligation (una por cada línea de la tabla anterior)
class TaxObligation
  attribute :obligation_id, Types::UUID
  
  # Referencia al sujeto primario
  attribute :primary_subject_id, Types::UUID
  
  # Cotitularidad (opcional)
  attribute :co_subjects, Types::Array.of(CoSubject)
  
  # Clasificación de la obligación
  attribute :tax_type, Types::String  # "ingresos_brutos", "inmobiliario", etc.
  attribute :role, Types::ObligationRole  # :taxpayer, :collection_agent, :substitute_responsible
  
  # Especificidad según tipo
  attribute :asset_id, Types::UUID.optional           # Para impuestos de bienes (asset-based)
  attribute :object_code, Types::String.optional       # Para objetos lógicos (income-based, ej. sucursal)
  attribute :event_reference, Types::String.optional  # Para hechos puntuales (event-based, ej. sellos)
  attribute :regime_code, Types::String.optional       # Para agentes de recaudación
  
  # Naturaleza (configurable por tax_type)
  attribute :tax_nature, Types::TaxNature  # :income_based, :asset_based, :event_based
  attribute :determination_method, Types::DeterminationMethod  # :self_determined, :pre_determined
  
  # Cuenta corriente (entity interna)
  attribute :account, TaxAccount
  
  # Configuración aplicable
  attribute :configuration_version, Types::Integer
  
  # Estado
  attribute :status, Types::ObligationStatus  # :active, :suspended, :closed
  attribute :opened_at, Types::Date
  attribute :closed_at, Types::DateTime.optional
  
  # Validación: combinación única de (primary_subject_id, tax_type, role, asset_id, regime_code)
end

class CoSubject
  attribute :subject_id, Types::UUID
  attribute :ownership_percentage, Types::Decimal  # 0.0 a 1.0
  attribute :is_primary, Types::Bool  # Solo uno puede ser primary
end
```

### Debt (Entidad interna de TaxObligation)

**Definición**: Ítem de débito con identidad propia para aplicación de pagos, cálculo de intereses y seguimiento de prescripción.

**Características**:
- Tiene `debt_id` (UUID) persistido en eventos
- Es ENTIDAD, no proyección (tiene ciclo de vida e identidad)
- Tipos: :liquidation, :interest, :penalty, :surcharge
- Estado: :pending, :partially_paid, :fully_paid, :prescribed
- Atributos: principal_amount, paid_amount, due_date, debt_status (:prejudicial, :judicial)

**Relación**:
- TaxObligation contiene múltiples Debt (entities)
- TaxAccount calcula balances sumando Debts
- PaymentAppliedToDebt referencia debt_id específico

### Objeto de la Obligación (Taxpayer)

Para obligaciones de contribuyente (:taxpayer), el "objeto" se modela con:

| Tipo de Impuesto | Campo usado | Ejemplo |
|-----------------|-------------|---------|
| Asset-based (inmobiliario, automotor) | `asset_id` | property_123, vehicle_789 |
| Income-based (ingresos brutos) | `object_code` | sucursal_001, casa_central |
| Event-based (sellos) | `event_reference` | contrato_2024_001 |

**Regla**: `asset_id` para bienes físicos registrados; `object_code` para objetos lógicos/operativos; `event_reference` para hechos puntuales.

---

## 2. Cotitularidad (Co-ownership)

### Modelo Solidario (Default)

- Cualquier cotitular puede pagar el 100% de la deuda
- El pago cancela la deuda para todos los cotitulares
- ownership_percentage es informativo (para estadísticas) no distributivo

### Configuración por Tipo de Impuesto

```ruby
TaxType.configure(:inmobiliario) do |tax|
  tax.ownership do
    allow_multiple true
    default_model :solidary  # Cualquiera paga todo
    
    # Alternativas futuras:
    # model :pro_rata        # Cada uno paga su %
    # model :joint           # Todos deben pagar juntos
  end
end
```

### Notificaciones

- Intimaciones y vencimientos: van al domicilio fiscal de cada cotitular
- O al primary_subject si se configura así

### Prescripción

- Interrupción por un cotitular (pago, reconocimiento) interrumpe para todos
- Suspensión afecta a todos

---

## 3. Aplicación de Pagos (Compensación) - CORREGIDO

**Principio fundamental**: El sujeto SIEMPRE elige qué obligación específica pagar.

**Flujo**:
1. Sujeto indica: obligación, período/concepto, monto
2. Sistema aplica pago a esa obligación específica
3. Si hay sobrante: aplican reglas de imputación (estrictas o libres según configuración)
4. Si hay saldo a favor del sujeto: compensación por decisión del fisco o a pedido de parte

### Modelo A: Libre Disponibilidad (Estilo AFIP)

- Sujeto elige obligación y distribución interna
- Sobrante: sujeto elige siguiente obligación
- Saldo a favor: compensación manual o automática según configuración

### Modelo B: Orden Estricto (Estilo ARBA)

- Sujeto elige obligación específica
- Dentro de esa obligación, si hay sobrante: orden estricto (multas → recargos → intereses → capital)
- Si aún sobra: siguiente obligación según orden cronológico de vencimiento
- Saldo a favor: compensación automática u ordenada por fisco

### Ejemplo ARBA corregido

```
Pago: $15,000
Sujeto indica: "Pagar Ingresos Brutos Enero 2024"

Deuda IB Enero 2024:
- Multa: $1,000
- Recargo: $500
- Interés: $2,000
- Capital: $8,000
Total: $11,500

Aplicación:
- Multa: $1,000 (elección sujeto, orden estricto interno)
- Recargo: $500
- Interés: $2,000
- Capital: $7,000 (parcial)
Sobrante: $3,500

Sobrante aplicado por orden estricto a siguiente deuda:
- IB Febrero 2024 Capital: $3,500
```

### Deudas Prescriptas

- Pueden ser pagadas voluntariamente
- Siguen las mismas reglas de aplicación
- El pago NO interrumpe prescripción (ya prescribió)

### Configuración

```ruby
TaxType.configure(:ingresos_brutos) do |tax|
  tax.payment_application do
    strategy :strict_ordering  # o :free_allocation

    ordering do
      priority 1, category: :penalty
      priority 2, category: :surcharge
      priority 3, category: :interest
      priority 4, category: :principal

      within_category :chronological  # oldest first
      cross_obligation :after_full_obligation  # Surplus goes to other obligations
    end

    allow_payment_to_prescribed true
  end
end
```

---

## 4. Agentes de Recaudación

### Flujo Completo

```ini
1. APLICACIÓN DE DEDUCCIÓN
   Agente aplica retención/percepción en transacción
   → Event: DeductionApplied
   
   Si es :full_payment (escribanos, registros, sellos):
   → Inmediatamente: DeductionAppliedToDebt (cancela obligación contribuyente)

2. DECLARACIÓN JURADA
   Agente presenta DDJJ con lote de deducciones del período
   → Event: AgentDeclarationSubmitted
   → Se crea deuda del agente hacia el fisco (AgentDebtCreated)

3. REMISIÓN
   Agente ingresa el dinero recaudado
   → Event: CollectionRemitted
   → Se paga deuda del agente (AgentDebtPaid)
   → Deducciones disponibles para contribuyentes (DeductionAvailableForTaxpayer)
```

### Tipos de Deducción

| Tipo | Descripción | Ejemplo |
|------|-------------|---------|
| :withholding | Retención | SIRCREB en cuenta bancaria |
| :perception | Percepción | Venta de bienes |
| :full_payment | Pago total cancela deuda | Escribano retiene Inmobiliario |

### Tasas de Agentes

| Tipo | Determinación |
|------|---------------|
| Fija | Misma tasa para todo el régimen |
| Por Segmento | Según características del sujeto/operación |
| Por Padrón | Tabla publicada por el fisco por período |

### Modelo de Padrón de Alícuotas

```ruby
class RateRegistry
  attribute :registry_id, Types::UUID
  attribute :regime_code, Types::String
  attribute :period, TaxPeriod
  
  # { subject_id => rate }
  attribute :rates, Types::Hash.of(Types::UUID => Types::Decimal)
  
  attribute :calculation_criteria, Types::Hash
  # Criterios usados: actividades, ingresos declarados, exenciones, etc.
  
  def rate_for(subject_id)
    rates[subject_id] || default_rate
  end
  
  def publish!
    yield RateRegistryPublished.new(...)
    yield RateRegistryAvailableForAgents.new(...)
  end
end
```

---

## 5. Intereses

### Modelo Híbrido (Recomendado)

**Materialización**: Mensual (job automático)
**Cálculo on-the-fly**: Para queries y proyecciones

### Tasas

| Tipo | Descripción | Ejemplo |
|------|-------------|---------|
| Resarcitorio (Prejudicial) | Compensatorio por mora | 4% → 6% |
| Punitorio (Judicial) | Por litigiosidad | 5% → 8% |

### Reglas Temporales

- NO retroactivo: tasa nueva aplica desde fecha de vigencia
- Deuda de Junio 2022 con tasa 4%: sigue con 4% hasta cambio
- Si cambia a 6% en Julio 2024: desde Julio 2024 con 6%

### Transición Prejudicial → Judicial

- Al judicializar: desde fecha de judicialización con tasa punitoria
- Intereses anteriores quedan con tasa resarcitoria

### Configuración

```ruby
TaxType.configure(:ingresos_brutos) do |tax|
  tax.interest do
    prejudicial do
      rate_table "default_prejudicial"
      calculation_method :compound  # o :simple
      materialize :monthly
    end
    
    judicial do
      rate_table "default_judicial"
      calculation_method :compound
      materialize :monthly
    end
    
    # Momentos de materialización adicionales
    also_materialize_on [:payment, :judicialization, :monthly_statement]
  end
end
```

### Evento de Interés

```ruby
class InterestAccrued < Event
  attribute :obligation_id, Types::UUID
  attribute :debt_id, Types::UUID
  attribute :accrual_date, Types::Date
  
  attribute :period_from, Types::Date
  attribute :period_to, Types::Date
  
  attribute :principal_amount, Money
  attribute :interest_amount, Money
  
  attribute :debt_status, Types::DebtStatus  # :prejudicial o :judicial
  
  # Metadata para auditoría
  attribute :calculation_metadata, Types::Hash
  # rate_table_code, rate_periods_applied, calculation_method, months
end
```

---

## 6. Prescripción

### Concepto

- Extinción de la **acción de cobro**, no de la deuda
- La deuda existe en la cuenta corriente pero no es exigible judicialmente
- El contribuyente puede pagarla voluntariamente

### Período

- Configurable por tipo de impuesto (típico: 5 años)
- Desde due_date (o configurable)

### Interrupciones (Reinician el plazo)

- Intimación formal del fisco
- Reconocimiento de deuda
- Pago parcial
- Inicio de acción judicial

### Suspensiones (Pausan el plazo)

- Plan de pagos vigente
- Recurso administrativo en trámite
- Fiscalización en curso

### Comportamiento al Prescribir

- Status de deuda: :prescribed
- NO se borra la deuda
- NO acumula más intereses
- SÍ puede ser pagada voluntariamente

---

## 7. Configuración de Impuestos

### Estrategia de Evolución

**Fase 1 (MVP)**: Fluent API en Ruby
**Fase 2**: YAML/JSON declarativo
**Fase 3**: Visual composer

### Ejemplo: ARBA Ingresos Brutos

```ruby
TaxType.configure(:ingresos_brutos) do |tax|
  # Básico
  tax.nature :income_based
  tax.determination :self_determined
  tax.ownership :single
  
  # Períodos
  tax.periods do
    monthly do
      declaration_due_date day: 15, of: :next_month
      payment_due_date day: 20, of: :next_month
    end
    annual_consolidation do
      declaration_due_date month: 3, day: 31, of: :next_year
    end
  end
  
  # Tasas
  tax.rates do
    default 0.035
    for_segment :small_business, rate: 0.01
    for_activity :financial_services, rate: 0.055
  end
  
  # Intereses
  tax.interest do
    prejudicial do
      rate_table "arba_prejudicial"
      calculation_method :compound
      materialize :monthly
    end
    judicial do
      rate_table "arba_judicial"
      calculation_method :compound
      materialize :monthly
    end
  end
  
  # Prescripción
  tax.prescription do
    period_years 5
    start_from :due_date
    interruptions [:formal_notice, :partial_payment, :judicial_action]
    suspensions [:payment_plan, :administrative_appeal]
  end
  
  # Aplicación de pagos
  tax.payment_application do
    strategy :strict_ordering
    ordering do
      priority 1, category: :penalty
      priority 2, category: :surcharge
      priority 3, category: :interest
      priority 4, category: :principal
      within_category :chronological
    end
    allow_payment_to_prescribed true
  end
  
  # Agentes de recaudación
  tax.collection_agents do
    enable_regime :general_withholding do
      rate_determination :by_registry
      declaration_due_date day: 10, of: :next_month
      remittance_due_date day: 10, of: :next_month
    end
    
    enable_regime :general_perception do
      rate_determination :by_segment
      declaration_due_date day: 15, of: :next_month
    end
    
    enable_regime :sircreb do
      rate_determination :by_registry
      automatic_deduction true
      declaration_due_date day: 5, of: :next_month
    end
  end
end
```

---

## 8. Catálogo de Eventos

### Sujeto (Subject)

- SubjectRegistered
- RepresentativeAuthorized
- RepresentativeRevoked
- SubjectSegmentChanged

### Obligación Tributaria (TaxObligation)

- TaxObligationCreated
- TaxObligationClosed
- CoOwnerAdded
- CoOwnerRemoved
- TaxLiquidationCreated
- TaxLiquidationCorrected
- TaxLiquidationCancelled

### Pagos (Payment)

- PaymentReceived
- PaymentAppliedToDebt
- AdvancePaymentCreated

### Intereses (Interest)

- InterestAccrued
- InterestMaterialized
- DebtStatusChanged  # prejudicial → judicial

### Prescripción (Prescription)

- PrescriptionInterrupted
- PrescriptionSuspended
- PrescriptionResumed
- DebtPrescribed

### Agentes de Recaudación (Collection Agents)

- DeductionApplied
- DeductionAppliedToDebt
- AgentDeclarationSubmitted
- AgentDeclarationRemitted
- CollectionRemitted
- AgentDebtCreated
- AgentDebtPaid
- DeductionAvailableForTaxpayer
- RateRegistryPublished

### Declaraciones (Declarations)

- TaxpayerDeclarationSubmitted
- TaxpayerDeclarationValidated
- TaxpayerDeclarationRejected
- TaxpayerDeclarationRectified

### Cobranzas (Collections)

- CollectionCaseOpened
- PaymentDemandIssued
- DebtJudicialized
- CollectionCaseClosed

---

## 9. Invariantes del Dominio

### TaxObligation

- Total de ownership_percentage debe sumar 1.0 (si hay cotitulares)
- Un solo cotitular puede ser primary
- Deudas prescritas no acumulan intereses
- Deudas prescritas no pueden ser judicializadas

### Aplicación de Pagos

- Total de asignaciones debe igualar monto del pago
- Asignación a deuda inexistente es inválida
- Orden estricto debe respetar configuración

### Agentes de Recaudación

- Agente solo puede declarar sus propias deducciones
- Monto de remisión debe igualar monto declarado
- Deducción no puede aplicarse dos veces al mismo contribuyente

### Prescripción

- Interrupción no puede ocurrir después de prescripción
- Suspensión no puede iniciar después de prescripción
- Deadline debe ser >= start_date + period_years

---

## 10. Principios de Diseño API

### API-First

- Todas las operaciones expuestas vía REST API
- Web UI es implementación de referencia
- Integraciones externas usan mismas APIs
- Webhooks para notificaciones

### Endpoints Principales

```sh
POST   /api/v1/declarations
GET    /api/v1/obligations/:id
# Contribuyentes
POST   /api/v1/payments
GET    /api/v1/payments/:id/receipt
GET    /api/v1/deductions/available

# Agentes de Recaudación
POST   /api/v1/agents/deductions
POST   /api/v1/agents/declarations
POST   /api/v1/agents/remittances
GET    /api/v1/agents/rate-registry/:period

# Autoridad Tributaria
POST   /api/v1/liquidations
POST   /api/v1/rate-registries
GET    /api/v1/prescription-alerts
POST   /api/v1/collection-actions
```

---

## 11. Anexo: Tipos y Enums (MVP)

```ruby
# SubjectStatus
:active, :suspended, :inactive

# SubjectType
:natural_person, :legal_person

# ObligationRole
:taxpayer, :collection_agent, :substitute_responsible

# ObligationStatus
:active, :suspended, :closed

# TaxNature
:income_based, :asset_based, :event_based

# DeterminationMethod
:self_determined, :pre_determined

# DebtCategory
:principal, :interest, :penalty, :surcharge

# DebtStatus
:prejudicial, :judicial, :prescribed

# PaymentApplicationStrategy
:free_allocation, :strict_ordering

# CollectionAgentRegime
:general_withholding, :general_perception, :sircreb, :notary_withholding, :registry_withholding

# PrescriptionInterruptionType
:formal_notice, :debt_recognition, :partial_payment, :judicial_action

# PrescriptionSuspensionType
:payment_plan, :administrative_appeal, :audit_in_progress
```

---

Esta especificación es el dominio completo de Fisco.io MVP.
Todas las reglas son configurables por tipo de impuesto.
Implementación usa Event Sourcing + CQRS + DDD patterns.
