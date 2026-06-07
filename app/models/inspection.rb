# == Schema Information
#
# Table name: inspections
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

  validates :property_address, presence: true
  validates :client_name, presence: true

  enum :status,
       {
         draft: 0,
         completed: 1,
       }

  scope :newest_first, -> { order(created_at: :desc) }
end
