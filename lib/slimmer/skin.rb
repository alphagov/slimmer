module Slimmer
  class Skin
    attr_accessor :use_cache
    private :use_cache=, :use_cache

    attr_accessor :templated_cache
    private :templated_cache=, :templated_cache

    attr_accessor :asset_host
    private :asset_host=, :asset_host

    attr_accessor :prefix
    private :prefix=, :prefix

    attr_accessor :logger
    private :logger=, :logger

    # TODO: Extract the cache to something we can pass in instead of using
    # true/false and an in-memory cache.
    def initialize asset_host, use_cache = false, prefix = nil, options = {}
      self.asset_host = asset_host
      self.templated_cache = {}
      self.prefix = prefix
      self.use_cache = false
      self.logger = options[:logger] || NullLogger.instance
    end

    def template(template_name)
      logger.debug "Slimmer: Looking for template #{template_name}"
      return cached_template(template_name) if template_cached? template_name
      logger.debug "Slimmer: Asking for the template to be loaded"
      load_template template_name
    end

    def template_cached? name
      logger.debug "Slimmer: Checking cache for template #{name}"
      cached = !cached_template(name).nil?
      logger.debug "Slimmer: Cache hit = #{cached}"
      cached
    end

    def cached_template name
      logger.debug "Slimmer: Trying to load cached template #{name}"
      templated_cache[name]
    end

    def cache name, template
      logger.debug "Slimmer: Asked to cache #{name}. use_cache = #{use_cache}"
      return unless use_cache
      logger.debug "Slimmer: performing caching"
      templated_cache[name] = template
    end

    def load_template template_name
      logger.debug "Slimmer: Loading template #{template_name}"
      url = template_url template_name
      logger.debug "Slimmer: template lives at #{url}"
      source = open(url, "r:UTF-8", :ssl_verify_mode => OpenSSL::SSL::VERIFY_NONE).read
      logger.debug "Slimmer: Evaluating the template as ERB"
      template = ERB.new(source).result binding
      cache template_name, template
      logger.debug "Slimmer: Returning evaluated template"
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
      logger.debug "Slimmer: starting skinning process"
      src = Nokogiri::HTML.parse(body.to_s)
      dest = Nokogiri::HTML.parse(template)

      start_time = Time.now
      logger.debug "Slimmer: Start time = #{start_time}"
      processors.each do |p|
        processor_start_time = Time.now
        logger.debug "Slimmer: Processor #{p} started at #{processor_start_time}"
        begin
          p.filter(src,dest)
        rescue => e
          logger.error "Slimmer: Failed while processing #{p}: #{[ e.message, e.backtrace ].flatten.join("\n")}"
        end
        processor_end_time = Time.now
        process_time = processor_end_time - processor_start_time
        logger.debug "Slimmer: Processor #{p} ended at #{processor_end_time} (#{process_time}s)"
      end
      end_time = Time.now
      logger.debug "Slimmer: Skinning process completed at #{end_time} (#{end_time - start_time}s)"

      return dest.to_html
    end

    def admin(request,body)
      processors = [
        TitleInserter.new(),
        TagMover.new(),
        AdminTitleInserter.new,
        FooterRemover.new,
        BodyInserter.new(),
        BodyClassCopier.new,
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
        SectionInserter.new(),
        GoogleAnalyticsConfigurator.new(request.env),
      ]

      template_name = request.env.has_key?(TEMPLATE_HEADER) ? request.env[TEMPLATE_HEADER] : 'wrapper'
      process(processors,body,template(template_name))
    end
  end
end
