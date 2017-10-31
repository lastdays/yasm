class Yasm::Event
  attr_reader :name
  attr_accessor :transitions

  def initialize(name, transitions = [])
    @name = name
    @transitions = transitions
  end
end
