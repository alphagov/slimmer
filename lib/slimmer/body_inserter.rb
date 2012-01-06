module Slimmer
  class BodyInserter
    def initialize(path='#wrapper')
      @path = path
    end

    def filter(src,dest)
      body = Nokogiri::HTML.fragment(src.at_css(@path).to_html)
      dest.at_css(@path).replace(body)
    end
  end
end
