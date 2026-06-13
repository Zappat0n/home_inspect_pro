FactoryBot.define do
  factory :inspection_template_item, aliases: [:checklist_item], class: "InspectionTemplate::Item" do
    association :inspection_template
    inspection_template_category do
      association(:inspection_template_category, inspection_template: inspection_template)
    end
    sequence(:name) { |n| "Checklist Item #{n}" }
    description { "Inspect and verify compliance" }
    severity { :info }
    position { 1 }
    allows_photo { false }
  end
end
