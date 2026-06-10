# frozen_string_literal: true

class GeneratePdfReportJob < ApplicationJob
  queue_as :default

  retry_on ActiveRecord::RecordNotFound

  def perform(inspection_id, base_url)
    Inspection.find(inspection_id).then do |inspection|
      Rails.logger.info("Generating PDF report for inspection #{inspection_id}")
      PdfReportService.new(inspection, base_url: base_url).call
      Rails.logger.info("PDF report generated for inspection #{inspection_id}")
    end
  end
end
