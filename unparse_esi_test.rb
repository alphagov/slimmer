require './lib/slimmer'

options = [
  "<include src='/blah/blah'></include>",
  "<esi:include src='/blah/blah'></esi:include>",
  "<esi:include src='/blah/blah' />",
  "<include src='/blah/blah' />"
]

def unparse_esi(doc)
  doc.gsub("<include","<esi:include").gsub("</include","</esi:include")
end

options.each do |doc|
  s = Slimmer::Skin.new('blah')
  if s.unparse_esi(doc) == "<esi:include src='/blah/blah' />"
    puts "Worked: #{doc}"
  else
    puts "Failed: #{doc} - Got #{s.unparse_esi(doc)}"
  end
end