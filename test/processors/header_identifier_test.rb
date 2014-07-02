require_relative "../test_helper"

class HeaderIdentifierTest < MiniTest::Unit::TestCase
  def test_it_adds_an_id_to_header_elements
    document = document_with_content %{
      <h1>Subject 1</h1>
      <h2><span>Subject</span> 2</h2>
      <h3>Subject&nbsp;3</h3>
      <h4>Subject-4*!</h4>
      <h5>  Subject 5  </h5>
      <h6>Subject...6</h6>
    }

    Slimmer::Processors::HeaderIdentifier.new.filter(:irrelevant, document)

    assert_equal "heading-subject-1", document.at_css("h1")[:id]
    assert_equal "heading-subject-2", document.at_css("h2")[:id]
    assert_equal "heading-subject-3", document.at_css("h3")[:id]
    assert_equal "heading-subject-4", document.at_css("h4")[:id]
    assert_equal "heading-subject-5", document.at_css("h5")[:id]
    assert_equal "heading-subject-6", document.at_css("h6")[:id]
  end

  def test_it_doesnt_modify_existing_header_ids
    document = document_with_content %{
      <h1 id="test_id">A header with an id</h1>
    }

    Slimmer::Processors::HeaderIdentifier.new.filter(:irrelevant, document)

    assert_equal "test_id", document.at_css("h1")[:id]
  end

  def test_it_generates_unique_ids_for_repeated_headings
    document = document_with_content %{
      <h1>Repeated Heading</h1>
      <h1>Repeated Heading</h1>
      <h1>Repeated Heading</h1>
    }

    Slimmer::Processors::HeaderIdentifier.new.filter(:irrelevant, document)

    ids = document.css('h1').map {|elem| elem[:id]}
    assert_equal 'heading-repeated-heading', ids[0]
    assert_equal 'heading-repeated-heading-2', ids[1]
    assert_equal 'heading-repeated-heading-3', ids[2]
  end

  def test_it_doesnt_reuse_ids_which_already_exist_in_the_document
    document = document_with_content %{
      <h1>Some heading</h1>
      <span id="heading-some-heading">Some conflicting id</span>
    }

    Slimmer::Processors::HeaderIdentifier.new.filter(:irrelevant, document)

    assert_equal 'heading-some-heading-2', document.at_css('h1')[:id]
  end

  def test_it_generates_sensible_ids_for_purely_numeric_headings
    document = document_with_content %{
      <h1>123</h1>
      <h2>123</h2>
    }

    Slimmer::Processors::HeaderIdentifier.new.filter(:irrelevant, document)

    assert_equal 'heading-123', document.at_css('h1')[:id]
    assert_equal 'heading-123-2', document.at_css('h2')[:id]
  end

  def test_it_ignores_non_asci_characters_in_headings
    document = document_with_content %{
      <h1>News: 英国政府的网站特好</h1>
    }

    Slimmer::Processors::HeaderIdentifier.new.filter(:irrelevant, document)

    assert_equal 'heading-news', document.at_css('h1')[:id]
  end

  def test_it_generates_an_id_of_heading_x_when_there_are_no_useable_characters_in_the_heading_text
    document = document_with_content %{
      <h1>谷歌翻译不想翻译考材料</h1>
      <h2>.....</h2>
    }

    Slimmer::Processors::HeaderIdentifier.new.filter(:irrelevant, document)

    assert_equal 'heading-1', document.at_css('h1')[:id]
    assert_equal 'heading-2', document.at_css('h2')[:id]
  end

private
  def document_with_content(content)
    as_nokogiri %{
      <html>
        <body>
          #{content}
        </body>
      </html>
    }
  end
end
