module Slimmer::Processors
  class MetaViewportRemover
    def initialize(skin, headers)
      @skin = skin
      @headers = headers
    end

    def filter(content_document, page_template)
      if should_remove_meta_viewport?
        viewport = page_template.at_xpath('//head//meta[@name="viewport"]')
        viewport.remove if viewport
      end
    end

    def should_remove_meta_viewport?
      !! @headers[Slimmer::Headers::REMOVE_META_VIEWPORT]
    end
  end
end
