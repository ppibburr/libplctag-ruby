require 'rmodbus'

class Plc
  class ModBus
    class Gateway < ::ModBus::TCPServer
      attr_reader :slave
      
      def initialize port=10002, slave: nil
        super port
        
        if slave
          # Configure default slave (UID 255) data
          @slave = with_slave(255)
          
        end
        
        start
      end
    end
  end
end

