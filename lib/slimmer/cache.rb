require 'singleton'

module Slimmer
  class Cache
    include Singleton
    attr_writer :use_cache, :cache_ttl

    # TODO: use a real cache rather than an in memory hash
    def initialize
      @cache_last_reset= Time.now

      @use_cache = false
      @cache_ttl = (5 * 60) # 5 mins

      @data_store = {}
    end

    def clear
      @data_store.clear
    end

    def fetch(key)
      clear_cache_if_stale
      data = @data_store[key]

      if data.nil?
        data = yield
      end

      if @use_cache
        @data_store[key] = data
      end

      data
    end

  private
    def clear_cache_if_stale
      time_to_clear_cache = @cache_last_reset + @cache_ttl
      if time_to_clear_cache < Time.now
        @data_store.clear
        @cache_last_reset = Time.now
      end
    end
  end
end
