# frozen_string_literal: true

class GeneratePdfReportJob < ApplicationJob
  queue_as :default

  retry_on ActiveRecord::RecordNotFound

  def perform(inspection_id, base_url)
    Inspection.find(inspection_id).then do |inspection|
      unless inspection.user.subscribed? || inspection.user.on_trial?
        Rails.logger.warn("Skipping PDF generation for inspection #{inspection_id}: user not subscribed or on trial")
        return nil
      end

      Rails.logger.info("Generating PDF report for inspection #{inspection_id}")
      PdfReportService.new(inspection, base_url: base_url).call
      Rails.logger.info("PDF report generated for inspection #{inspection_id}")
    end
  end
end
