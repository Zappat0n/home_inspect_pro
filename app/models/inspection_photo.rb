# frozen_string_literal: true

# == Schema Information
#
# Table name: inspection_photos
# Database name: primary
#
#  id                :bigint           not null, primary key
#  position          :integer          default(0), not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  checklist_item_id :bigint           not null
#  inspection_id     :bigint           not null
#
# Indexes
#
#  idx_inspection_photos_on_inspection_and_position  (inspection_id,position) UNIQUE
#  index_inspection_photos_on_checklist_item_id      (checklist_item_id)
#  index_inspection_photos_on_inspection_id          (inspection_id)
#
# Foreign Keys
#
#  fk_rails_...  (checklist_item_id => checklist_items.id)
#  fk_rails_...  (inspection_id => inspections.id)
#
class InspectionPhoto < ApplicationRecord
  belongs_to :inspection
  belongs_to :checklist_item
  has_one_attached :photo

  validates :position,
            presence: true,
            uniqueness: { scope: :inspection_id }

  validate :photo_attached

  scope :ordered, -> { order(position: :asc) }

  private

  def photo_attached
    errors.add(:photo, :must_be_attached) unless photo.attached?
  end
end
