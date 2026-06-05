# frozen_string_literal: true

class RuboCop::Cop::Custom::ForbidFeatureSpecPageExpectations < ::RuboCop::Cop::Base
  MSG = "Avoid `expect(page)` in feature specs; assert through a page object instead."
  RESTRICT_ON_SEND = %i[to not_to to_not].freeze

  # Matches expect(page).to / not_to / to_not
  def_node_matcher :forbidden_page_expectation?, <<~PATTERN
    (send
      (send nil? :expect {(send {nil? self} :page) (lvar :page)})
      {:to :not_to :to_not}
      ...)
  PATTERN

  def on_send(node)
    return unless forbidden_page_expectation?(node)

    add_offense(node.loc.selector, message: MSG)
  end
end
