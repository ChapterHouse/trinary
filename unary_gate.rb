require_relative 'gate'

class UnaryGate < Gate

  INPUT_COUNT = 1

  #def initialize
  #  super 1
  #end

  def initialize(input=nil)
    super()
    self.input=input
  end


  def input(*args)
    if args.empty?
      input(0)
    else
      super
    end
  end

  def input=(gate)
    input(0, gate)
  end

  def self.table
    @table ||= [-1, 0, 1].map { |x| new(x).to_i }
  end

end
