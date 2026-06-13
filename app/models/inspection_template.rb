# == Schema Information
#
# Table name: inspection_templates
# Database name: primary
#
#  id            :bigint           not null, primary key
#  category      :string
#  name          :string
#  published     :boolean          default(FALSE), not null
#  template_type :integer          default("system"), not null
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
  MAX_CUSTOM_TEMPLATES = 10

  belongs_to :country
  belongs_to :user, optional: true
  has_many :items,
           -> { ordered },
           class_name: "InspectionTemplate::Item",
           dependent: :destroy
  has_many :categories,
           -> { ordered },
           class_name: "InspectionTemplate::Category",
           dependent: :destroy
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
    return if user.blank?
    return if custom_template_count_for_user < MAX_CUSTOM_TEMPLATES

    errors.add(:base, :max_custom_templates, count: MAX_CUSTOM_TEMPLATES)
  end

  def custom_template_count_for_user
    user
      .inspection_templates
      .custom_templates
      .count
  end
end
