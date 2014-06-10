module Slimmer::Processors
  class AlphaLabelInserter
    def initialize(skin, headers)
      @skin = skin
      @headers = headers
    end

    def filter(content_document, page_template)
      if should_add_alpha_label?
        if position == 'before'
          page_template.at_css(selector).add_previous_sibling(alpha_label_block)
        elsif position == 'after'
          page_template.at_css(selector).add_next_sibling(alpha_label_block)
        end
      end
    end

    def should_add_alpha_label?
      !! @headers[Slimmer::Headers::ALPHA_LABEL]
    end

    def alpha_label_block
      @alpha_label_block ||= @skin.template('alpha_label').to_s
    end

  private
    def selector
      @headers[Slimmer::Headers::ALPHA_LABEL].gsub(/.*:/, '')
    end

    def position
      @headers[Slimmer::Headers::ALPHA_LABEL].gsub(/:.*/, '')
    end
  end
end
