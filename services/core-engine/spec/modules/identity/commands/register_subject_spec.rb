# frozen_string_literal: true

# Fisco.io - Identity::Commands::RegisterSubject specs

require "spec_helper"
require "app/commands/base_command"
require "app/modules/identity/commands/register_subject"

RSpec.describe Identity::Commands::RegisterSubject do
  it "requiere tax_id y legal_name" do
    cmd = described_class.new(aggregate_id: "agg-1", tax_id: "20-12345678-9", legal_name: "ACME")
    expect(cmd.tax_id).to eq("20-12345678-9")
    expect(cmd.legal_name).to eq("ACME")
  end
end
