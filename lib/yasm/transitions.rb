module Yasm
  class Transitions
    include Enumerable

    attr_accessor :data

    def initialize(transitions)
      raise StandardError unless transitions.is_a?(Array)
      @data = transitions
    end

    def each
      data.each
    end

    def push(transition)
      raise StandardError unless transition.is_a?(Yasm::Transition)
      @data.push(transition)
    end
  end
end
