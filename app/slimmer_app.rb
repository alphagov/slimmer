require 'json'
require 'slimmer/skin'
require 'slimmer/headers'
require 'slimmer/artefact'
require 'logger'
require 'erb'
require 'nokogiri'

module Slimmer
  module Processors
  end
end

Dir["../lib/slimmer/processors/*.rb"].each { |proc| require proc }

class SlimmerApp
  POST_BODY = 'rack.input'.freeze
  attr_accessor :logger, :skin

  def initialize
    self.logger = Logger.new(STDOUT)
    self.skin = Slimmer::Skin.new(asset_host: 'https://static.preview.alphagov.co.uk/', logger: self.logger)
  end

  def call(env)
    if env['REQUEST_METHOD'] !~ %r{POST}i
      [406, {"Content-Type" => "text/plain"}, ["Not Acceptable"]]
    elsif env['CONTENT_TYPE'] =~ %r{application/json}i
      encoded_body = env[POST_BODY].read
      [200, {"Content-Type" => "text/html"}, [process(encoded_body)]]
    else
      [404, {"Content-Type" => "text/plain"}, ["I prefer JSON"]]
    end
  end

  def process(encoded_body)
    body = JSON.parse(encoded_body)
    html = body.delete('source_content')
    slim(html, body)
  end

  def slim(source_content, artefact_data)
    artefact = Slimmer::Artefact.new(artefact_data)
    headers = {}
    template_name = 'wrapper'
    context_url = 'http://www.example.com/blah'
    skin.process_success(headers, artefact, source_content, template_name, context_url)
  end
end
