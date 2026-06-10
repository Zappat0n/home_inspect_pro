# frozen_string_literal: true

require "rails_helper"

RSpec.describe GeneratePdfReportJob do
  describe "#perform" do
    it "generates a PDF report for the given inspection" do
      inspection = create(:inspection)
      base_url = "http://example.com"
      service_double = instance_double(PdfReportService)
      allow(PdfReportService).to receive(:new)
        .with(inspection, base_url: base_url)
        .and_return(service_double)
      allow(service_double).to receive(:call)

      described_class.perform_now(inspection.id, base_url)

      expect(PdfReportService).to have_received(:new)
        .with(inspection, base_url: base_url)
      expect(service_double).to have_received(:call)
    end

    it "raises RecordNotFound when the inspection does not exist" do
      nonexistent_id = 999_999_999

      expect do
        described_class.new.perform(nonexistent_id, "http://example.com")
      end.to raise_error(ActiveRecord::RecordNotFound)
    end
  end
end
