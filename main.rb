=begin

class DSLBlock

  def initialize(parent = nil, &block)
    @block = block
    @parent = parent
  end

  def execute
    instance_eval(&@block)
  end

  def method_missing(name, *args, &block)
    if @parent && @parent.respond_to?(name)
      @parent.send(name, *args, &block)
    else
      super
    end
  end

end

class Orchestrator < DSLBlock

  def oputs(string)
    puts "Orchestrate #{string}"
  end

  def roles(&block)
    roller = Roller.new(self, &block)
    roller.execute
  end

end

class Roller < DSLBlock

  def rputs(string)
    puts "Roller #{string}"
  end

end


def orchestrate(&block)

  x = Orchestrator.new(&block)
  x.execute

end



orchestrate do
  puts 'A'
  oputs 'A'
  roles do
    puts 'B'
    rputs 'B'
    oputs 'B'
  end
end

#oputs 'A'

exit


=end

=begin
source1 = [[-1, -1], [-1, 0], [-1, 1]]
source2 = [[ 0, -1], [ 0, 0], [ 0, 1]]
source3 = [[ 1, -1], [ 1, 0], [ 1, 1]]

@source = [source1, source2, source3]

def show_element(element)
  print '(%2i, %2i)' % element
end

def show_row(row)
  row.each { |element| show_element element }
  puts "\n"
end

def show_table(table)
  table.each { |row| show_row row }
  puts "\n"
end

def gate(p, q)
  @source[p+1][q+1]
end

show_table @source

table2 = [
    [gate(1, -1), gate(0, -1), gate(-1, -1)],
    [gate(1,  0),  gate(0, 0),  gate(-1, 0)],
    [gate(1,  1),  gate(0, 1),  gate(-1, 1)]
  ]

show_table table2


table3 = [-1, 0, 1].map do |q|
  [1, 0, -1].map do |p|
    gate(p, q)
  end
end

show_table table3

exit
=end
#require_relative 'unary_gates'
require_relative 'binary_gates'
require_relative 'transformations'

include GateMapper

def trans_gates
  @trans_gates ||= {}
end

def pgate(name)
  puts name
  ptable trans_gates[name]
  puts "\n"
end

def ptable(klass)
  puts klass.table.map { |x| '%1i' % x }.each_slice(3).to_a.map { |x| x.join(' ') }
end

def table(gate, show_headers=false)
  if gate.input_count == 0
    #table = [gate.name, gate.value.to_s]
    table = [gate.name] + gate.table.map { |x| '%2i' % x }
  elsif gate.input_count == 1
    table = [gate.name] + gate.table.map { |x| '%2i' % x }
    #elsif gate.input_count == 101
    #  inputs = [-1, 0, 1]
    #  table = inputs.inject([gate.name]) { |table, input|
    #    gate.input = input
    #    table << (show_headers ? '%2i %2i' % [input, gate] : '%2i' % gate)
    #  }
  elsif true == false
    inputs = [
        [-1, -1],
        [-1,  0],
        [-1,  1],
        [ 0, -1],
        [ 0,  0],
        [ 0,  1],
        [ 1, -1],
        [ 1,  0],
        [ 1,  1],
    ]
    #inputs = map_to_gate(inputs)
    values = inputs.map do |input|
      gate.input(0, input[0])
      gate.input(1, input[1])
      gate.value
    end
    table = []
    table << gate.name
    headers = [-1, 0, 1]
    table << '   %2i %2i %2i' % headers if show_headers
    rows = values.each_slice(3).to_a
    rows.each_with_index do |row, i|
      table << (show_headers ? '%2i %2i %2i %2i' % row.unshift(headers[i]) : '%2i %2i %2i' % row)
    end
  else
    table = [gate.name + ":#{gate.number}"] + gate.table.map { |x| '%1i' % x }.each_slice(3).to_a.map { |x| x.join(' ') }
  end
  table.map { |row| row.center(show_headers ? 20 : 18) }
end





#true_gate = TrueGate.new
#potential_gate = PotentialGate.new
#false_gate = FalseGate.new
#
#inputs = [true_gate, potential_gate, false_gate]
#inputs.each { |x| puts "#{x.name} #{x.output}" }

#not_gate = NotGate.new
#puts table(not_gate).join("\n")

#and_gate = AndGate.new
#puts table(and_gate).join("\n")

def show_gates(gates, show_headers=false)
  tables = gates.sort { |a, b| a.number <=> b.number }.map { |gate| table(gate, show_headers) }
  groups = tables.each_slice(9).to_a
  groups.each do |tables|
    tables.first.size.times do |i|
      puts tables.map { |t| t[i] }.join('  ') + "\n"
    end
    puts "\n"
  end
end


#show_gates NullaryGate.all


#show_gates UnaryGate.all
#show_gates (0..26).to_a.reverse.map { |i| UnaryGate[i] }

#gates = UnaryGate.names.select { |name| name[0..1] == 'Un' && name.size < 6 }.map { |name| UnaryGate[name] }
#show_gates gates


transformation_codes.each do |code|
  klass = Class.new(BinaryGate)
  klass.send(:include, Object.const_get("Trans#{code}"))
  klass.send(:origin, JunkGate)
  klass.instance_eval <<-NAME
  def name
    #{code.inspect}
  end
  NAME
  trans_gates[klass.name] = klass
end

pgate ""
pgate "W"
pgate "CS"
pgate "WCS"
exit

hash = {}

trans_gates.values.each { |klass| hash[klass.table] = Array(hash[klass.table]) << klass.name }

hash.each do |key, value|
  if value.size > 1
    puts value.inspect
    puts key.map { |x| '%1i' % x }.each_slice(3).to_a.map { |x| x.join(' ') }
  end
end


puts "#{transformation_codes.size} original transformations"
puts "#{hash.keys.size} unique transformations"


#show_gates trans_gates.select { |x| x.name == 'Identity' || x.name == 'Wrap' }

#show_gates trans_gates

#show_gates BinaryGate.all






#inputs_each






=begin

UnaryGate.new(:not) { |trit| -trit }
BinaryGate.new(:and) { |a, b| [a, b].min }
BinaryGate.new(:or) { |a, b| [a, b].max }
BinaryGate.new(:imp) { |ta, tb|

  def timp(trit_a, trit_b)
    tor(tnot(trit_a), trit_b)
  end

}



class TruthTable

  attr_reader :name

  def initialize(name, &block)
    @name = name
    @block = block
  end

end

def tand(*trits)
  trits.min
end

def tor(*trits)
  trits.max
end

def tnot(trit)
  -trit
end

def timp(trit_a, trit_b)
  tor(tnot(trit_a), trit_b)
end

def txor(*trits)
  tand tnot(tand(*trits)), tor(*trits)
end

def tax(*trits)
  trits.count(1).odd? ? 1 : -1
end

def trit_order
  [1, 0, -1]
end

def trit_args(size)
  rc = []
  trit_order.product(*([trit_order] * (size - 1))).each_slice(3) { |x| rc << x }
  rc
end

def table(tcom, trit_count)
  trit_args(trit_count).map { |trit_group| trit_group.map { |trits| send tcom, *trits } }
end

def ptable(tcom, trit_count)
  table(tcom, trit_count).each { |values| puts('%2i %2i %2i' % values) }
end

def stcom(tcom)

end

def ptcom(tcom)
  puts "\n"
  puts tcom.to_s.center(15)
  fmt = (["%2i"] * 3).join(' ')
  puts("   #{fmt}" % trit_order)
  table(tcom, 2).each_with_index do |trits, i|
    puts("%2i #{fmt}" % [trit_order[i], trits].flatten)
  end
end

def stcoms(*tcoms)

end

def ptcoms(*tcoms)
  stcoms(*tcoms)
end

#tvs = [1, 0, -1]
#puts('   %2i %2i %2i' % tvs)
#tvs.each do |trit_a|
#  values = tvs.map { |trit_b| tand(trit_a, trit_b)}
#  values.unshift trit_a
#  puts('%2i %2i %2i %2i' % values)
#end
#puts "\n"

#tvs = [1, 0, -1]
#puts('   %2i %2i %2i' % tvs)
#tvs.each do |trit_a|
#  values = tvs.map { |trit_b| tor(trit_a, trit_b)}
#  values.unshift trit_a
#  puts('%2i %2i %2i %2i' % values)
#end
#puts "\n"
#
#tvs.each do |trit_a|
#  puts('%2i %2i' % [trit_a, tnot(trit_a)])
#end
#puts "\n"


#tvs = [1, 0, -1]
#puts('   %2i %2i %2i' % tvs)
#tvs.each do |trit_a|
#  values = tvs.map { |trit_b| txor(trit_a, trit_b)}
#  values.unshift trit_a
#  puts('%2i %2i %2i %2i' % values)
#end


#tvs.each do |a|
#  tvs.each do |b|
#    tvs.each do |c|
#      puts('%2i %2i %2i %2i' % [a, b, c, txor(a, b, c)])
#    end
#  end
#end


#tvs = [1, 1]
#
#10.times do |i|
#  x = tor(*tvs)
#  puts x
#  tvs.push x
#  tvs.shift
#end

#tvs = [1, 0, -1]
#tvs.each do |trit_a|
#  values = tvs.map { |trit_b| timp(trit_a, trit_b)}
#  puts('%2i %2i %2i' % values)
#end
#puts "\n"


ptcom :tand
ptcom :tor
ptcom :timp
ptcom :txor

=end