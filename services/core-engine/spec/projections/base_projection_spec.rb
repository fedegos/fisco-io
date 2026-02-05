# frozen_string_literal: true

# Fisco.io - BaseProjection specs

require "spec_helper"
require_relative "../../app/projections/base_projection"
require_relative "../../app/events/base_event"

RSpec.describe BaseProjection do
  describe "#handle" do
    it "no falla cuando no hay handler para el event_type" do
      proj = BaseProjection.new
      event = BaseEvent.new(aggregate_id: "agg-1", event_type: "UnknownEvent")
      expect { proj.handle(event) }.not_to raise_error
    end
  end
end
