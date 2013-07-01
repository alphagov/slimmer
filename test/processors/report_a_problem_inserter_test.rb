require_relative '../test_helper'

class ReportAProblemInserterTest < MiniTest::Unit::TestCase

  def setup
    super
    @report_a_problem_template = File.read( File.dirname(__FILE__) + "/../fixtures/report_a_problem.raw.html.erb" )
    @skin = stub("Skin", :template => nil)
  end

  def test_should_add_report_a_problem_form_using_the_template_from_static
    @skin.expects(:template).with('report_a_problem.raw').returns(@report_a_problem_template)

    template = as_nokogiri %{
      <html>
        <body">
          <div id="wrapper">
            <div id="report-a-problem"></div>
          </div>
        </body>
      </html>
    }

    headers = { Slimmer::Headers::APPLICATION_NAME_HEADER => 'government' }
    Slimmer::Processors::ReportAProblemInserter.new(@skin, "http://www.example.com/somewhere?foo=bar", headers).filter(:any_source, template)
    assert_in template, "#wrapper div.report-a-problem-container"
    assert_in template, "div.report-a-problem-container form input[name=url][value='http://www.example.com/somewhere?foo=bar']"
    assert_in template, "div.report-a-problem-container form input[name=source][value='government']"
  end

  def test_should_not_add_report_a_problem_form_if_wrapper_element_missing
    template = as_nokogiri %{
      <html>
        <body class="mainstream">
          <div id="wrapper">
          </div>
        </body>
      </html>
    }

    @skin.expects(:template).never # Shouldn't fetch template when not inserting block

    Slimmer::Processors::ReportAProblemInserter.new(@skin, "", {}).filter(:any_source, template)
    assert_not_in template, "div.report-a-problem-container"
  end
end
