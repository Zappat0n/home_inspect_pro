FactoryBot.define do
  factory :inspection_item do
    association :inspection
    association :checklist_item
    status { :ok }
    comment { nil }
  end
end
