# == Schema Information
#
# Table name: countries
#
#  id         :bigint           not null, primary key
#  available  :boolean
#  code       :string
#  locale     :string
#  name       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
FactoryBot.define do
  factory :country do
    sequence(:name) { |n| "Country #{n}" }
    sequence(:code) { |n| "C#{n}" }
    locale { "en" }
    available { true }
  end
end
