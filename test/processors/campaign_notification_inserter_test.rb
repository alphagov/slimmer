require "test_helper"

class CampaignNotificationInserterTest < MiniTest::Unit::TestCase
  def test_should_not_replace_campaign_if_header_not_set
    campaign = '<section id="campaign-notification"><p>testing...</p></section>'
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

    assert_equal expected.to_html.strip,
                 Slimmer::Processors::CampaignNotificationInserter.new({})
                   .filter(source.to_html, campaign).strip
  end

  def test_should_replace_campaign_with_notification_if_header_set
    campaign = '<section id="campaign-notification"><p>testing...</p></section>'
    source = as_nokogiri %{
      <html>
        <body>
          <section class="main-campaign group"><a href="/tour">A tour!</a></section>
        </body>
      </html>
    }

    headers = {Slimmer::Headers::CAMPAIGN_NOTIFICATION => "true"}
    expected = as_nokogiri %{
      <html>
        <body>
          <section id="campaign-notification"><p>testing...</p></section>
        </body>
      </html>
    }
    assert_equal expected.to_html.strip,
                 Slimmer::Processors::CampaignNotificationInserter.new(headers)
                   .filter(source.to_html, campaign).strip
  end
end
