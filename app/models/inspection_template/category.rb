# == Schema Information
#
# Table name: inspection_template_categories
# Database name: primary
#
#  id                     :bigint           not null, primary key
#  name                   :string           not null
#  position               :integer
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  inspection_template_id :bigint           not null
#
# Indexes
#
#  idx_categories_on_template_and_name                             (inspection_template_id,name) UNIQUE
#  index_inspection_template_categories_on_inspection_template_id  (inspection_template_id)
#
# Foreign Keys
#
#  fk_rails_...  (inspection_template_id => inspection_templates.id)
#
class InspectionTemplate::Category < ApplicationRecord
  belongs_to :inspection_template
  has_many :items,
           class_name: "InspectionTemplate::Item",
           foreign_key: :inspection_template_category_id,
           dependent: :destroy

  validates :name, presence: true, uniqueness: { scope: :inspection_template_id }

  scope :ordered, -> { order(:position) }
end
