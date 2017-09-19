module Slimmer
  class LocalComponentResolver < ComponentResolver
  private

    def template_body(template_path)
      File.read(template_file(template_path))
    end

    def template_file(template_path)
      path = template_path.sub(/\.raw(\.html\.erb)?$/, '')

      if defined?(Rails)
        Rails.root.join("app", "views", "#{path}.raw.html.erb")
      else
        "#{path}.raw.html.erb"
      end
    end
  end
end
