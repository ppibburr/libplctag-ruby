# libplctag-ruby
libplctag bindings for Ruby. uses gobject-introspection

`rake install`
```ruby
require 'plc/tag'
t = PlcTag::Tag.create("protocol=modbus-tcp&gateway=127.0.0.1:10002&path=255&elem_count=4&name=hr0")
t.read 50 # timeout of 50ms
p t.get_int16(0)

t = Plc::Tag.new("protocol=modbus-tcp&gateway=127.0.0.1:10002&path=255&elem_count=4&name=hr0")
t.read 50 # timeout of 50ms
p t.get_int16(0)

plc = Plc.new("127.0.0.1", proto: "modbus-tcp", port: 10002, path: 255)
t =  plc.tag("h0", count: 4)
t.read 50 # timeout of 50ms
p t.get_int16(0)
```
