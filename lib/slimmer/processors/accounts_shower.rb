module Slimmer::Processors
  class AccountsShower
    def initialize(headers)
      @headers = headers
    end

    def filter(_src, dest)
      header_value = @headers[Slimmer::Headers::SHOW_ACCOUNTS_HEADER]
      if header_value == "signed-in"
        remove_signed_out(dest)
      elsif header_value == "signed-out"
        remove_signed_in(dest)
      else
        remove_signed_out(dest)
        remove_signed_in(dest)
      end
    end

    def remove_signed_out(dest)
      signed_out = dest.at_css("#global-header #accounts-signed-out")
      signed_out.remove if signed_out
    end

    def remove_signed_in(dest)
      signed_in = dest.at_css("#global-header #accounts-signed-in")
      signed_in.remove if signed_in
    end
  end
end
