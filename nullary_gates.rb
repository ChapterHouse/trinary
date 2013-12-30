require_relative 'nullary_gate'

class TrueGate < NullaryGate

  def initialize
    super 1
  end

end

class PotentialGate < NullaryGate

  def initialize
    super 0
  end

end

class FalseGate < NullaryGate

  def initialize
    super -1
  end

end