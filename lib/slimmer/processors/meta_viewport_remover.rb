module Slimmer::Processors
  class MetaViewportRemover
    def initialize(response)
      @response = response
    end

    def filter(src, dest)
      if @response.headers["X-Slimmer-Remove-Meta-Viewport"] == "true"
        dest.at_xpath('//head//meta[@name="viewport"]').remove
      end
    end
  end
end
