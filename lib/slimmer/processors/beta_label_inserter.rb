module Slimmer::Processors
  class BetaLabelInserter
    def initialize(skin, headers)
      @skin = skin
      @headers = headers
    end

    def filter(page_template)
      if should_add_beta_label?
        if position == 'before'
          page_template.at_css(selector).add_previous_sibling(beta_label_block)
        elsif position == 'after'
          page_template.at_css(selector).add_next_sibling(beta_label_block)
        end
      end

    end

    def should_add_beta_label?
      !! @headers[Slimmer::Headers::BETA_LABEL]
    end

    def beta_label_block
      @beta_label_block ||= @skin.template('beta_label').to_s
    end

  private
    def selector
      @headers[Slimmer::Headers::BETA_LABEL].gsub(/.*:/, '')
    end

    def position
      @headers[Slimmer::Headers::BETA_LABEL].gsub(/:.*/, '')
    end
  end
end
