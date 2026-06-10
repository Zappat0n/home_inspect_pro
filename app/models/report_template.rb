# == Schema Information
#
# Table name: report_templates
# Database name: primary
#
#  id               :bigint           not null, primary key
#  footer_text      :text
#  header_text      :text
#  legal_disclaimer :text
#  locale           :string           not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  country_id       :bigint           not null
#
# Indexes
#
#  index_report_templates_on_country_id             (country_id)
#  index_report_templates_on_country_id_and_locale  (country_id,locale) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (country_id => countries.id)
#
class ReportTemplate < ApplicationRecord
  belongs_to :country

  validates :locale, presence: true
  validates :locale, uniqueness: { scope: :country_id }
end
