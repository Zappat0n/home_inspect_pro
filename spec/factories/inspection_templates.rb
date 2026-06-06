FactoryBot.define do
  factory :inspection_template do
    association :country
    sequence(:name) { |n| "Inspection Template #{n}" }
    category { "Electrical" }
    published { false }
  end
end
