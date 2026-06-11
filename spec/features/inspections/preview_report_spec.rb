# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Report preview", :js, type: :feature do
  it "displays PDF preview for completed inspection" do
    country = create(:country, code: "US", locale: "en")
    user = create(:user, country: country)
    inspection_template = create(
      :inspection_template,
      country: country,
      published: true,
    )
    inspection = create(
      :inspection,
      user: user,
      inspection_template: inspection_template,
      status: :completed,
      pdf_url: "http://example.com/report.pdf",
    )

    sign_in user

    preview_page = Inspections::PreviewReportPage.new(inspection)
    preview_page.visit_page

    expect(preview_page).to have_preview_heading
    expect(preview_page).to have_pdf_preview
  end

  it "previews report, goes back, returns to preview, and sends report" do
    country = create(:country, code: "US", locale: "en")
    user = create(:user, country: country)
    inspection_template = create(
      :inspection_template,
      country: country,
      published: true,
    )
    inspection = create(
      :inspection,
      user: user,
      inspection_template: inspection_template,
      status: :completed,
      pdf_url: "http://example.com/report.pdf",
    )

    allow(ReportMailer).to receive_message_chain(:send_report, :deliver_later)

    sign_in user

    preview_page = Inspections::PreviewReportPage.new(inspection)

    preview_page.visit_page
    expect(preview_page).to have_preview_heading
    expect(preview_page).to have_pdf_preview

    preview_page.back_to_inspection

    show_page = Inspections::ShowPage.new(inspection)
    expect(show_page).to have_heading

    find("[data-testid='preview-report-button']").click

    expect(preview_page).to have_preview_heading
    expect(preview_page).to have_pdf_preview

    preview_page.send_report

    expect(preview_page).to have_success_notice
    expect(ReportMailer).to have_received(:send_report)
  end
end
