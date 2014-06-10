require_relative "../test_helper"

class AlphaLabelInserterTest < MiniTest::Unit::TestCase

  def setup
    super
    alpha_label_block = '<div class="alpha-label"><p>This page is ALPHA.</p></div>'
    @skin = stub("Skin", :template => alpha_label_block)
    @template = as_nokogiri %{
      <html><body><div><div id="wrapper"><header id="main">GOV.UK</header></div></div></body></html>
    }
  end

  def test_should_add_alpha_label_after

    headers = {
      Slimmer::Headers::ALPHA_LABEL => "after:header#main"
    }

    Slimmer::Processors::AlphaLabelInserter.new(@skin, headers).filter(nil, @template)

    assert_in @template, '#main + .alpha-label'
  end

  def test_should_add_alpha_label_before
    headers = {
      Slimmer::Headers::ALPHA_LABEL => "before:header#main"
    }

    Slimmer::Processors::AlphaLabelInserter.new(@skin, headers).filter(nil, @template)

    assert_in @template, '.alpha-label + #main'
  end

  def test_should_not_add_alpha_label
    headers = {}

    Slimmer::Processors::AlphaLabelInserter.new(@skin, headers).filter(nil, @template)

    assert_not_in @template, '.alpha-label'
  end
end
