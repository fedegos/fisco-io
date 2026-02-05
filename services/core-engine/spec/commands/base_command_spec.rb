# frozen_string_literal: true

# Fisco.io - BaseCommand specs

require "spec_helper"
require "securerandom"
require_relative "../../app/commands/base_command"

RSpec.describe BaseCommand do
  describe ".new" do
    it "genera command_id si no se provee" do
      cmd = BaseCommand.new(aggregate_id: "agg-1")
      expect(cmd.command_id).to be_a(String)
      expect(cmd.command_id.length).to eq(36)
    end

    it "es válido por defecto" do
      cmd = BaseCommand.new
      expect(cmd.valid?).to be true
      expect(cmd.errors).to eq([])
    end
  end
end
