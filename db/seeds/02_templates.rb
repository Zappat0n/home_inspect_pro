# frozen_string_literal: true

require "yaml"

Rails.root.join("lib/templates").glob("*.yml").each do |template_file|
  template_data = YAML.load_file(template_file)

  country = Country.find_by!(code: template_data["country_code"])

  template = InspectionTemplate.find_or_create_by!(name: template_data["name"]) do |t|
    t.country = country
    t.published = template_data["published"]
    t.template_type = :system
  end

  position = 0

  template_data["categories"].each do |category_data|
    category = InspectionTemplate::Category.find_or_create_by!(
      inspection_template: template,
      name: category_data["name"],
    )

    category_data["items"].each do |item|
      position += 1

      category.items.find_or_create_by!(
        name: item["name"],
      ) do |ci|
        ci.severity = item["severity"]
        ci.position = position
        ci.allows_photo = item["allows_photo"]
      end
    end
  end

  puts "Seeded template: #{template.name} (#{template.items.size} items)"
end

puts "Total: #{InspectionTemplate.count} templates, #{InspectionTemplate::Item.count} items"
