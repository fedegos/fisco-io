# frozen_string_literal: true

# Fisco.io - BaseEvent specs

require "spec_helper"
require_relative "../../app/events/base_event"

RSpec.describe BaseEvent do
  describe ".new" do
    it "asigna aggregate_id y event_type" do
      event = BaseEvent.new(aggregate_id: "agg-1", event_type: "TestOccurred")
      expect(event.aggregate_id).to eq("agg-1")
      expect(event.event_type).to eq("TestOccurred")
    end

    it "tiene event_version por defecto 1" do
      event = BaseEvent.new(aggregate_id: "agg-1", event_type: "TestOccurred")
      expect(event.event_version).to eq(1)
    end
  end

  describe "#to_store" do
    it "serializa atributos para persistencia" do
      event = BaseEvent.new(aggregate_id: "agg-1", event_type: "TestOccurred", data: { foo: "bar" })
      stored = event.to_store
      expect(stored[:aggregate_id]).to eq("agg-1")
      expect(stored[:event_type]).to eq("TestOccurred")
      expect(stored[:data]).to eq({ foo: "bar" })
    end
  end
end
