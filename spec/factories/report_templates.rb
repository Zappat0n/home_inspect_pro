FactoryBot.define do
  factory :report_template do
    association :country
    locale { "en" }
    header_text { "Home Inspection Report" }
    footer_text { "Generated electronically" }
    legal_disclaimer { "Standard inspection disclaimer text." }
  end
end
