# == Schema Information
#
# Table name: inspection_items
# Database name: primary
#
#  id                :bigint           not null, primary key
#  comment           :text
#  repair_priority   :integer
#  status            :integer
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  checklist_item_id :bigint           not null
#  inspection_id     :bigint           not null
#
# Indexes
#
#  idx_inspection_items_on_inspection_and_item  (inspection_id,checklist_item_id) UNIQUE
#  index_inspection_items_on_checklist_item_id  (checklist_item_id)
#  index_inspection_items_on_inspection_id      (inspection_id)
#
# Foreign Keys
#
#  fk_rails_...  (checklist_item_id => inspection_template_items.id)
#  fk_rails_...  (inspection_id => inspections.id)
#
class InspectionItem < ApplicationRecord
  belongs_to :inspection
  belongs_to :checklist_item,
             class_name: "InspectionTemplate::Item"

  enum :status,
       {
         ok: 0,
         defect: 1,
         na: 2,
       }

  enum :repair_priority,
       {
         immediate: 0,
         within_30_days: 1,
         within_6_months: 2,
         monitor: 3,
       },
       prefix: true

  validates :checklist_item_id,
            uniqueness: { scope: :inspection_id }

  scope :with_defects, -> { where(status: :defect) }
  scope :with_comments, -> { where.not(comment: [nil, ""]) }
end
