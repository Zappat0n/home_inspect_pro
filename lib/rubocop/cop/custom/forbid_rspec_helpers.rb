# frozen_string_literal: true

class RuboCop::Cop::Custom::ForbidRspecHelpers < ::RuboCop::Cop::Base
  MSG = "Avoid using `let`, `before`, or `subject` in specs; prefer explicit setup and inline test data."

  RESTRICT_ON_SEND = %i[let before subject].freeze

  def on_send(node)
    return unless node.receiver.nil?

    add_offense(node.loc.selector, message: MSG)
  end
end
