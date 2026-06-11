# frozen_string_literal: true

class Inspections::PreviewReportPage
  include Capybara::DSL
  include Rails.application.routes.url_helpers

  def initialize(inspection)
    @inspection = inspection
  end

  def visit_page
    visit preview_report_inspection_path(@inspection)
  end

  def has_pdf_preview?
    has_css?("[data-testid='pdf-preview-frame']")
  end

  def has_preview_heading?
    has_content?(I18n.t("inspections.preview_report.title"))
  end

  def back_to_inspection
    find("[data-testid='back-to-inspection-button']").click
  end

  def send_report
    find("[data-testid='send-report-button']").click
  end

  def has_success_notice?
    has_content?(I18n.t("inspections.send_report.success"))
  end
end
