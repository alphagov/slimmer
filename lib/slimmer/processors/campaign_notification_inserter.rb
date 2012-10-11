module Slimmer::Processors
  class CampaignNotificationInserter
    def initialize(headers)
      @headers = headers
      @old_campaign = ".main-campaign"
      @new_campaign = "#campaign-notification"
    end

    def filter(source, campaign_template)
      parsed_source = Nokogiri::HTML.parse(source)
      campaign = Nokogiri::HTML.parse(campaign_template)
      if @headers[Slimmer::Headers::CAMPAIGN_NOTIFICATION] == "true" &&
          parsed_source.at_css(@old_campaign) &&
          campaign.at_css(@new_campaign)
        notification = Nokogiri::HTML.fragment(campaign.at_css(@new_campaign).to_html)
        parsed_source.at_css(@old_campaign).replace(notification)
        return parsed_source.to_html
      end
      return source
    end
  end
end
