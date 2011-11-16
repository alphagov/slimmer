require "test_helper"

class UnparseESITest < MiniTest::Unit::TestCase
  def unparse_esi(doc)
    doc.gsub("<include","<esi:include").gsub("</include","</esi:include")
  end

  def test_unparse_esi
    options = [
      "<include src='/blah/blah'></include>",
      "<esi:include src='/blah/blah'></esi:include>",
      "<esi:include src='/blah/blah' />",
      "<include src='/blah/blah' />"
    ]

    options.each do |doc|
      s = Slimmer::Skin.new('blah')
      assert_equal "<esi:include src='/blah/blah' />", s.unparse_esi(doc)
    end
  end
end