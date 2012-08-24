module Slimmer::Processors
  class BodyClassCopier
    def filter(src, dest)
      src_body_tag = src.at_css("body")
      dest_body_tag = dest.at_css('body')
      if src_body_tag.has_attribute?("class")
        combinded_classes = dest_body_tag.attr('class').to_s.split(/ +/)
        combinded_classes << src_body_tag.attr('class').to_s.split(/ +/)
        dest_body_tag.set_attribute("class", combinded_classes.join(' '))
      end
    end
  end
end
