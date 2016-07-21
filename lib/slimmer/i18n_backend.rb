require 'json'

module Slimmer
  class I18nBackend
    include I18n::Backend::Base, I18n::Backend::Flatten

    def available_locales
      cache.fetch("available_locales") do
        locale_json = fetch(static_locales_url)
        locales = JSON.parse(locale_json).map(&:to_sym)
      end
    end

    def lookup(locale, key, scope = [], options = {})
      key = normalize_flat_keys(locale, key, scope, options[:separator])
      translations = translations(locale)
      translations["#{locale}.#{key}".to_sym]
    end

  private

    def cache
      Cache.instance
    end

    def translations(locale)
      cache.fetch("translations/#{locale}") do
        fetch_translations(locale)
      end
    end

    def static_locales_url(locale=nil)
      [static_host, "templates", "locales", locale].compact.join('/')
    end

    def static_host
      @static_host ||= Plek.new.find('static')
    end

    def fetch_translations(locale)
      url = static_locales_url(locale)
      json_data = fetch(url)
      translations = JSON.parse(json_data)
      flatten_translations(locale, translations, false, false)
    rescue TemplateNotFoundException
      {}
    end

    def fetch(url)
      headers = {}
      headers[:govuk_request_id] = GovukRequestId.value if GovukRequestId.set?
      response = RestClient.get(url, headers)
      response.body
    rescue RestClient::Exception => e
      raise TemplateNotFoundException, "Unable to fetch: '#{url}' because #{e}", caller
    rescue Errno::ECONNREFUSED => e
      raise CouldNotRetrieveTemplate, "Unable to fetch: '#{url}' because #{e}", caller
    rescue SocketError => e
      raise CouldNotRetrieveTemplate, "Unable to fetch: '#{url}' because #{e}", caller
    end
  end
end
