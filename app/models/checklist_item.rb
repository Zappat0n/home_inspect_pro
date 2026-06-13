# == Schema Information
#
# Table name: checklist_items
# Database name: primary
#
#  id                     :bigint           not null, primary key
#  allows_photo           :boolean          default(FALSE), not null
#  category               :string           default("General"), not null
#  description            :text
#  name                   :string
#  position               :integer
#  severity               :integer
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  inspection_template_id :bigint           not null
#
# Indexes
#
#  idx_checklist_items_on_template_and_position     (inspection_template_id,position) UNIQUE
#  index_checklist_items_on_inspection_template_id  (inspection_template_id)
#
# Foreign Keys
#
#  fk_rails_...  (inspection_template_id => inspection_templates.id)
#
class ChecklistItem < ApplicationRecord
  belongs_to :inspection_template
  has_many :inspection_items, dependent: :destroy
  has_many :inspection_photos, dependent: :destroy

  validates :name, presence: true
  validates :category, presence: true
  validates :position, presence: true, uniqueness: { scope: :inspection_template_id }

  enum :severity,
       {
         critical: 0,
         major: 1,
         minor: 2,
         info: 3,
       }

  scope :ordered, -> { order(:position) }
end
