module Slimmer
  class BodyInserter
    def initialize(source_path='#wrapper', destination_path='#wrapper')
      @source_path = source_path
      @destination_path = destination_path
    end

    def filter(src,dest)
      body = Nokogiri::HTML.fragment(src.at_css(@source_path).to_html)
      dest.at_css(@destination_path).replace(body)
    end
  end
end
