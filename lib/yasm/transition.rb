module Yasm
  class Transition
    attr_reader :from, :to, :guard

    def initialize(from:, to:, guard: nil)
      @from = from
      @to = to
      @guard = guard || -> { true }
    end

    def evaluate_guard(context)
      if guard.respond_to?(:call)
        guard.call
      elsif context.respond_to?(guard)
        context.send(guard)
      else
        true
      end
    end
  end
end
