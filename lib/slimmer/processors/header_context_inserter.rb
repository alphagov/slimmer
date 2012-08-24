module Slimmer::Processors
  class HeaderContextInserter
    def initialize(path='.header-context')
      @path = path
    end

    def filter(src,dest)
      if dest.at_css(@path) && replacement = src.at_css(@path)
        header_context = src.fragment(replacement)
        dest.at_css(@path).replace(header_context)
      end
    end
  end
end
