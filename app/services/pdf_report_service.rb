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
        defects_grouped: defects_grouped,
        defect_counts: defect_counts,
        categories: categories,
        report_url: report_url,
        generated_at: generated_at,
      },
    )
  end

  def base_url
    @_base_url ||= begin
      opts = Rails.application.routes.default_url_options
      opts = Rails.application.config.action_mailer.default_url_options if opts.blank?

      host = opts[:host] || "localhost"
      port = opts[:port]
      protocol = (opts[:protocol] || opts[:scheme] || "http").to_s

      URI::HTTP.build(host: host, port: port, scheme: protocol).to_s
    end
  end

  def report_template
    @_report_template ||= inspection.inspection_template.country.report_templates.find_by(locale: locale)
  end

  def items_grouped
    inspection
      .inspection_items
      .includes(:checklist_item)
      .order("inspection_template_items.position")
      .group_by { |item| item.checklist_item.inspection_template_category.name }
  end

  def defects
    inspection
      .inspection_items
      .with_defects
      .includes(:checklist_item)
  end

  def defects_grouped
    @_defects_grouped ||= begin
      severity_order = %w[critical major minor info]
      severity_order.filter_map do |severity|
        items = defects.select { |d| d.checklist_item.severity == severity }
        next if items.empty?

        {
          severity: severity,
          translation_key: "reports.show.severities.#{severity}",
          items: items,
        }
      end
    end
  end

  def defect_counts
    @_defect_counts ||= begin
      counts = defects.group_by { |d| d.checklist_item.severity }.transform_values(&:count)
      {
        total: defects.size,
        critical: counts.fetch("critical", 0),
        major: counts.fetch("major", 0),
        minor: counts.fetch("minor", 0),
        info: counts.fetch("info", 0),
      }
    end
  end

  def categories
    @_categories ||= items_grouped.map do |name, items|
      { name: name, has_defects: items.any?(&:defect?) }
    end
  end

  def report_url
    @_report_url ||= "#{base_url}#{Rails.application.routes.url_helpers.report_inspection_path(inspection)}"
  end

  def generated_at
    @_generated_at ||= Time.current
  end
end
