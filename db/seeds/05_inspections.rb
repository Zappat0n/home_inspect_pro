# frozen_string_literal: true

# Seed sample inspections for each demo user (mix of draft + completed)
User.find_each do |user|
  template = user.default_inspection_template
  next unless template

  sample_inspections = [
    {
      property_address: "123 Maple Street, Springfield",
      client_name: "Alice Johnson",
      client_email: "alice.johnson@example.com",
      status: :completed,
      completed_at: Time.current,
    },
    {
      property_address: "456 Oak Avenue, Riverton",
      client_name: "Bob Martinez",
      client_email: "bob.martinez@example.com",
      status: :draft,
      completed_at: nil,
    },
    {
      property_address: "789 Pine Lane, Westbrook",
      client_name: "Carol Davis",
      client_email: "carol.davis@example.com",
      status: :completed,
      completed_at: 1.day.ago,
    },
  ]

  sample_inspections.each do |inspection_attrs|
    inspection = Inspection.find_or_create_by!(
      user: user,
      inspection_template: template,
      property_address: inspection_attrs[:property_address],
    ) do |ins|
      ins.client_name = inspection_attrs[:client_name]
      ins.client_email = inspection_attrs[:client_email]
      ins.status = inspection_attrs[:status]
      ins.completed_at = inspection_attrs[:completed_at]
    end

    next if inspection.inspection_items.exists?

    Inspections::InitializeChecklistService.new(inspection).call

    if inspection.completed?
      items = inspection.inspection_items.to_a
      items.first(items.size / 3).each { |item| item.update!(status: :ok) }

      defect_items = items[items.size / 3, items.size / 4]
      defect_items&.each do |item|
        item.update!(
          status: :defect,
          comment: "Needs further evaluation by a qualified professional.",
        )
      end
    end
  end

end

puts "Seeded sample inspections"
