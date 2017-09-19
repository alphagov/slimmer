module Slimmer
  class ComponentResolver < ::ActionView::Resolver
    TEST_TAG_NAME = 'test-govuk-component'

    def find_templates(name, prefix, partial, details, outside_app_allowed = false)
      return [] unless prefix == 'govuk_component'
      template_path = [prefix, name].join('/')
      details = {
        :format => 'text/html',
        :updated_at => Time.now,
        :virtual_path => template_path
      }

      [ActionView::Template.new(template_body(template_path), template_path, erb_handler, details)]
    end

  private
    def erb_handler
      @erb_handler ||= ActionView::Template.registered_template_handler(:erb)
    end

    def template_body(_template_path)
      raise NotImplementedError, "Use NetworkComponentResolver or LocalComponentResolver"
    end
  end
end
