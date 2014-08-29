module Slimmer::Processors
  class ReportAProblemInserter
    include ERB::Util

    def initialize(skin, url, headers, wrapper_id)
      @skin = skin
      @request_url = url
      @headers = headers
      @wrapper_id = wrapper_id
    end

    def filter(content_document, page_template)
      if enabled? && container = page_template.at_css('#' + @wrapper_id)
        container.add_child(report_a_problem_block)
      end
    end

    def report_a_problem_block
      request_url = @request_url
      source      = @headers[Slimmer::Headers::APPLICATION_NAME_HEADER]
      page_owner  = @headers[Slimmer::Headers::PAGE_OWNER_HEADER]
      report_a_problem_template = @skin.template('report_a_problem.raw')
      html = ERB.new(report_a_problem_template).result(binding)
      Nokogiri::HTML.fragment(html)
    end

  private
    def enabled?
      @headers[Slimmer::Headers::REPORT_A_PROBLEM_FORM] != 'false'
    end
  end
end
