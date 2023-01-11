module Slimmer::Processors
  class NonceInserter
    def initialize(env)
      # As Rails is an optional dependency of this gem quietly do nothing if Rails
      # classes don't exist.
      @nonce = if defined?(ActionDispatch::Request)
                 ActionDispatch::Request.new(env).content_security_policy_nonce
               end
    end

    def filter(_src, dest)
      return unless @nonce

      # Add the nonce attribute to script elements that don't have a src attribute
      # we expect those with src to be on a CSP host allow list
      dest.css("script:not([src])").each do |script|
        script["nonce"] = @nonce
      end
    end
  end
end
