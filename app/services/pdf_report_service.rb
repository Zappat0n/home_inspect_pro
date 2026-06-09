# frozen_string_literal: true

class PdfReportService
  def initialize(inspection)
    @inspection = inspection
  end

  def call
    pdf = Grover.new(html, format: "A4").to_pdf

    inspection.pdf.attach(
      io: StringIO.new(pdf),
      filename: "inspection_report_#{inspection.id}.pdf",
      content_type: "application/pdf",
    )

    inspection.update!(pdf_url: inspection.pdf.url)
  end

  private

  attr_reader :inspection

  def html
    ApplicationController.render(
      template: "reports/show",
      layout: "layouts/report_pdf",
      locals: {
        inspection: inspection,
        items_grouped: items_grouped,
        defects: defects,
      },
    )
  end

  def items_grouped
    inspection.inspection_items
      .includes(:checklist_item)
      .order("checklist_items.position")
      .group_by { |item| item.checklist_item.category }
  end

  def defects
    inspection.inspection_items.with_defects.includes(:checklist_item)
  end
end
