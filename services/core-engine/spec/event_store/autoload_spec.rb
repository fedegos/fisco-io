# frozen_string_literal: true

# Fisco.io - Verifica que EventStore::Repository se carga correctamente con Zeitwerk
# Este spec reproduce el NameError que ocurre cuando hay problemas de autoload/reload.

require "rails_helper"

RSpec.describe "EventStore autoload", type: :request do
  it "EventStore::Repository se puede instanciar sin depender del initializer" do
    # Verificar que la constante existe y se puede instanciar
    expect { EventStore::Repository.new }.not_to raise_error
  end

  it "EventStore::Repository está definido como constante" do
    expect(defined?(EventStore::Repository)).to eq("constant")
  end

  it "EventStore módulo existe" do
    expect(defined?(EventStore)).to eq("constant")
  end

  # Este spec verifica que Zeitwerk puede cargar EventStore::Repository via autoload.
  # Si la constante se descarga (como en un reload), Zeitwerk debe poder recargarla.
  it "EventStore::Repository puede ser recargado por Zeitwerk" do
    # Forzar que la constante se cargue primero
    _ = EventStore::Repository

    # Verificar que está definida
    expect(defined?(EventStore::Repository)).to eq("constant")

    # Simular descarga del módulo y forzar recarga via Zeitwerk
    # Nota: En test mode, Zeitwerk no permite reload, así que solo verificamos que
    # la constante se puede usar múltiples veces sin problemas
    repo1 = EventStore::Repository.new
    repo2 = EventStore::Repository.new
    expect(repo1).to be_a(EventStore::Repository)
    expect(repo2).to be_a(EventStore::Repository)
  end

  describe "desde el controlador" do
    let(:subject_id) { SecureRandom.uuid }

    before do
      SubjectReadModel.create!(
        subject_id: subject_id,
        legal_name: "Test SA",
        tax_id: "20-11111111-1",
        registration_date: Date.current,
        status: "active"
      )
    end

    it "snapshot_at puede usar EventStore::Repository" do
      # Este es el endpoint que falla con NameError
      get operadores_snapshot_at_padron_sujeto_path(subject_id),
          params: { up_to_version: 1 },
          headers: { "Turbo-Frame" => "snapshot_modal" }

      expect(response).to have_http_status(:ok)
    end
  end
end
