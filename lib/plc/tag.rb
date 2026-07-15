require 'gio2'

module PlcTag;end

loader = GObjectIntrospection::Loader.new(PlcTag)
loader.load "PlcTag"

class Plc
  class Tag < PlcTag::Tag
    def self.new *o
      p @path = o[0]
      create *o
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
  
  def tag name, elem_count: nil, elem_size: nil, timeout: 50
   str = @config.merge({
      elem_count: elem_count,
      elem_size: elem_size,
      name: name
    }).find_all do |k,v|
      !!v
    end.map do |k,v| "#{k}=#{v}" end.join("&")

    return self.class::Tag.new(str, timeout)
  end
end

class Plc::LGX < Plc
  def initialize *o,**k
    k[:cpu] ||= :lgx
    super
  end
end

class Plc::ModBus < Plc
  class Tag < Plc::Tag
    def value
      raise ""
    end
    
    def values
      raise ""
    end
  end
  
  module Register
    def value offset=0, timeout: 50
      read timeout
      get_int16 offset, timeout
    end
    
    def values len, offset=0, timeout: 50
      read timeout
      (0..(len-1)).map do |i|
        get_int16 i*2
      end
    end
  end

  def initialize *o,**k
    k[:protocol] = "modbus-tcp"
    super
  end
  
  def holding_register i, count: 1
    t=tag "hr#{i}", elem_count: count
    t.extend Register
    t
  end
end

