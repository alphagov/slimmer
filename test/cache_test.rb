require_relative "test_helper"

describe Slimmer::Cache do
  describe "a cache" do
    before do
      @cache = Slimmer::Cache.send(:new)
      @cache.use_cache = false
    end

    it "should not save item in cache by default" do
      @cache.fetch('not-cached') { "value1" }
      assert_equal 'new-value', @cache.fetch('not-cached') { "new-value" }
    end

    it "should return passed argument if cache is empty" do
      @cache.use_cache = true

      assert_equal 'new-value', @cache.fetch('uncached-key') { "new-value" }
    end

    it "should return cached argument if cache is enabled and warm" do
      @cache.use_cache = true

      @cache.fetch('cached-key') { "value1" }
      assert_equal 'value1', @cache.fetch('cached-key') { "new-value" }
    end

    it "should only cache the template for 5 mins by default" do
      @cache.use_cache = true

      @cache.fetch('timed-cached-key') { "value1" }
      Timecop.travel( 5 * 60 - 30) do # now + 4 mins 30 secs
        assert_equal "value1", @cache.fetch('timed-cached-key') { "value2" }
      end
      Timecop.travel( 5 * 60 + 30) do # now + 5 mins 30 secs
        assert_equal "value3", @cache.fetch('timed-cached-key') { "value3" }
      end
    end

    it "should allow overriding the cache ttl" do
      @cache.use_cache = true
      @cache.cache_ttl = 10 * 60

      @cache.fetch('ttl-timed-cached-key') { "value1" }
      Timecop.travel( 10 * 60 - 30) do # now + 9 mins 30 secs
        assert_equal "value1", @cache.fetch('ttl-timed-cached-key') { "value2" }
      end
      Timecop.travel( 10 * 60 + 30) do # now + 10 mins 30 secs
        assert_equal "value3", @cache.fetch('ttl-timed-cached-key') { "value3" }
      end
    end
  end
end
