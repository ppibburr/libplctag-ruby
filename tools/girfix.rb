o = "./PlcTag-1.0.gir"
buff = open(o).read
buff=buff.gsub(/<type name="int([0-9]+)"/) do |m,q|
p m,$1
"<type name=\"gint#{$1}\""
end
buff=buff.gsub(/<type name="uint([0-9]+)"/) do |m,q|
p m,$1
"<type name=\"guint#{$1}\""
end
buff=buff.gsub(/<type name="float([0-9]+)"/) do |m,q|
p m,$1
"<type name=\"gfloat#{$1}\""
end
buff=buff.gsub(/<type name="float"/) do |m,q|
p m,$1
"<type name=\"gfloat\""
end
buff=buff.gsub(/<type name="double"/) do |m,q|
p m,$1
"<type name=\"gdouble\""
end

buff=buff.gsub(/<type name="size_t"/) do |m,q|
p m,$1
"<type name=\"gsize\""
end

a= <<EOC
<record name="Tag" c:type="int32_t">
<function name="create" c:identifier="plc_tag_create">
  <return-value transfer-ownership="none">
      <type name="Plc.Tag" c:type="int32_t"
EOC

b = <<EOC
<record name="Tag" c:type="int32_t">
<function name="create" c:identifier="plc_tag_create">
  <return-value transfer-ownership="none">
      <type name="Tag" c:type="int32_t"
EOC

buff = buff.gsub(a.strip,b.strip)

File.open(o, "w") do |f| f.puts buff end
