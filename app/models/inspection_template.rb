# == Schema Information
#
# Table name: inspection_templates
#
#  id         :bigint           not null, primary key
#  category   :string
#  name       :string
#  published  :boolean          default(FALSE), not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  country_id :bigint           not null
#
# Indexes
#
#  index_inspection_templates_on_country_id  (country_id)
#  index_inspection_templates_on_name        (name)
#
# Foreign Keys
#
#  fk_rails_...  (country_id => countries.id)
#
class InspectionTemplate < ApplicationRecord
  belongs_to :country
  has_many :checklist_items, -> { ordered }, dependent: :destroy

  validates :name, presence: true

  scope :published, -> { where(published: true) }
end
