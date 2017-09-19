require 'slimmer/govuk_request_id'
require 'active_support/core_ext/string/inflections'

module Slimmer
  class NetworkComponentResolver < ComponentResolver
  private

    def template_body(template_path)
      if test?
        test_body(template_path)
      else
        Slimmer.cache.fetch(template_path, expires_in: Slimmer::CACHE_TTL) do
          fetch(template_url(template_path))
        end
      end
    end

    def test?
      defined?(Rails) && Rails.env.test?
    end

    def fetch(template_url)
      HTTPClient.get(template_url)
    rescue RestClient::Exception => e
      raise TemplateNotFoundException, "Unable to fetch: '#{template_url}' because #{e}", caller
    rescue Errno::ECONNREFUSED => e
      raise CouldNotRetrieveTemplate, "Unable to fetch: '#{template_url}' because #{e}", caller
    rescue SocketError => e
      raise CouldNotRetrieveTemplate, "Unable to fetch: '#{template_url}' because #{e}", caller
    end

    def template_url(template_path)
      path = template_path.sub(/\.raw(\.html\.erb)?$/, '')
      [static_host, "templates", "#{path}.raw.html.erb"].join('/')
    end

    def static_host
      @static_host ||= Plek.new.find('static')
    end

    def test_body(path)
      %{<#{TEST_TAG_NAME} data-template="#{path.parameterize}"><%= JSON.dump(local_assigns) %></#{TEST_TAG_NAME}>}
    end
  end
end
