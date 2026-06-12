FactoryBot.define do
  factory :inspection_template do
    association :country
    sequence(:name) { |n| "Inspection Template #{n}" }
    category { "Electrical" }
    published { false }
    template_type { :system }

    trait :custom do
      template_type { :custom }
      association :user
    end
  end
end
