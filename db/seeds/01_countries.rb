# frozen_string_literal: true

# Seed launch countries
launch_countries = [
  { name: "United States", code: "US", locale: "en", available: true },
  { name: "Canada", code: "CA", locale: "en", available: true },
  { name: "Spain", code: "ES", locale: "es", available: true }
]

launch_countries.each do |country_attrs|
  Country.find_or_create_by!(code: country_attrs[:code]) do |country|
    country.name = country_attrs[:name]
    country.locale = country_attrs[:locale]
    country.available = country_attrs[:available]
  end
end

puts "Seeded #{Country.count} countries"
