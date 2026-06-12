# == Schema Information
#
# Table name: inspection_templates
# Database name: primary
#
#  id            :bigint           not null, primary key
#  category      :string
#  name          :string
#  published     :boolean          default(FALSE), not null
#  template_type :integer          default(0), not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  country_id    :bigint           not null
#  user_id       :bigint
#
# Indexes
#
#  index_inspection_templates_on_country_id  (country_id)
#  index_inspection_templates_on_name        (name)
#  index_inspection_templates_on_user_id     (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (country_id => countries.id)
#  fk_rails_...  (user_id => users.id)
#
class InspectionTemplate < ApplicationRecord
  belongs_to :country
  belongs_to :user, optional: true
  has_many :checklist_items, -> { ordered }, dependent: :destroy
  has_many :inspections, dependent: :destroy

  validates :name, presence: true
  validate :max_custom_templates, on: :create, if: -> { custom? }

  enum :template_type, { system: 0, custom: 1 }

  scope :published, -> { where(published: true) }
  scope :system_templates, -> { where(template_type: :system) }
  scope :custom_templates, -> { where(template_type: :custom) }
  scope :for_user, ->(user) { system_templates.or(where(user: user)) }

  private

  def max_custom_templates
    return unless user.present? && user.inspection_templates.custom_templates.count >= 5

    errors.add(:base, "Maximum of 5 custom templates allowed")
  end
end
