# == Schema Information
#
# Table name: users
# Database name: primary
#
#  id                     :bigint           not null, primary key
#  email                  :string           default(""), not null
#  encrypted_password     :string           default(""), not null
#  remember_created_at    :datetime
#  reset_password_sent_at :datetime
#  reset_password_token   :string
#  trial_ends_at          :datetime
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  country_id             :bigint           not null
#  stripe_customer_id     :string
#
# Indexes
#
#  index_users_on_country_id            (country_id)
#  index_users_on_email                 (email) UNIQUE
#  index_users_on_reset_password_token  (reset_password_token) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (country_id => countries.id)
#
class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable,
         :registerable,
         :recoverable,
         :rememberable,
         :validatable

  pay_customer

  before_create :set_trial

  belongs_to :country
  has_many :inspections, dependent: :destroy
  has_many :inspection_templates, dependent: :nullify

  def subscribed?
    payment_processor.present? && payment_processor.subscribed?
  end

  def on_trial?
    trial_ends_at.present? && Time.current < trial_ends_at
  end

  def trial_days_remaining
    return 0 if trial_ends_at.blank?

    ((trial_ends_at - Time.current) / 1.day).ceil
  end

  def default_inspection_template
    template = InspectionTemplate.published.find_by(country: country)
    return template if template

    us_country = Country.find_by(code: "US")
    InspectionTemplate.published.find_by(country: us_country)
  end

  private

  def set_trial
    self.trial_ends_at ||= 7.days.from_now
  end
end
