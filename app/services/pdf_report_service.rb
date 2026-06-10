# frozen_string_literal: true

class PdfReportService
  def initialize(inspection, base_url: nil)
    @inspection = inspection
    @_base_url = base_url
    @locale = inspection.locale
  end

  def call
    previous_url_options = ActiveStorage::Current.url_options
    ActiveStorage::Current.url_options = { host: base_url }

    I18n.with_locale(locale) do
      pdf = Grover.new(html, format: "A4").to_pdf

      inspection.pdf.attach(
        io: StringIO.new(pdf),
        filename: "inspection_report_#{inspection.id}.pdf",
        content_type: "application/pdf",
      )

      inspection.update!(pdf_url: inspection.pdf.url)
    end
  ensure
    ActiveStorage::Current.url_options = previous_url_options
  end

  private

  attr_reader :inspection, :locale

  def html
    ApplicationController.render(
      template: "reports/show",
      layout: "layouts/report_pdf",
      formats: [:html],
      locals: {
        inspection: inspection,
        items_grouped: items_grouped,
        defects: defects,
      },
    )
  end

  def base_url
    @_base_url ||= begin
      opts = Rails.application.routes.default_url_options
      opts = Rails.application.config.action_mailer.default_url_options if opts.blank?
      host = opts[:host] || "localhost"
      port = opts[:port]
      port ? "http://#{host}:#{port}" : "http://#{host}"
    end
  end

  def report_template
    @_report_template ||= inspection.inspection_template.country.report_templates.find_by(locale: locale)
  end

  def items_grouped
    inspection
      .inspection_items
      .includes(:checklist_item)
      .order("checklist_items.position")
      .group_by { |item| item.checklist_item.category }
  end

  def defects
    inspection
      .inspection_items
      .with_defects
      .includes(:checklist_item)
  end
end
