module Slimmer
  class AdminTitleInserter
    def filter(src,dest)
      title = src.at_css('#site-title')
      head  = dest.at_css('.gds-header h2')
      if head && title
        head.content = title.content
        title.remove
      end
    end
  end
end
