FactoryBot.define do
  factory :inspection_photo do
    association :inspection
    association :checklist_item
    position { 0 }
  end
end
