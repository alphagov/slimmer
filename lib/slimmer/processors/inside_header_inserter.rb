module Slimmer::Processors
  class InsideHeaderInserter
    def filter(src, dest)
      insertion = src.at_css('.slimmer-inside-header')

      if insertion
        logo = dest.at_css('.header-logo')
        logo.add_next_sibling(insertion.inner_html) unless logo.nil?
      end
    end
  end
end
