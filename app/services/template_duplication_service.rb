# frozen_string_literal: true

class TemplateDuplicationService
  def initialize(source_template, user)
    @source_template = source_template
    @user = user
  end

  def call
    new_template = InspectionTemplate.create!(
      template_type: :custom,
      user: user,
      name: "Copy of #{source_template.name}",
      country: source_template.country,
      published: false,
    )

    duplicate_checklist_items(new_template)

    new_template
  end

  private

  attr_reader :source_template, :user

  def duplicate_checklist_items(new_template)
    source_template.items.includes(:inspection_template_category).find_each do |item|
      category = new_template.categories.find_or_create_by!(name: item.inspection_template_category.name)

      category.items.create!(
        inspection_template: new_template,
        name: item.name,
        description: item.description,
        severity: item.severity,
        position: item.position,
        allows_photo: item.allows_photo,
      )
    end
  end
end
