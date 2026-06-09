# frozen_string_literal: true

require "rails_helper"

RSpec.describe PdfReportService do
  describe "#call" do
    it "generates a PDF and attaches it to the inspection" do
      country = create(:country, locale: "en")
      create(:report_template, country: country, locale: "en")
      template = create(:inspection_template, country: country, published: true)
      inspection = create(:inspection, inspection_template: template)
      roof_item = create(
        :checklist_item,
        inspection_template: template,
        category: "Roof",
        name: "Shingles",
        position: 1,
      )
      electrical_item = create(
        :checklist_item,
        inspection_template: template,
        category: "Electrical",
        name: "Outlet",
        position: 2,
      )
      create(
        :inspection_item,
        inspection: inspection,
        checklist_item: roof_item,
        status: :defect,
        comment: "Missing shingles on east side",
      )
      create(:inspection_item, inspection: inspection, checklist_item: electrical_item, status: :ok)

      ActiveStorage::Current.url_options = { host: "http://localhost:3000" }
      grover_double = instance_double(Grover, to_pdf: "fake pdf content")
      rendered_html = nil
      allow(Grover).to receive(:new) do |html|
        rendered_html = html
        grover_double
      end

      described_class.new(inspection).call

      expect(inspection.pdf).to be_attached
      expect(inspection.pdf_url).to be_present
      expect(rendered_html).to include("Roof")
      expect(rendered_html).to include("Electrical")
      expect(rendered_html).to include("Shingles")

      defects_section = rendered_html.split("Defects Summary").last
      expect(defects_section).to include("Missing shingles on east side")
    end

    it "generates a PDF with Spanish locale" do
      country = create(:country, locale: "es")
      create(:report_template, country: country, locale: "es")
      template = create(:inspection_template, country: country, published: true)
      inspection = create(:inspection, inspection_template: template)

      ActiveStorage::Current.url_options = { host: "http://localhost:3000" }
      grover_double = instance_double(Grover, to_pdf: "fake pdf content")
      allow(Grover).to receive(:new).and_return(grover_double)

      described_class.new(inspection).call

      expect(inspection.pdf).to be_attached
    end
  end
end
