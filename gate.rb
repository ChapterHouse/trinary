class Gate

  include Comparable

  def initialize
    @input = Array.new(input_count)
  end

  def name
    self.class.gate_name
  end

  def input(index, gate=false)
    if index < 0
      raise ArgumentError.new("Invalid input connection index #{index}. Connections start at index 0")
    elsif index >= input_count
      raise ArgumentError.new("Invalid input connection index #{index}. This gate accepts #{input_count} inputs.")
    elsif gate != false
      @input[index] = gate
      self
    else
      @input[index].value
    end
  end

  def inputs
    @input[0..input_count-1]
  end

  def inputs=(array)
    array.each_with_index { |inpt, i| input(i, inpt) }
  end

  def input_count
    self.class.input_count
  end

  def number
    self.class.number
  end

  def value
    connected = @input.compact.size
    raise "Unconnected Gate. #{connected} input#{connected == 1 ? '' : 's'} of #{input_count} connected." if connected < input_count
    begin
    calculate.value
    rescue => e
      raise e
    end
  end

  def <=>(other)
    value <=> other.value
  end

  def -@
    -value
  end

  def +@
    value
  end

  def to_i
    value.to_i
  end

  def to_s
    value.to_s
  end

  #def self.register(gate)
  #  registered[gate.name] = gate
  #end
  #
  #def self.registered
  #  @gates ||= {}
  #end
  #
  #def self.[](name)
  #  registered[name]
  #end

  class << self

    def inherited(subclass)
      all << subclass
      if subclass.name.nil?
        require 'securerandom'
        subname = SecureRandom.base64(8)
        klass = class << subclass; self; end
        klass.send(:define_method, :name) { subname }
      else
        subname = subclass.name[-4..-1] == 'Gate' ? subclass.name[0..-5] : subclass.name
      end

      named[subname] = subclass
      @numbered = nil
    end

    def all
      @all ||= []
    end

    def each(&block)
      numbered.keys.each { |i| yield numbered[i] }
    end

    def gate_name
      unless @gate_name
        @gate_name = name
        @gate_name = @gate_name[0..-5] if @gate_name[-4..-1] == 'Gate'
        if @gate_name[0..1] == 'Un' && @gate_name.size < 6
          @gate_name = "Unknown#{number}"
        end
        @gate_name.downcase!
      end
      @gate_name
    end

    def input_count
      const_get(:INPUT_COUNT)
    end

    def names
      named.keys.sort
    end

    def number
      @number ||= table.inject(0) { |total, value| total * 3 + value + 1 }
    end

    def table
      raise "No gate table defined for #{name}"
    end

    def [](identifier)
      if identifier.is_a?(String)
        named[identifier]
      elsif identifier.is_a?(Fixnum)
        numbered[identifier]
      else
        identifier.respond_to?(:to_s) && named[identifier.to_s] || identifier.respond_to?(:to_i) && named[identifier.to_i]
      end
    end

    private

    def named
      @named ||= {}
    end

    def numbered
      unless @numbered
        @numbered = {}
        all.each { |subclass| @numbered[subclass.number] = subclass }
      end
      @numbered
    end


  end

  private

  def calculate
    raise "No output calculation defined for #{self.class.name}"
  end

end

module GateMapper

  def map_to_gate(array)
    gate = {-1 => FalseGate, 0 => PotentialGate, 1 => TrueGate}
    array.map { |x| x.is_a?(Array) ? map_to_gate(x) : gate[x].new }
  end

  def map_to_value(array)
    array.map { |x| x.is_a?(Array) ? map_to_value(x) : x.value }
  end

  def trit_args(size)
    rc = []
    trit_order = [-1, 0, 1]
    #[-1, 0, 1].product(*([-1, 0, 1] * (size - 1))).each_slice(3) { |x| args << x }
    trit_order.product(*([trit_order] * (size - 1))).each_slice(3) { |x| rc << x }

    map_to_gate rc
  end

  def trit_arg_values(size)
    map_to_value(trit_args(size))
  end

end

class Fixnum

  def value
    self
  end

end

module NullDegenerate

  def initialize(*args)
    new_args = args.dup

  end

end

module UniDegenerate

  def initialize(*args)
    new_args = args.dup
    while new_args.size < input_count
      new_args << new_args.first.dup
    end

    super(*new_args)
  end

end