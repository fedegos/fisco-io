# frozen_string_literal: true

# Fisco.io - Event Store Migration
# Migración del Event Store / Event Store schema
#
# Crea las tablas events y snapshots para Event Sourcing.
# See .cursorrules "Event Sourcing Implementation Guide".

class CreateEventStore < ActiveRecord::Migration[8.0]
  def change
    # Tabla de eventos inmutables (append-only)
    # Immutable events table (source of truth)
    create_table :events, id: :uuid do |t|
      t.uuid :aggregate_id, null: false
      t.string :aggregate_type, limit: 100, null: false
      t.string :event_type, limit: 100, null: false
      t.integer :event_version, null: false, default: 1
      t.jsonb :data, null: false
      t.jsonb :metadata, null: false, default: {}
      t.timestamps
      # sequence_number: orden global de eventos (asignado por app o secuencia DB)
      t.bigint :sequence_number, null: false
    end

    # Un evento por versión de agregado (aggregate_id + event_version únicos)
    # One event per aggregate version
    add_index :events, %i[aggregate_id event_version], unique: true, name: "unique_aggregate_version"
    add_index :events, :event_type, name: "idx_events_type"
    add_index :events, :created_at, name: "idx_events_created_at"
    add_index :events, :sequence_number, name: "idx_events_sequence"

    # Tabla de snapshots para reconstrucción rápida de agregados con muchos eventos
    # Snapshots for fast aggregate rebuild when event count is high
    create_table :snapshots, id: false do |t|
      t.uuid :aggregate_id, primary_key: true
      t.string :aggregate_type, limit: 100, null: false
      t.jsonb :data, null: false
      t.integer :version, null: false
      t.timestamps
    end

    add_index :snapshots, :aggregate_type, name: "idx_snapshots_type"
  end
end
