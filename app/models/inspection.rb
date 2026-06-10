# == Schema Information
#
# Table name: inspections
# Database name: primary
#
#  id                     :bigint           not null, primary key
#  client_email           :string
#  client_name            :string
#  completed_at           :datetime
#  pdf_url                :string
#  property_address       :text
#  signature_data         :text
#  status                 :integer
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  inspection_template_id :bigint           not null
#  user_id                :bigint           not null
#
# Indexes
#
#  index_inspections_on_inspection_template_id  (inspection_template_id)
#  index_inspections_on_status                  (status)
#  index_inspections_on_user_id                 (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (inspection_template_id => inspection_templates.id)
#  fk_rails_...  (user_id => users.id)
#
class Inspection < ApplicationRecord
  belongs_to :user
  belongs_to :inspection_template
  has_many :inspection_items, dependent: :destroy
  has_many :inspection_photos, dependent: :destroy
  has_one_attached :pdf

  validates :property_address, presence: true
  validates :client_name, presence: true

  enum :status,
       {
         draft: 0,
         completed: 1,
       }

  scope :newest_first, -> { order(created_at: :desc) }

  def next_photo_position
    (inspection_photos.maximum(:position) || 0) + 1
  end

  def locale
    inspection_template
      .country
      .locale
  end
end
