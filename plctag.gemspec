Gem::Specification.new do |s|
  s.name        = "PlcTag"
  s.version     = "0.0.1"
  s.summary     = "Plc::Tag"
  s.description = "libplctag bindings for ruby"
  s.authors     = ["ppibburr"]
  s.email       = "tulnor33@gmail.com"
  s.files       = ["lib/plc/tag.rb", "bin/plc-tag","bin/plc-tag-web", "lib/plc/modbus/gateway.rb", "lib/plc/webapi.rb"]
  s.executables = ["plc-tag", "plc-tag-web", "plc-tag-modbus-plc"]
  s.homepage    =
    "https://github.com/ppibburr/libplctag-ruby"
  s.license       = "MIT"
end
