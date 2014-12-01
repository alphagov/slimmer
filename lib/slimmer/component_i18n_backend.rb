require 'json'

module Slimmer
  class ComponentI18nBackend < I18n::Backend::KeyValue

    def initialize
    end

    def available_locales
      cache = Cache.instance

      cache.fetch(available_translation_file) do
        locale_json = fetch(translation_url(available_translation_file))
        locales = JSON.parse(locale_json).map(&:to_sym)
      end
    end

    def translate(locale, key, options={})
      cache = Cache.instance

      translations = cache.fetch(translation_file(locale)) do
        generate_translations(locale, translation_file(locale))
      end

      translations["#{locale}.#{key}".to_sym]
    end

  private

    def available_translation_file
      "translations"
    end

    def translation_file(locale)
      "translations/#{locale}"
    end

    def translation_url(file)
      [static_host, "templates", "govuk_component", file].compact.join('/')
    end

    def static_host
      @static_host ||= Plek.new.find('static')
    end

    def generate_translations(locale, locale_file)
      translations = JSON.parse(fetch(translation_url(locale_file)))
      flatten_translations(locale, translations, false, false)
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
