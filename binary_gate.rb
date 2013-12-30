require_relative 'gate'

class BinaryGate < Gate

  INPUT_COUNT = 2

  def initialize(p=nil, q=nil)
    super()
    self.p=p
    self.q=q
  end

  def p
    input(0)
  end

  def p=(x)
    input(0, x)
  end

  def q
    input(1)
  end

  def q=(x)
    input(1, x)
  end

  def table
    pq = [
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

    @table ||= pq.map do |p, q|
      self.p = p
      self.q = q
      to_i
    end
  end

  def self.table
    new.table
  end

end

module BinaryPDegenerate

  def initialize(p=nil, q=nil)
    super(p, q || 0)
  end

  def input=(x)
    self.p = x
  end

end

module BinaryQDegenerate

  def initialize(p=nil, q=nil)
    super(p || 0, q || p)
  end

  def input=(x)
    self.q = x
  end

end

module BinaryPQDegenerate

  def initialize(p=nil, q=nil)
    super(p || 0, q || 0)
  end

end

# T, M, B
# L, M, R

module BinaryRotR

  def self.included(base)
    class << base
      def origin(binary_gate_class)
        gate = binary_gate_class.new
        @@transformed_table = [-1, 0, 1].map do |q|
          [1, 0, -1].map do |p|
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


module BinaryRotL

  def self.included(base)
    class << base
      def origin(binary_gate_class)
        gate = binary_gate_class.new
        @@transformed_table = [1, 0, -1].map do |q|
          [-1, 0, 1].map do |p|
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

# 36 Transformations
$transformations = [-1, 0, 1].permutation.to_a.product([-1, 0, 1].permutation.to_a)
$transformations.each_with_index do |transformation, i|
  eval <<-TRANSFORMATION
    module BinaryTransformationPQ#{i}
      def self.included(base)
        class << base
          def origin(binary_gate_class)
            gate = binary_gate_class.new
            @@transformed_table = #{transformation.first.inspect}.map do |p|
              #{transformation.last.inspect}.map do |q|
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

    module BinaryTransformationQP#{i}
      def self.included(base)
        class << base
          def origin(binary_gate_class)
            gate = binary_gate_class.new
            @@transformed_table = #{transformation.first.inspect}.map do |q|
              #{transformation.last.inspect}.map do |p|
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


#module Missing
#
#  def self.included(base)
#    class << base
#      def origin(binary_gate_class)
#        gate = binary_gate_class.new
#        @@transformed_table = [-1, -1, -1].map do |q|
#          [-1, 0, 1].map do |p|
#            gate.inputs = [p, q]
#            gate.to_i
#          end
#        end
#      end
#    end
#  end
#
#  def calculate
#    @@transformed_table[p+1][q+1]
#  end
#
#end

#puts transformation.inspect








# Interesting transforms
#@@transformed_table = [-1, 0, 1].map do |q|
#  [-1, 0, 1].map do |p|
#    binary_gate_class.new(p, q)
#  end
#end

#@@transformed_table = [0, 1, -1].map do |q|
#  [0, 1, -1].map do |p|
#    gate.inputs = [p, q]
#    gate.to_i
#  end
