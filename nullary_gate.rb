require_relative 'gate'

class NullaryGate < Gate

  INPUT_COUNT = 0

  def initialize(value)
    @value = value
    super
  end

  def calculate
    @value
  end

  def self.table
    @table ||= [new.to_i]
  end

end
