# frozen_string_literal: true

# Seed admin user
admin = AdminUser.find_or_create_by!(email: "admin@example.com") do |a|
  a.password = "password"
  a.password_confirmation = "password"
end

puts "Seeded admin user: #{admin.email}"
