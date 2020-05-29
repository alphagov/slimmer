require_relative "../test_helper"

class InsideHeaderInserterTest < MiniTest::Test
  def test_should_insert_into_header
    source = as_nokogiri %(
      <html>
        <body>
          <div class="slimmer-inside-header">
            <h2>Inserted Page Title</h2>
          </div>
        </body>
      </html>
    )
    template = as_nokogiri %(
      <html>
        <body>
          <div class="header-global">
            <div class="header-logo">
              <a href="https://www.gov.uk/" title="Go to the GOV.UK homepage" id="logo" class="content">
                <img src="/assets/gov.uk_logotype_crown_invert_trans.png" width="35" height="31" alt="">
              </a>
            </div>
          </div>
        </body>
      </html>
    )

    Slimmer::Processors::InsideHeaderInserter.new.filter(source, template)

    assert_in template,
              "div.header-global .header-logo + h2",
              "Inserted Page Title",
              "Expecting the H2 to be inserted after .header-logo"
  end

  def test_should_fail_gracefully_if_logo_not_present
    source = as_nokogiri %(
      <html>
        <body>
          <div class="slimmer-inside-header">
            <h2>Inserted Page Title</h2>
          </div>
        </body>
      </html>
    )
    template = as_nokogiri %(
      <html>
        <body></body>
      </html>
    )

    # No exception should be thrown
    Slimmer::Processors::InsideHeaderInserter.new.filter(source, template)
  end
end
