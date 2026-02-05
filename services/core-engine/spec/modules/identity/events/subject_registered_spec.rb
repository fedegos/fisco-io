# frozen_string_literal: true

# Fisco.io - Identity::Events::SubjectRegistered specs

require "spec_helper"
require "app/events/base_event"
require "app/modules/identity/events/subject_registered"

RSpec.describe Identity::Events::SubjectRegistered do
  it "tiene event_type SubjectRegistered" do
    event = described_class.new(aggregate_id: "agg-1", data: { "legal_name" => "ACME" })
    expect(event.event_type).to eq("SubjectRegistered")
  end
end
