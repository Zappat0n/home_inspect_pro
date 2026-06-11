# frozen_string_literal: true

require "rails_helper"

RSpec.describe ReportMailer, type: :mailer do
  describe "#send_report" do
    it "sends report to client and inspector with correct content" do
      country = build_stubbed(:country)
      user = build_stubbed(:user, country: country)
      template = build_stubbed(:inspection_template, country: country, published: true)
      inspection = build_stubbed(:inspection, user: user, inspection_template: template)

      mail = described_class.send_report(inspection)

      expect(mail.to).to contain_exactly(inspection.client_email, user.email)
      expect(mail.subject).to include(inspection.property_address)
      expect(mail.from).to contain_exactly("notifications@homeinspectpro.com")
      expect(mail.body.encoded).to include(inspection.client_name)
      expect(mail.body.encoded).to include(inspection.property_address)
      expect(mail.body.encoded).to include(user.email)
      expect(mail.attachments).to be_empty
    end

    it "attaches PDF when inspection has a PDF" do
      country = create(:country)
      user = create(:user, country: country)
      template = create(:inspection_template, country: country, published: true)
      inspection = create(:inspection, user: user, inspection_template: template)
      inspection.pdf.attach(
        io: StringIO.new("fake pdf content"),
        filename: "test_report.pdf",
        content_type: "application/pdf",
      )

      mail = described_class.send_report(inspection)

      expect(mail.attachments.map(&:filename)).to include("inspection_report_#{inspection.id}.pdf")
      expect(mail.attachments.first.content_type).to include("application/pdf")
    end
  end
end
