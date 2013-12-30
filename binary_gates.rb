require_relative 'binary_gate'



class JunkGate < BinaryGate

  def calculate

    x = p + 1
    y = q + 1

    [[1, 2, 3], [4, 5, 6], [7, 8, 9]][x][y]

  end


end

=begin

def subtransname(x)
  if ['PC', 'CS', 'PS', 'TH', 'HB', 'TB'].include?(x)
    "Swap#{x}"
  elsif ['L', 'R', 'U', 'D'].include?(x)
    "Shift#{x}"
  elsif x == 'W'
    'Wrap'
  else
    '?'
  end
end

def transname(x)
  order = ['W', 'PC', 'CS', 'PS', 'TH', 'HB', 'TB', 'L', 'R', 'U', 'D']
  x.gsub(/./) { |match| "#{match} " }.gsub(/P C|P S|C S|T H|H B|T B/) { |match| match.gsub(' ','') }.split.sort { |a, b| order.index(a) <=> order.index(b) }.map { |y| subtransname(y) }.join.gsub(/Shift.Shift/) { |match| match[0..5]  }.gsub(/Swap..Swap/) { |match| match[0..5] }
end

def transname2(x)
  order = ['W', 'PC', 'CS', 'PS', 'TH', 'HB', 'TB', 'L', 'R', 'U', 'D']
  x.gsub(/./) { |match| "#{match} " }.gsub(/P C|P S|C S|T H|H B|T B/) { |match| match.gsub(' ','') }.split.sort { |a, b| order.index(a) <=> order.index(b) }.map { |y| subtransname(y) }.join
end

a = ['PC', 'CS', 'PS']
b = ['TH', 'HB', 'TB']
c = ['L', 'R']
d = ['U', 'D']
e = ['', 'W']
#e = ['']
base = [a, b, c, d]

groups = (base.combination(0).to_a + base.combination(1).to_a + base.combination(2).to_a).map { |x| x.size < 2 ? x : x.first.product(x.last).to_a }.inject([]) do |array, x|
  if x.first.nil?
    array << ''
  elsif x.size == 1
    array += x.first
  else
    array += x
  end
end.product(e).map { |x| x.reverse.join }.map { |x| transname(x) }

duplications =
{
    'SwapPC' => ['SwapCSShiftR', 'SwapPSShiftL'],
    'SwapCS' => ['SwapPCShiftL', 'SwapPSShiftR'],
    'SwapPS' => ['SwapPCShiftR', 'SwapCSShiftL'],
    'SwapTH' => ['SwapHBShiftD', 'SwapTBShiftU'],
    'SwapHB' => ['SwapTHShiftU', 'SwapTBShiftD'],
    'SwapTB' => ['SwapTHShiftD', 'SwapHBShiftU']
}



groups2 = (base.combination(0).to_a + base.combination(1).to_a + base.combination(2).to_a).map { |x| x.size < 2 ? x : x.first.product(x.last).to_a }.inject([]) do |array, x|
  if x.first.nil?
    array << ''
  elsif x.size == 1
    array += x.first
  else
    array += x
  end
end.product(e).map { |x| x.reverse.join }.map { |x| transname2(x) }

#groups2.each { |x| puts x.inspect }
#puts groups.size

def numerize(name)

  p = [-1, 0, 1]
  q = [-1, 0, 1]

  nm = name[0..3] == 'Wrap' ? name[4..-1] : name.dup

  nm.each_char.to_a.each_slice(6).to_a.map(&:join).each do |trans|
    case trans
      when 'SwapPC'
        p[0], p[1] = p[1], p[0]
      when 'SwapCS'
        p[1], p[2] = p[2], p[1]
      when 'SwapPS'
        p[0], p[2] = p[2], p[0]
      when 'SwapTH'
        q[0], q[1] = q[1], q[0]
      when 'SwapHB'
        q[1], q[2] = q[2], q[1]
      when 'SwapTB'
        q[0], q[2] = q[2], q[0]
      when 'ShiftL'
        p.push(p.shift)
      when 'ShiftR'
        p.unshift(p.pop)
      when 'ShiftU'
        q.push(q.shift)
      when 'ShiftD'
        q.unshift(q.pop)
      else
        puts "Crap #{trans.inspect}"
    end
  end

  p, q = q, p if name != nm

  name = 'Identity' if name == ''

  [q, p, name]

end

groups2.map! { |x| numerize(x) }

groups2.each do |x, y, name|
  name = "Trans#{name}"
  if name.include?('TransWrap')
    eval <<-WRAPTRANSFORMATION
        module #{name}
          def self.included(base)
            class << base
              def origin(binary_gate_class)
                gate = binary_gate_class.new
                @@transformed_table = #{x.inspect}.map do |q|
                  #{y.inspect}.map do |p|
                    gate.inputs = [p, q]
                    gate.to_i
                  end
                end
              end
            end
          end

          def calculate
            @@transformed_table[p+1][q+1]
          end
        end
    WRAPTRANSFORMATION
  else
    eval <<-TRANSFORMATION
        module #{name}
          def self.included(base)
            class << base
              def origin(binary_gate_class)
                gate = binary_gate_class.new
                @@transformed_table = #{x.inspect}.map do |p|
                  #{y.inspect}.map do |q|
                    gate.inputs = [p, q]
                    gate.to_i
                  end
                end
              end
            end
          end

          def calculate
            @@transformed_table[p+1][q+1]
          end
        end
    TRANSFORMATION
  end
end


$new_transformations = groups2.map(&:last)
$new_transformations

=end

=begin
#groups2.sort!
#groups2.each { |x| puts x.inspect }

b = Hash.new(0)
groups2.each { |x| b[[x[0], x[1]] ] += 1}
c = b.keys.select { |x| b[x] > 1 }

c.each { |x|
  groups2.each { |y|
    puts y.inspect  if x[0] == y[0] && x[1] == y[1]
  }
  puts '----'
}

puts groups2.size
puts groups2.uniq.size

exit

worded = [
[[-1, 0, 1], [-1, 0, 1]],
[[-1, 0, 1], [-1, 1, 0]],
[[-1, 0, 1], [-1, 1, 0]],
[[-1, 0, 1], [0, -1, 1]],
[[-1, 0, 1], [0, -1, 1]],
[[-1, 0, 1], [0, 1, -1]],
[[-1, 0, 1], [0, 1, -1]],
[[-1, 0, 1], [1, -1, 0]],
[[-1, 0, 1], [1, -1, 0]],
[[-1, 0, 1], [1, 0, -1]],
[[-1, 0, 1], [1, 0, -1]],
[[-1, 1, 0], [-1, 1, 0]],
[[-1, 1, 0], [0, -1, 1]],
[[-1, 1, 0], [1, 0, -1]],
[[0, -1, 1], [-1, 1, 0]],
[[0, -1, 1], [0, -1, 1]],
[[0, -1, 1], [1, 0, -1]],
[[0, 1, -1], [-1, 1, 0]],
[[0, 1, -1], [-1, 1, 0]],
[[0, 1, -1], [-1, 1, 0]],
[[0, 1, -1], [-1, 1, 0]],
[[0, 1, -1], [0, -1, 1]],
[[0, 1, -1], [0, -1, 1]],
[[0, 1, -1], [0, -1, 1]],
[[0, 1, -1], [0, -1, 1]],
[[0, 1, -1], [0, 1, -1]],
[[0, 1, -1], [1, -1, 0]],
[[0, 1, -1], [1, 0, -1]],
[[0, 1, -1], [1, 0, -1]],
[[0, 1, -1], [1, 0, -1]],
[[0, 1, -1], [1, 0, -1]],
[[1, -1, 0], [-1, 1, 0]],
[[1, -1, 0], [-1, 1, 0]],
[[1, -1, 0], [-1, 1, 0]],
[[1, -1, 0], [-1, 1, 0]],
[[1, -1, 0], [0, -1, 1]],
[[1, -1, 0], [0, -1, 1]],
[[1, -1, 0], [0, -1, 1]],
[[1, -1, 0], [0, -1, 1]],
[[1, -1, 0], [0, 1, -1]],
[[1, -1, 0], [1, -1, 0]],
[[1, -1, 0], [1, 0, -1]],
[[1, -1, 0], [1, 0, -1]],
[[1, -1, 0], [1, 0, -1]],
[[1, -1, 0], [1, 0, -1]],
[[1, 0, -1], [-1, 1, 0]],
[[1, 0, -1], [0, -1, 1]],
[[1, 0, -1], [1, 0, -1]]
]



#wtf = (worded - $transformations)
#missing = $transformations - worded

puts worded.size
puts worded.uniq.size

#puts $transformations.size
#puts wtf.size
#puts missing.size
#
#missing.each { |x| puts x.inspect }


exit


original = ['SwapMR',
'SwapLM',
'ShiftL',
'ShiftR',
'SwapLR',
'SwapMB',
'SwapMRMB',
'SwapLMMB',
'ShiftLSwapMB',
'ShiftRSwapMB',
'SwapLFMB',
'SwapTM',
'SwapMRTM',
'SwapLMTM',
'ShiftLSwapTM',
'ShiftRSwapTM',
'SwapLRTM',
'ShiftU',
'SwapMRShiftU',
'SwapLMShiftU',
'ShiftLU',
'ShiftRU',
'SwapLRShiftU',
'ShiftD',
'SwapMRShiftD',
'SwapLMShiftD',
'ShiftLD',
'ShiftRD',
'SwapLRShiftD',
'SwapTB',
'SwapMRTB',
'SwapLMTB',
'ShiftLSwapTB',
'ShiftRSwapTB',
'SwapLRShiftU'
]


original.sort!
newt = groups.map { |x| x.gsub('P','L').gsub('S','R').gsub('C', 'M').gsub('H','M').gsub('Rhift','Shift').gsub('Rwap','Swap') }.sort

(newt - original).each { |x| puts x }

exit

# .gsub(/./) { |match| "#{match} " }.gsub(/P C|P S|C S|T H|H B|T H/) { |match| match.gsub(' ','') }.split


# PQ Transformation Primitives
# ['PC', 'CS', 'PS'], ['TH', 'HB', 'TH'], ['L', 'R'], ['U', 'D'], ['', 'W']
# Swaps: LM MR LR TM MB TM
# Shifts: L R U D W
# QP:
def transnamepq(i)

  case i
    when 0
      'Identity'
    when 1
      'SwapMR'
    when 2
      'SwapLM'
    when 3
      'ShiftL'
    when 4
      'ShiftR'
    when 5
      'SwapLR'
    when 6
      'SwapMB'
    when 7
      'SwapMRMB'
    when 8
      'SwapLMMB'
    when 9
      'ShiftLSwapMB'
    when 10
      'ShiftRSwapMB'
    when 11
      'SwapLFMB'
    when 12
      'SwapTM'
    when 13
      'SwapMRTM'
    when 14
      'SwapLMTM'
    when 15
      'ShiftLSwapTM'
    when 16
      'ShiftRSwapTM'
    when 17
      'SwapLRTM'
    when 18
      'ShiftU'
    when 19
      'SwapMRShiftU'
    when 20
      'SwapLMShiftU'
    when 21
      'ShiftLU'
    when 22
      'ShiftRU'
    when 23
      'SwapLRShiftU'
    when 24
      'ShiftD'
    when 25
      'SwapMRShiftD'
    when 26
      'SwapLMShiftD'
    when 27
      'ShiftLD'
    when 28
      'ShiftRD'
    when 29
      'SwapLRShiftD'
    when 30
      'SwapTB'
    when 31
      'SwapMRTB'
    when 32
      'SwapLMTB'
    when 33
      'ShiftLSwapTB'
    when 34
      'ShiftRSwapTB'
    when 35
      'SwapLRShiftU' # 'Rotate'
    else
      "PQ#{i}"
  end

end

def transnameqp(i)

  case i
    when 0
      'BackFlip'
    when 5
      'RotateR'
    when 30
      'RotateL'
    else
      "QP#{i}"
  end

end


$transformations.size.times do |i|

  eval <<-JUNK

    class #{transnamepq(i)} < BinaryGate
      include BinaryTransformationPQ#{i}
      origin JunkGate
    end

    #puts "T#{transnamepq(i)} = BinaryTransformationPQ#{i}"
    T#{transnamepq(i)} = BinaryTransformationPQ#{i}

    class #{transnameqp(i)} < BinaryGate
      include BinaryTransformationQP#{i}
      origin JunkGate
    end

  JUNK

end



#require_relative 'unary_gates'
=end

=begin

class AndGate < BinaryGate

  def calculate
    [p, q].min
  end

end

class FalseGate < BinaryGate

  include BinaryPQDegenerate

  def calculate
    -1
  end

end unless defined?(FalseGate)

class ImplicationGate < BinaryGate

  def initialize(*args)
    @not_p = NotGate.new
    @or_p_q = OrGate.new
    super
  end

  def calculate
    @not_p.input = q
    @or_p_q.inputs = [@not_p, q]
    @or_p_q
  end

end

class TestGate < BinaryGate

  def calculate
    -TrueGate.new
  end

end

class NotGate < BinaryGate

  include BinaryPDegenerate

  def calculate
    -p
  end

end

class OrGate < BinaryGate

  def calculate
    [p, q].max
  end

end

class PotentialGate < BinaryGate

  include BinaryPQDegenerate

  def calculate
    0
  end

end unless defined?(PotentialGate)

class TrueGate < BinaryGate

  include BinaryPQDegenerate

  def calculate
    1
  end

end unless defined?(TrueGate)

class AndRotLGate < BinaryGate

  def calculate
    [[-1,  0,  1],
     [-1,  0,  0],
     [-1, -1, -1]
    ][p+1][q+1]
  end

end
=end


#class ZZZ < BinaryGate
#  include BinaryTransformationQP0
#  origin JunkGate
#end
#
#($transformations.size - 1).times do |i|
#  blerk = Class.new(BinaryGate)
#  blerk.send(:include, Object.const_get("BinaryTransformationQP#{i+1}"))
#  blerk.send(:origin, ZZZ)
#
#  BinaryGate.all.each do |klass|
#    if klass.table == blerk.table
#      if klass != blerk && klass.table == blerk.table
#        puts "Transforamtion#{i+1} -> #{klass.name}"
#      end
#    end
#  end
#end

=begin
($transformations.size - 1).times do |i|
  blerk = Class.new(BinaryGate)
  blerk.send(:include, Object.const_get("BinaryTransformationPQ#{i+1}"))
  blerk.send(:origin, Identity)

  BinaryGate.all.each do |klass|
    if klass.table == blerk.table
      if klass != blerk && klass.table == blerk.table
        puts "Transforamtion#{i+1} -> #{klass.name}"
      end
    end
  end
end
=end



#class AndRotRGate < BinaryGate
#
#  include BinaryRotR
#
#  origin JunkGate
#
#end

#class AndRotLGate < BinaryGate
#
#  include BinaryRotL
#
#  origin JunkGate
#
#end

#class AndDupGate < BinaryGate
#
#  include BinaryDup
#
#  origin JunkGate
#
#end


#class AndFlipGate < BinaryGate
#
#  def calculate
#    [[ 1,  0, -1],
#     [ 0,  0,  1],
#     [-1, -1, -1]
#    ][p+1][q+1]
#  end
#
#end

