module Slimmer::Processors
  class BetaNoticeInserter
    def initialize(skin)
      @skin = skin
    end

    def filter(content_document, page_template)
      if page_template.at_css('body.beta')
        if cookie_bar = page_template.at_css('#global-cookie-message')
          cookie_bar.add_next_sibling(beta_notice_block)
        end
        if footer = page_template.at_css('footer#footer')
          footer.add_previous_sibling(beta_notice_block)
        end
      end
    end

    def beta_notice_block
      @beta_notice_block ||= @skin.template('beta_notice')
    end
  end
end

