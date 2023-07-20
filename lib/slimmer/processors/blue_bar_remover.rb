module Slimmer::Processors
  class BlueBarRemover
    def initialize(headers)
      @headers = headers
    end

    def filter(_src, dest)
      if @headers.include?(Slimmer::Headers::REMOVE_BLUE_BAR_HEADER)
        blue_bar = dest.at_css(".gem-c-layout-for-public__blue-bar")
        blue_bar.remove if blue_bar
      end
    end
  end
end
