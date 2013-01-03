require 'minitest/autorun'
require 'rack/test'
require File.expand_path('../../slimmer_app', __FILE__)

class AppTest < MiniTest::Unit::TestCase
  include Rack::Test::Methods

  def app
    SlimmerApp.new
  end

  def test_returns_406_on_get
    get "/", {}, {'Content-Type' => 'application/json'}
    assert_equal 406, last_response.status
  end

  def test_returns_404_when_not_json
    post "/"
    assert_equal 404, last_response.status
  end
end