require 'minitest/autorun'
require 'rack/test'
require File.expand_path('../../slimmer_app', __FILE__)

class AppTest < MiniTest::Unit::TestCase
  include Rack::Test::Methods

  def app
    SlimmerApp.new
  end

  def post_as_json(hash)
    header "Content-Type", "application/json"
    post "/", JSON.dump(hash)
  end

  def test_returns_406_on_get
    get "/", {}, {'Content-Type' => 'application/json'}
    assert_equal 406, last_response.status
  end

  def test_returns_404_when_not_json
    post "/"
    assert_equal 404, last_response.status
  end

  def test_can_skin_successfully
    source_content = '<div id="wrapper"><p>Hello World</p></div>'

    post_as_json('source_content' => source_content)
    assert_equal 200, last_response.status
    assert_match /GOV.UK - The best place to find government services and information/, last_response.body
  end
end