module Slimmer
  class FooterRemover
    def filter(src,dest)
      footer = src.at_css("#footer")
      footer.remove if footer
    end
  end
end
