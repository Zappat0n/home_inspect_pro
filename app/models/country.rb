# == Schema Information
#
# Table name: countries
# Database name: primary
#
#  id         :bigint           not null, primary key
#  available  :boolean
#  code       :string
#  locale     :string
#  name       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_countries_on_code  (code) UNIQUE
#
class Country < ApplicationRecord
  has_many :users
  has_many :inspection_templates
  has_many :report_templates, dependent: :destroy

  validates :name, presence: true
  validates :code, presence: true, uniqueness: true
  validates :locale, presence: true
end
