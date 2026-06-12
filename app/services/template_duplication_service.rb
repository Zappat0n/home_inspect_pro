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
    source_template.checklist_items.each do |item|
      new_template.checklist_items.create!(
        name: item.name,
        description: item.description,
        category: item.category,
        severity: item.severity,
        position: item.position,
        allows_photo: item.allows_photo,
      )
    end
  end
end
