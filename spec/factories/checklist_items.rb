FactoryBot.define do
  factory :checklist_item do
    association :inspection_template
    sequence(:name) { |n| "Checklist Item #{n}" }
    description { "Inspect and verify compliance" }
    category { "Safety" }
    severity { :info }
    position { 1 }
    allows_photo { false }
  end
end
