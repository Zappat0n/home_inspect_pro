# frozen_string_literal: true

require "yaml"

Rails.root.join("lib/templates").glob("*.yml").each do |template_file|
  template_data = YAML.load_file(template_file)

  country = Country.find_by!(code: template_data["country_code"])

  template = InspectionTemplate.find_or_create_by!(name: template_data["name"]) do |t|
    t.country = country
    t.published = template_data["published"]
  end

  position = 0

  template_data["categories"].each do |category|
    category["items"].each do |item|
      position += 1

      ChecklistItem.find_or_create_by!(
        name: item["name"],
        inspection_template: template,
      ) do |ci|
        ci.category = category["name"]
        ci.severity = item["severity"]
        ci.position = position
        ci.allows_photo = item["allows_photo"]
      end
    end
  end

  puts "Seeded template: #{template.name} (#{template.checklist_items.size} items)"
end

puts "Total: #{InspectionTemplate.count} templates, #{ChecklistItem.count} items"
