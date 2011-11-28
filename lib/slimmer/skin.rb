module Slimmer
  class Skin
    attr_accessor :use_cache
    private :use_cache=, :use_cache

    attr_accessor :templated_cache
    private :templated_cache=, :templated_cache

    attr_accessor :asset_host
    private :asset_host=, :asset_host

    # TODO: Extract the cache to something we can pass in instead of using
    # true/false and an in-memory cache.
    def initialize asset_host, use_cache = false
      self.asset_host = asset_host
      self.templated_cache = {}
      self.use_cache = false
    end

    def template(template_name)
      return cached_template(template_name) if template_cached? template_name
      load_template template_name
    end

    def template_cached? name
      !cached_template(name).nil?
    end

    def cached_template name
      templated_cache[name]
    end

    def cache name, template
      return unless use_cache
      templated_cache[name] = template
    end

    def load_template template_name
      url = template_url template_name
      source = open(url, "r:UTF-8").read
      template = ERB.new(source).result binding
      cache template_name, template
      template
    end

    def template_url template_name
      host = asset_host.dup
      host += '/' unless host =~ /\/$/
      "#{host}templates/#{template_name}.html.erb"
    end

    def error(request, template_name, body)
      processors = [
        TitleInserter.new()
      ]
      process(processors, body, template(template_name))
    end

    def process(processors,body,template)
      src = Nokogiri::HTML.parse(body.to_s)
      dest = Nokogiri::HTML.parse(template)

      processors.each do |p|
        p.filter(src,dest)
      end

      return dest.to_html
    end

    def admin(request,body)
      processors = [
        TitleInserter.new(),
        TagMover.new(),
        AdminTitleInserter.new,
        FooterRemover.new,
        BodyInserter.new(),
        BodyClassCopier.new
      ]
      process(processors,body,template('admin'))
    end

    def success(request,body)
      processors = [
        TitleInserter.new(),
        TagMover.new(),
        BodyInserter.new(),
        BodyClassCopier.new,
        HeaderContextInserter.new(),
        SectionInserter.new()
      ]

      template_name = request.env.has_key?(TEMPLATE_HEADER) ? request.env[TEMPLATE_HEADER] : 'wrapper'
      process(processors,body,template(template_name))
    end
  end
end
