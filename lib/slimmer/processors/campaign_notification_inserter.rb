module Slimmer::Processors
  class CampaignNotificationInserter
    def initialize(skin, headers)
      @headers = headers
      @skin = skin
      @old_campaign_selector = ".main-campaign"
      @new_campaign_selector = "#campaign-notification"
    end

    def filter(content_document, page_template)
      if @headers[Slimmer::Headers::CAMPAIGN_NOTIFICATION] == "true" &&
          old_campaign = page_template.at_css(@old_campaign_selector)
        new_campaign_block = campaign_notification_block
        if new_campaign_block.at_css(@new_campaign_selector)
          old_campaign.replace(new_campaign_block)
        end
      end
    end

    private

    def campaign_notification_block
      html = @skin.template('campaign')
      Nokogiri::HTML.fragment(html)
    end
  end
end
