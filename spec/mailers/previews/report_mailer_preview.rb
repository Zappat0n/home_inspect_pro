# frozen_string_literal: true

class ReportMailerPreview < ActionMailer::Preview
  def send_report
    user = User.new(email: "inspector@example.com")

    inspection = Inspection.new(
      client_name: "Jane Doe",
      client_email: "client@example.com",
      property_address: "123 Main St, Anytown, USA",
      id: 1,
    )

    inspection.define_singleton_method(:user) { user }

    inspection.define_singleton_method(:pdf) do
      OpenStruct.new(attached?: false)
    end

    ReportMailer.send_report(inspection)
  end
end
