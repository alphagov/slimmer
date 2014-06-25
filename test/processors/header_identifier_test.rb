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

    assert_equal "heading_subject_1", document.at_css("h1")[:id]
    assert_equal "heading_subject_2", document.at_css("h2")[:id]
    assert_equal "heading_subject_3", document.at_css("h3")[:id]
    assert_equal "heading_subject_4", document.at_css("h4")[:id]
    assert_equal "heading_subject_5", document.at_css("h5")[:id]
    assert_equal "heading_subject_6", document.at_css("h6")[:id]
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
    assert_equal 'heading_repeated_heading', ids[0]
    assert_equal 'heading_repeated_heading_2', ids[1]
    assert_equal 'heading_repeated_heading_3', ids[2]
  end

  def test_it_doesnt_reuse_ids_which_already_exist_in_the_document
    document = document_with_content %{
      <h1>Some heading</h1>
      <span id="heading_some_heading">Some conflicting id</span>
    }

    Slimmer::Processors::HeaderIdentifier.new.filter(:irrelevant, document)

    assert_equal 'heading_some_heading_2', document.at_css('h1')[:id]
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
