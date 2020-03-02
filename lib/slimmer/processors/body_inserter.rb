module Slimmer::Processors
  class BodyInserter
    def initialize(source_id = "wrapper", destination_id = "wrapper")
      @source_selector = "#" + source_id
      @destination_selector = "#" + destination_id
    end

    def filter(src, dest)
      body = Nokogiri::HTML.fragment(src.at_css(@source_selector).to_html)
      dest.at_css(@destination_selector).replace(body)
    end
  end
end
