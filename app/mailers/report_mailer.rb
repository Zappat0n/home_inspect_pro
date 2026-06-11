# frozen_string_literal: true

class ReportMailer < ApplicationMailer
  def send_report(inspection)
    user = inspection.user

    if inspection.pdf.attached?
      attachments["inspection_report_#{inspection.id}.pdf"] = inspection.pdf.download
    end

    mail(
      to: [inspection.client_email, user.email],
      subject: t(".subject", property_address: inspection.property_address),
    ) do |format|
      format.html { render(locals: { inspection: inspection, user: user }) }
      format.text { render(locals: { inspection: inspection, user: user }) }
    end
  end
end
