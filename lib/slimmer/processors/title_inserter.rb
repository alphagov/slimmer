module Slimmer::Processors
  class TitleInserter
    def filter(src,dest)
      title = src.at_css('head title')
      head  = dest.at_xpath('/html/head')
      if head && title
        insert_title(title,head)
      end
    end

    def insert_title(title, head)
      if head.at_css('title').nil?
        head.first_element_child.nil? ? head << title : head.first_element_child.before(title)
      else
        head.at_css('title').replace(title)
      end
    end
  end
end
