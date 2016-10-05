module Slimmer::Processors
  class InsideHeaderInserter
    def filter(src, dest)
      insertion = src.at_css('.slimmer-inside-header')

      if insertion
        dest.at_css('.header-logo').add_next_sibling(insertion.inner_html)
      end
    end
  end
end
