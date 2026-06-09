require "rails_helper"

RSpec.describe ReportTemplate, type: :model do
  describe "validations" do
    it "validates locale presence" do
      report_template = build_stubbed(:report_template, locale: nil)

      expect(report_template).not_to be_valid
      expect(report_template.errors[:locale]).to be_present
    end

    it "validates locale uniqueness within country scope" do
      country = create(:country)
      create(:report_template, country: country, locale: "en")
      duplicate = build(:report_template, country: country, locale: "en")

      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:locale]).to be_present
    end

    it "allows same locale across different countries" do
      usa = create(:country, code: "US")
      spain = create(:country, code: "ES")
      create(:report_template, country: usa, locale: "en")
      other = build(:report_template, country: spain, locale: "en")

      expect(other).to be_valid
    end
  end

  describe "associations" do
    it "belongs to country" do
      country = create(:country)
      report_template = create(:report_template, country: country)

      expect(report_template.country).to eq(country)
    end
  end
end
