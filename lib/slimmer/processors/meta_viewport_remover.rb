module Slimmer::Processors
  class MetaViewportRemover
    def initialize(response_headers)
      @headers = response_headers
    end

    def filter(src, dest)
      if @headers[Slimmer::Headers::REMOVE_META_VIEWPORT] == "true"
        dest.at_xpath('//head//meta[@name="viewport"]').remove
      end
    end
  end
end
