module Slimmer::Processors
  class BetaNoticeInserter
    def initialize(skin, headers)
      @skin = skin
      @headers = headers
    end

    def filter(content_document, page_template)
      if should_add_beta_notice?
        page_template.at_css('body div#beta-notice').replace(beta_notice_block)
      end
    end

    def should_add_beta_notice?
      !! @headers[Slimmer::Headers::BETA_HEADER]
    end

    def beta_notice_block
      @beta_notice_block ||= @skin.template('beta_notice')
    end
  end
end

