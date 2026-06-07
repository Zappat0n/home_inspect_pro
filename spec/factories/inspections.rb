FactoryBot.define do
  factory :inspection do
    association :user
    association :inspection_template
    property_address { "123 Main St, Anytown, USA" }
    client_name { "Jane Doe" }
    client_email { "client@example.com" }
    status { :draft }
  end
end
