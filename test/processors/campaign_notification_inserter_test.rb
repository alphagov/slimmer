require "test_helper"

class CampaignNotificationInserterTest < MiniTest::Unit::TestCase
  def setup
    @skin = stub("Skin", :template => nil)
  end

  def test_should_not_replace_campaign_if_header_not_set
    @skin.expects(:template).with("campaign").never
    campaign_inserter = Slimmer::Processors::CampaignNotificationInserter.new(@skin, {})

    source = as_nokogiri %{
      <html>
        <body>
          <section class="main-campaign group"><a href="/tour">A tour!</a></section>
        </body>
      </html>
    }
    expected = as_nokogiri %{
      <html>
        <body>
          <section class="main-campaign group"><a href="/tour">A tour!</a></section>
        </body>
      </html>
    }

    campaign_inserter.filter(:any_source, source)
    assert_equal expected.to_html, source.to_html
  end

  def test_should_replace_campaign_with_notification_if_header_set
    campaign = '<section id="campaign-notification"><p>testing...</p></section>'
    @skin.expects(:template).with('campaign').returns(campaign)

    headers = {Slimmer::Headers::CAMPAIGN_NOTIFICATION => "true"}
    campaign_inserter = Slimmer::Processors::CampaignNotificationInserter.new(@skin, headers)

    source = as_nokogiri %{
      <html><body><section class="main-campaign group"><a href="/tour">A tour!</a></section></body></html>
    }

    expected = as_nokogiri %{
      <html><body><section id="campaign-notification"><p>testing...</p></section></body></html>
    }

    campaign_inserter.filter(:any_source, source)
    assert_equal expected.to_html.gsub(/\n/," ").strip, source.to_html.gsub(/\n/," ").strip
  end
end
