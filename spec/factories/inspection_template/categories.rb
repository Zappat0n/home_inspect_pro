FactoryBot.define do
  factory :inspection_template_category, class: "InspectionTemplate::Category" do
    association :inspection_template
    sequence(:name) { |n| "Category #{n}" }
    position { 1 }
  end
end
