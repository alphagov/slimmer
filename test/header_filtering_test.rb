require "test_helper"

class HeaderFilteringTest < SlimmerIntegrationTest
  ALLOWED_HEADERS = ["Vary", "Set-Cookie", "Location", "Content-Type", "Expires", "Cache-Control", "WWW-Authenticate", "Last-Modified", "ETag"]
  FORBIDDEN_HEADERS = ["Anything-Else"]

  given_response 200, %{Anything}, (ALLOWED_HEADERS + FORBIDDEN_HEADERS).inject({}) {|memo, header| memo[header] = header.downcase; memo}

  def test_allows_whitelisted_headers
    ALLOWED_HEADERS.each do |header|
      assert last_response.headers.keys.include?(header)
    end
  end

  def test_filters_other_headers
    FORBIDDEN_HEADERS.each do |header|
      refute last_response.headers.keys.include?(header)
    end
  end
end