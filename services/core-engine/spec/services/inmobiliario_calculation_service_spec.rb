# frozen_string_literal: true

require "rails_helper"

Bracket = Struct.new(:base_from, :base_to, :rate_pct, :minimum_amount, keyword_init: true)

RSpec.describe InmobiliarioCalculationService do
  describe ".apply_brackets" do
    let(:brackets) do
      [
        Bracket.new(base_from: 0, base_to: 100_000, rate_pct: 0.5, minimum_amount: 500),
        Bracket.new(base_from: 100_001, base_to: 500_000, rate_pct: 0.8, minimum_amount: 1_200)
      ]
    end

    it "returns 0 for nil or zero base" do
      expect(described_class.apply_brackets(nil, brackets)).to eq(0)
      expect(described_class.apply_brackets(0, brackets)).to eq(0)
    end

    it "applies first bracket and minimum for base within first range" do
      # 50_000 * 0.005 = 250, min 500 => 500
      expect(described_class.apply_brackets(50_000, brackets)).to eq(500)
    end

    it "applies both brackets for base spanning two ranges" do
      # 0-100k: 500 (min); 100k-150k: 50_000*0.008=400, min 1200 => 1200. Total 1700
      expect(described_class.apply_brackets(150_000, brackets)).to eq(1700)
    end
  end
end
