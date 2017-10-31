class Yasm::Transition
  attr_reader :from, :to

  def initialize(from:, to:)
    @from = from
    @to = to
  end
end
