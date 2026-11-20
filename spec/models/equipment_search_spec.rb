require "rails_helper"

RSpec.describe Equipment, type: :model do
  let!(:oscilloscope) { described_class.create!(name: "Oscilloscope", asset_identifier: "LAB-015", location: "Lab A", status: "Available") }
  let!(:printer) { described_class.create!(name: "Printer", asset_identifier: "OFFICE-002", location: "Office", status: "Available") }

  it "matches a partial name without regard to capitalization or surrounding spaces" do
    expect(described_class.search("  OSCIL  ")).to contain_exactly(oscilloscope)
  end

  it "matches part of an asset identifier without regard to capitalization" do
    expect(described_class.search("lab-01")).to contain_exactly(oscilloscope)
  end

  it "returns a record once when both fields match" do
    oscilloscope.update!(name: "LAB-015 instrument")
    expect(described_class.search("lab-015")).to contain_exactly(oscilloscope)
  end

  [ nil, "", "   " ].each do |query|
    it "returns the current relation for a blank query #{query.inspect}" do
      expect(described_class.where(id: printer.id).search(query)).to contain_exactly(printer)
    end
  end

  it "keeps matches inside the current relation" do
    expect(described_class.where(id: printer.id).search("lab")).to be_empty
  end

  it "returns no results for an unknown term" do
    expect(described_class.search("nonexistent")).to be_empty
  end

  [ "%", "_", "\\" ].each_with_index do |character, index|
    it "treats #{character.inspect} literally rather than as a search wildcard" do
      literal = described_class.create!(name: "Instrument #{character} special", asset_identifier: "SPECIAL-#{index}", location: "Lab", status: "Available")
      expect(described_class.search(character)).to contain_exactly(literal)
    end
  end

  it "treats SQL-like input as plain search text" do
    expect(described_class.search("' OR 1=1 --")).to be_empty
  end
end
