require 'slimmer/govuk_request_id'
require 'active_support/core_ext/string/inflections'

module Slimmer
  class ComponentResolver < ::ActionView::Resolver
    def find_templates(name, prefix, partial, details)
      return [] unless prefix == 'govuk_component'

      template_path = [prefix, name].join('/')
      if test?
        template_body = test_body(template_path)
      else
        template_body = fetch(template_url(template_path))
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
      headers = {}
      headers[:govuk_request_id] = GovukRequestId.value if GovukRequestId.set?
      response = RestClient.get(template_url, headers)
      response.body
    rescue RestClient::Exception => e
      raise TemplateNotFoundException, "Unable to fetch: '#{template_url}' because #{e}", caller
    rescue Errno::ECONNREFUSED => e
      raise CouldNotRetrieveTemplate, "Unable to fetch: '#{template_url}' because #{e}", caller
    rescue SocketError => e
      raise CouldNotRetrieveTemplate, "Unable to fetch: '#{template_url}' because #{e}", caller
    end

    def template_url(template_path)
      [static_host, "templates", "#{template_path}.raw.html.erb"].join('/')
    end

    def static_host
      @static_host ||= Plek.new.find('static')
    end

    def test_body(path)
      %Q{<div class="#{path.parameterize}"><%= local_assigns.keys.join(' ') %></div>}
    end
  end
end
