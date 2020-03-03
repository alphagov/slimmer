require "rails"
require "action_controller/railtie"

module Rails
  def self.cache
    Slimmer::NoCache.new
  end
end

module TestApp1
  class Application < Rails::Application
  end
end

module TestApp2
  class Application < Rails::Application
  end
end
