require 'gio2'

module PlcTag;end

loader = GObjectIntrospection::Loader.new(PlcTag)
loader.load "PlcTag"

class Plc
  Tag = PlcTag::Tag
  
  class PlcTag::Tag
    attr_accessor :value_type
    
    include Enumerable
  
    def self.new *o, value_type: nil, &b
      p @path = o[0]
      t = create *o
      t.value_type = value_type
      
      if b
        t.read 50
        b.call t
        t.destroy
      end
      
      t
    end
    
    def [] i
      raise unless value_type
      
      if i.is_a?(Range)
        last = i.last
        last = length+i.last if i.last < 0
        
        return((i.first..(last)).map do |i|
          self[i]
        end)
      end
      
      send(:"get_#{value_type}", i*elem_size)
    end
    
    def []= i,v
      raise unless value_type
      
      send(:"set_#{value_type}", i*elem_size, v)
      return v
    end    
    
    def length
      get_int_attribute("elem_count", 0)
    end
    
    def elem_size
      get_int_attribute("elem_size", 0)
    end
    
    def map o=0, type: @value_type, &b
      (0..(length-1)).map do |i|
        if !type
          b.call i*elem_size, self
        else
          b.call send(:"get_#{type}", i*elem_size)
        end
      end
    end
    
    def each o=0, type: @value_type, &b
      map(o, type: type) do |a| a end.each &b
    end 
  end
  
  def initialize addr, path: 0, port: nil, protocol: nil, cpu: nil
    @config = {
      gateway: "#{addr}#{port ? ":#{port}" : ""}",
      path: path,
      protocol: protocol,
      cpu: cpu
    }
  end
  
  def tag name, elem_count: nil, elem_size: nil, timeout: 50, value_type: nil, &b
   str = @config.merge({
      elem_count: elem_count,
      elem_size: elem_size,
      name: name
    }).find_all do |k,v|
      !!v
    end.map do |k,v| "#{k}=#{v}" end.join("&")
    
    return self.class::Tag.new(str, timeout, value_type: value_type, &b)
  end
end

class Plc::LGX < Plc
  def initialize *o,**k
    k[:cpu] ||= :lgx
    super
  end
end

class Plc::ModBus < Plc
  def initialize *o,**k
    k[:protocol] = "modbus-tcp"
    super
  end
  
  def coils n=1, o = 0, &b
    t = tag "co#{o}", elem_count: n, value_type: :bit, &b
  end
  
  def holding_registers n=1, o=0, &b
    t = tag "hr#{o}", elem_count: n, value_type: :int16, &b
  end
end

if __FILE__ == $0
  
end
