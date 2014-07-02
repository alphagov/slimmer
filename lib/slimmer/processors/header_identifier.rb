module Slimmer::Processors
  class HeaderIdentifier
    ID_PREFIX = "heading"
    attr_reader :ids_in_use

    def initialize
      @ids_in_use = []
    end

    def filter(_source, dest)
      dest.css('*[id]').each do |element|
        ids_in_use << element[:id] unless element[:id].nil?
      end

      dest.css('h1, h2, h3, h4, h5, h6').each do |element|
        element[:id] = deduplicated_id(id_from_text(element.inner_text)).to_s if element[:id].nil?
      end
    end

  private
    def id_from_text(header_text)
      id_base = header_text.downcase.gsub(/\W+/, '-').gsub(/(^-*)|(-*$)/, '')
      HeaderId.new(ID_PREFIX, id_base)
    end

    def deduplicated_id(header_id)
      if id_in_use?(header_id)
        header_id.iterate!
        deduplicated_id(header_id)
      else
        ids_in_use << header_id.to_s
        header_id
      end
    end

    def id_in_use?(header_id)
      ids_in_use.include?(header_id.to_s)
    end

    class HeaderId
      attr_reader :prefix, :base
      attr_accessor :iteration

      def initialize(prefix, base, iteration = 1)
        @prefix = prefix
        @base = base
        @iteration = iteration
      end

      def to_s
        if base.to_s == ''
          "#{prefix}-#{iteration}"
        elsif iteration > 1
          "#{prefix}-#{base}-#{iteration}"
        else
          "#{prefix}-#{base}"
        end
      end

      def iterate!
        self.iteration += 1
      end
    end
  end
end
