# frozen_string_literal: true

# Fisco.io - BaseAggregate specs

require "spec_helper"
require_relative "../../app/aggregates/base_aggregate"
require_relative "../../app/events/base_event"

RSpec.describe BaseAggregate do
  describe "#apply" do
    it "incrementa version cuando el evento tiene event_version" do
      agg = BaseAggregate.new(id: "agg-1", version: 0)
      event = BaseEvent.new(aggregate_id: "agg-1", event_type: "FakeEvent", event_version: 1)
      agg.apply(event)
      expect(agg.version).to eq(1)
    end
  end
end
