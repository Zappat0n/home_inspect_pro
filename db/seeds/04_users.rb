# frozen_string_literal: true

# Seed demo inspector users — one per launch country
demo_users = [
  { email: "inspector.us@example.com", country_code: "US" },
  { email: "inspector.ca@example.com", country_code: "CA" },
  { email: "inspector.es@example.com", country_code: "ES" },
]

demo_users.each do |user_attrs|
  country = Country.find_by!(code: user_attrs[:country_code])

  User.find_or_create_by!(email: user_attrs[:email]) do |user|
    user.country = country
    user.password = "password"
    user.password_confirmation = "password"
  end
end

puts "Seeded #{demo_users.length} demo users"
