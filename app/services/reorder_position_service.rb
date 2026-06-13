# frozen_string_literal: true

class ReorderPositionService
  attr_reader :scope, :positions_data

  def initialize(scope, positions_data)
    @scope = scope
    @positions_data = positions_data
  end

  def call
    ids = positions_data.map { |d| d.fetch(:id) }
    records = scope.where(id: ids)

    ActiveRecord::Base.transaction do
      records.update_all("position = -position")

      when_clauses = positions_data.map { |d| "WHEN #{d[:id]} THEN #{d[:position]}" }.join(" ")
      records.update_all("position = CASE id #{when_clauses} END")
    end
  end
end
