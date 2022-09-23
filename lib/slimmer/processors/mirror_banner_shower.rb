module Slimmer::Processors
  class MirrorBannerShower
    def initialize(headers)
      @headers = headers
    end

    def filter(_src, dest)
      header_value = @headers[Slimmer::Headers::SHOW_MIRROR_BANNER]
      unless header_value == "TRUE"
        banner = dest.at_css("#mirror-banner")
        banner.remove if banner
      end
    end
  end
end
