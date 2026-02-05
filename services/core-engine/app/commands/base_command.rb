# frozen_string_literal: true

# Fisco.io - Base Command
# Clase base para comandos / Base class for commands
#
# Comandos son imperativos; validación básica (scaffolding).
# Commands are imperative; basic validation (scaffolding).

class BaseCommand
  attr_reader :aggregate_id, :command_id, :metadata

  def initialize(aggregate_id: nil, command_id: nil, metadata: {})
    @aggregate_id = aggregate_id
    @command_id = command_id || SecureRandom.uuid
    @metadata = metadata.freeze
  end

  # Validación básica; subclases sobrescriben
  # Basic validation; subclasses override
  def valid?
    true
  end

  def errors
    []
  end
end
