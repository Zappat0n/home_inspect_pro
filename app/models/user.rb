# == Schema Information
#
# Table name: users
#
#  id                     :bigint           not null, primary key
#  email                  :string           default(""), not null
#  encrypted_password     :string           default(""), not null
#  remember_created_at    :datetime
#  reset_password_sent_at :datetime
#  reset_password_token   :string
#  subscribed             :boolean          default(FALSE)
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

  belongs_to :country
  has_many :inspections, dependent: :destroy

  def default_inspection_template
    template = InspectionTemplate.published.find_by(country: country)
    return template if template

    us_country = Country.find_by(code: "US")
    InspectionTemplate.published.find_by(country: us_country)
  end
end
