def column_swaps
  ['PC', 'CS', 'PS']
end

def row_swaps
  ['TH', 'HB', 'TB']
end

def column_shifts
  ['L', 'R']
end

def row_shifts
  ['U', 'D']
end

def weaves
  ['', 'W']
end

def swaps
  column_swaps + row_swaps
end

def shifts
  column_shifts + row_shifts
end

def transformation_types
  [weaves, column_swaps, row_swaps, column_shifts, row_shifts]
end

def ordered
  transformation_types.flatten
end

def transformation_codes
  @transformation_codes ||=
  transformation_types.size.times.to_a.inject([]) { |combinations, i|
    combinations += transformation_types.combination(i + 1).to_a
  }.map { |group|
    group[1..-1].inject(group.first) { |current, set|
      current.product(set).map(&:flatten)
    }
  }.inject([]) { |array, x|
    array + x
  }.map { |x|
    Array(x).sort { |a, b|
      ordered.index(a) <=> ordered.index(b)
    }.join
  }.uniq.sort
end


def single_transformation_name(x)
  if swaps.include?(x)
    "Swap#{x}"
  elsif shifts.include?(x)
    "Shift#{x}"
  elsif x == 'W'
    'Weave'
  else
    raise "Unknown transformation code #{x}"
  end
end

def transformation_code_to_a(code)
  code.gsub(/./) { |letter|
    "#{letter} "
  }.gsub(/P C|P S|C S|T H|H B|T B/) { |single_transformation_code|
    single_transformation_code.gsub(' ','')
  }.split
end

def transformation_name(code)
  transformation_code_to_a(code).map { |single_code|
    single_transformation_name(single_code)
  }.join.gsub(/Shift.Shift/) { |dual_shifts|
    dual_shifts[0..5]
  }.gsub(/Swap..Swap/) { |dual_swaps|
    dual_swaps[0..5]
  }
end

def transformation_names
  @transformation_names ||= transformation_codes.map { |code| transformation_name(code) }
end


def pq_map(code)

  p = [-1, 0, 1]
  q = [-1, 0, 1]

  a = p
  b = q

  codes = transformation_code_to_a(code)
  codes.each do |trans|
    case trans
      when 'PC'
        a[0], a[1] = a[1], a[0]
      when 'CS'
        a[1], a[2] = a[2], a[1]
      when 'PS'
        a[0], a[2] = a[2], a[0]
      when 'TH'
        q[0], b[1] = b[1], b[0]
      when 'HB'
        b[1], b[2] = b[2], b[1]
      when 'TB'
        b[0], b[2] = b[2], b[0]
      when 'L'
        a.push(a.shift)
      when 'R'
        a.unshift(a.pop)
      when 'U'
        b.push(b.shift)
      when 'D'
        b.unshift(b.pop)
      when 'W'
        a, b = b, a
    end
  end

  #p, q = q, p if codes.first == 'W'

  [p, q]

end


transformation_codes.each do |code|
  code_map = pq_map(code)
  weave = transformation_code_to_a(code).first == 'W'
  #if code == ''
  #  name = 'Identity'
  #else
  #  name = transformation_name(code)
  #end
  #name = "Trans#{name}"
  name = "Trans#{code}"
  if weave
    eval <<-WEAVETRANSFORMATION
        module #{name}
          def self.included(base)
            class << base
              def origin(binary_gate_class)
                gate = binary_gate_class.new
                @@transformed_table = #{code_map.first.inspect}.map do |q|
                  #{code_map.last.inspect}.map do |p|
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
    WEAVETRANSFORMATION
  else
    eval <<-TRANSFORMATION
        module #{name}
          def self.included(base)
            class << base
              def origin(binary_gate_class)
                gate = binary_gate_class.new
                @@transformed_table = #{code_map.first.inspect}.map do |p|
                  #{code_map.last.inspect}.map do |q|
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



#transformation_codes.each { |x| puts x.inspect }
#transformation_names.each { |x| puts x.inspect }
#transformation_codes.each_with_index { |code, i| puts "#{code} => #{transformation_names[i]}" }
#transformation_codes.each_with_index { |code, i| puts "#{code} => #{pq_map(code)}" }
#transformation_codes.each_with_index { |code, i| puts "#{code} => #{transformation_code_to_a(code)}" }
#puts transformation_codes.size




#puts key.map { |x| '%1i' % x }.each_slice(3).to_a.map { |x| x.join(' ') }
