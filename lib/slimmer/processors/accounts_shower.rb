module Slimmer::Processors
  class AccountsShower
    def initialize(headers)
      @headers = headers
    end

    def filter(_src, dest)
      header_value = @headers[Slimmer::Headers::SHOW_ACCOUNTS_HEADER]
      layout_header = dest.at_css(".gem-c-layout-header")
      static_header = dest.at_css("#global-header")

      if header_value && layout_header
        static_header.remove if static_header
      elsif !header_value && !is_gem_layout?
        layout_header.remove if layout_header
      end

      case header_value
      when "signed-in"
        remove_signed_out(dest)
      when "signed-out"
        remove_signed_in(dest)
      else
        remove_signed_out(dest)
        remove_signed_in(dest)
      end

      if is_navigation_empty?(dest)
        header_content = dest.at_css(".govuk-header__content")
        header_content.remove if header_content
      end
    end

  private

    def remove_signed_out(dest)
      signed_out = dest.at_css("#global-header #accounts-signed-out")
      signed_out_link = dest.css(".gem-c-layout-header [data-link-for='accounts-signed-out']")

      signed_out.remove if signed_out
      signed_out_link.each do |link|
        link.parent.remove
      end
    end

    def remove_signed_in(dest)
      signed_in = dest.at_css("#global-header #accounts-signed-in")
      signed_in_link = dest.css(".gem-c-layout-header [data-link-for='accounts-signed-in']")

      signed_in.remove if signed_in
      signed_in_link.each do |link|
        link.parent.remove
      end
    end

    def is_navigation_empty?(dest)
      dest.at_css(".govuk-header__navigation a").nil?
    end

    def is_gem_layout?
      @headers[Slimmer::Headers::TEMPLATE_HEADER]&.start_with?("gem_layout")
    end
  end
end
