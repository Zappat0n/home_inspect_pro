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
class Country < ApplicationRecord
  has_many :users

  validates :name, presence: true
  validates :code, presence: true, uniqueness: true
  validates :locale, presence: true
end
