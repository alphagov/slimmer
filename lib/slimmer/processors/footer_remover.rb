module Slimmer::Processors
  class FooterRemover
    def filter(src, _dest)
      footer = src.at_css("#footer")
      footer.remove if footer
    end
  end
end
