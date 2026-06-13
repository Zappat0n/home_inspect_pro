# == Schema Information
#
# Table name: inspection_template_items
# Database name: primary
#
#  id                              :bigint           not null, primary key
#  allows_photo                    :boolean          default(FALSE), not null
#  description                     :text
#  name                            :string
#  position                        :integer
#  severity                        :integer
#  created_at                      :datetime         not null
#  updated_at                      :datetime         not null
#  inspection_template_category_id :bigint           not null
#  inspection_template_id          :bigint           not null
#
# Indexes
#
#  idx_items_on_category_and_position                         (inspection_template_category_id,position) UNIQUE
#  idx_on_inspection_template_category_id_d9aada3866          (inspection_template_category_id)
#  index_inspection_template_items_on_inspection_template_id  (inspection_template_id)
#
# Foreign Keys
#
#  fk_rails_...  (inspection_template_category_id => inspection_template_categories.id)
#  fk_rails_...  (inspection_template_id => inspection_templates.id)
#
class InspectionTemplate::Item < ApplicationRecord
  self.table_name = "inspection_template_items"

  belongs_to :inspection_template
  belongs_to :inspection_template_category,
             class_name: "InspectionTemplate::Category"
  has_many :inspection_items, foreign_key: :checklist_item_id, dependent: :destroy
  has_many :inspection_photos, foreign_key: :checklist_item_id, dependent: :destroy

  validates :name, presence: true
  validates :position, presence: true, uniqueness: { scope: :inspection_template_category_id }

  enum :severity,
       {
         critical: 0,
         major: 1,
         minor: 2,
         info: 3,
       }

  scope :ordered, -> { order(:position) }
end
