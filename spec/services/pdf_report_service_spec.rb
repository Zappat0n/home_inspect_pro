# frozen_string_literal: true

require "rails_helper"

RSpec.describe PdfReportService do
  describe "#call" do
    it "groups items by their checklist category" do
      country = create(:country)
      user = create(:user, country: country)
      template = create(:inspection_template, country: country, published: true)
      roof_item = create(
        :checklist_item,
        inspection_template: template,
        category: "Roof",
        position: 1,
      )
      electrical_item = create(
        :checklist_item,
        inspection_template: template,
        category: "Electrical",
        position: 2,
      )
      inspection = create(:inspection, user: user, inspection_template: template)
      create(:inspection_item, inspection: inspection, checklist_item: roof_item, status: :ok)
      create(
        :inspection_item,
        inspection: inspection,
        checklist_item: electrical_item,
        status: :defect,
      )

      result = described_class.new(inspection).send(:items_grouped)

      expect(result.keys).to match_array(%w[Roof Electrical])
    end

    it "includes only defect items in the defects list" do
      country = create(:country)
      user = create(:user, country: country)
      template = create(:inspection_template, country: country, published: true)
      ok_item = create(
        :checklist_item,
        inspection_template: template,
        name: "OK Item",
        position: 1,
      )
      defect_item = create(
        :checklist_item,
        inspection_template: template,
        name: "Defect Item",
        position: 2,
      )
      na_item = create(
        :checklist_item,
        inspection_template: template,
        name: "NA Item",
        position: 3,
      )
      inspection = create(:inspection, user: user, inspection_template: template)
      create(:inspection_item, inspection: inspection, checklist_item: ok_item, status: :ok)
      create(
        :inspection_item,
        inspection: inspection,
        checklist_item: defect_item,
        status: :defect,
      )
      create(:inspection_item, inspection: inspection, checklist_item: na_item, status: :na)

      result = described_class.new(inspection).send(:defects)

      expect(result.size).to eq(1)
      expect(result.first.status).to eq("defect")
      expect(result.first.checklist_item.name).to eq("Defect Item")
    end

    it "returns the country locale" do
      country = create(:country, locale: "es")
      template = create(:inspection_template, country: country, published: true)
      inspection = create(:inspection, inspection_template: template)

      result = described_class.new(inspection).send(:locale)

      expect(result).to eq("es")
    end

    it "finds report template matching country locale" do
      country = create(:country, locale: "es")
      template = create(:inspection_template, country: country, published: true)
      inspection = create(:inspection, inspection_template: template)
      report_template = create(:report_template, country: country, locale: "es")

      result = described_class.new(inspection).send(:report_template)

      expect(result).to eq(report_template)
    end

    it "falls back to first report template when locale-specific not found" do
      country = create(:country, locale: "fr")
      template = create(:inspection_template, country: country, published: true)
      inspection = create(:inspection, inspection_template: template)
      report_template = create(:report_template, country: country, locale: "en")

      result = described_class.new(inspection).send(:report_template)

      expect(result).to eq(report_template)
    end
  end
end
