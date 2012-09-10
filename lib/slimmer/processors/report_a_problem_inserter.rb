module Slimmer::Processors
  class ReportAProblemInserter
    include ERB::Util

    def initialize(skin, url)
      @skin = skin
      @request_url = url
    end

    def filter(content_document, page_template)
      if (placeholder = page_template.at_css('body #report-a-problem'))
        placeholder.replace(report_a_problem_block)
      end
    end

    def report_a_problem_block
      request_url = @request_url
      report_a_problem_template = @skin.template('report_a_problem.raw')
      html = ERB.new(report_a_problem_template).result(binding)
      Nokogiri::HTML.fragment(html)
    end
  end
end

