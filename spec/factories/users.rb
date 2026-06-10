FactoryBot.define do
  factory :user do
    association :country
    sequence(:email) { |n| "user#{n}@example.com" }
    password { "password123" }
    password_confirmation { "password123" }
    trial_ends_at { 7.days.from_now }
  end
end
