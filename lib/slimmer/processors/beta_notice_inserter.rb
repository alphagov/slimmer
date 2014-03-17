module Slimmer::Processors
  class BetaNoticeInserter
    def initialize(skin, headers)
      @skin = skin
      @headers = headers
    end

    def filter(content_document, page_template)
      if should_add_beta_notice?
        warn "[DEPRECATION WARNING] BETA_HEADER is deprecated. Use BETA_LABEL instead."
        page_template.css('body').add_class('beta')
        if header = page_template.at_css('#global-header')
          header.add_next_sibling(beta_notice_block)
        end
        if footer = page_template.at_css('footer#footer')
          footer.add_previous_sibling(add_footer_class(beta_notice_block))
        end
      end
    end

    def should_add_beta_notice?
      !! @headers[Slimmer::Headers::BETA_HEADER]
    end

    def add_footer_class(block)
      block = Nokogiri::HTML.fragment(block)
      block.child['class'] = "#{block.child['class']} js-footer"
      block
    end

    def beta_notice_block
      @beta_notice_block ||= @skin.template('beta_notice')
    end
  end
end
