require 'slimmer/govuk_request_id'
require 'active_support/core_ext/string/inflections'

module Slimmer
  class ComponentResolver < ::ActionView::Resolver
    TEST_TAG_NAME = 'test-govuk-component'

    def self.caching
      # this turns off the default ActionView::Resolver caching which caches
      # all templates for the duration of the current process in production
      false
    end

    def find_templates(name, prefix, partial, details, outside_app_allowed = false)
      return [] unless prefix == 'govuk_component'

      template_path = [prefix, name].join('/')
      if test?
        template_body = test_body(template_path)
      else
        template_body = Slimmer.cache.fetch(template_path, expires_in: Slimmer::CACHE_TTL) do
          fetch(template_url(template_path))
        end
      end

      details = {
        :format => 'text/html',
        :updated_at => Time.now,
        :virtual_path => template_path
      }

      [ActionView::Template.new(template_body, template_path, erb_handler, details)]
    end

  private
    def test?
      defined?(Rails) && Rails.env.test?
    end

    def erb_handler
      @erb_handler ||= ActionView::Template.registered_template_handler(:erb)
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
      %Q{<#{TEST_TAG_NAME} data-template="#{path.parameterize}"><%= JSON.dump(local_assigns) %></#{TEST_TAG_NAME}>}
    end
  end
end
