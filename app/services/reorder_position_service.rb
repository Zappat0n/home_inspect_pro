# frozen_string_literal: true

class ReorderPositionService
  attr_reader :scope, :positions_data

  def initialize(scope, positions_data)
    @scope = scope
    @positions_data = positions_data
  end

  def call
    return if positions_data.empty?

    ids = positions_data.map { |d| d.fetch(:id) }
    records = scope.where(id: ids)

    ActiveRecord::Base.transaction do
      records.update_all("position = -position")

      table = Arel::Table.new(scope.table_name)
      case_node = positions_data.reduce(Arel::Nodes::Case.new) do |node, data|
        node.when(table[:id].eq(data.fetch(:id).to_i))
          .then(data.fetch(:position).to_i)
      end

      records.update_all(position: case_node)
    end
  end
end
