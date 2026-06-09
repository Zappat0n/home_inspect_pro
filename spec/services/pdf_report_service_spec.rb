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
  end
end
