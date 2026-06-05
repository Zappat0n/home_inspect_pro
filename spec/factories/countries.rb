FactoryBot.define do
  factory :country do
    sequence(:name) { |n| "Country #{n}" }
    sequence(:code) { |n| "C#{n}" }
    locale { "en" }
    available { true }
    is_default { false }
  end
end
