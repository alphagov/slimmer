require_relative "../test_helper"

class BetaLabelInserterTest < MiniTest::Unit::TestCase

  def setup
    super
    beta_label_block = '<div class="beta-label"><p>This page is BETA.</p></div>'
    @skin = stub("Skin", :template => beta_label_block)
    @template = as_nokogiri %{
      <html><body><div><div id="wrapper"><header id="main">GOV.UK</header></div></div></body></html>
    }
  end

  def test_should_add_beta_label_after    

    headers = {
      Slimmer::Headers::BETA_LABEL => "after:header#main"
    }

    Slimmer::Processors::BetaLabelInserter.new(@skin, headers).filter(nil, @template)

    assert_in @template, '#main + .beta-label'
  end

  def test_should_add_beta_label_before
    headers = {
      Slimmer::Headers::BETA_LABEL => "before:header#main"
    }

    Slimmer::Processors::BetaLabelInserter.new(@skin, headers).filter(nil, @template)

    assert_in @template, '.beta-label + #main'
  end

  def test_should_not_add_beta_label
    headers = {}

    Slimmer::Processors::BetaLabelInserter.new(@skin, headers).filter(nil, @template)

    assert_not_in @template, '.beta-label'
  end
end
