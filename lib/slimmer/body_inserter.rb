module Slimmer
  class BodyInserter
    def initialize(path='#wrapper')
      @path = path
    end

    def filter(src,dest)
      body = src.fragment(src.at_css(@path))
      dest.at_css(@path).replace(body)
    end
  end
end
