module Slimmer::Processors
  class HeaderIdentifier
    ID_PREFIX = "heading"
    attr_reader :ids_in_use

    def initialize
      @ids_in_use = []
    end

    def filter(_source, dest)
      headings = dest.css('h1, h2, h3, h4, h5, h6')

      headings.each do |element|
        ids_in_use << element[:id] unless element[:id].nil?
      end

      headings.each do |element|
        element[:id] = deduplicated_id(id_from_text(element.inner_text)) if element[:id].nil?
      end
    end

  private
    def id_from_text(header_text)
      "#{ID_PREFIX}_#{header_text.downcase.gsub(/\W+/, '_').gsub(/(^_*)|(_*$)/, '')}"
    end

    def deduplicated_id(raw_id)
      if id_in_use?(raw_id)
        deduplicated_id(iterate_id(raw_id))
      else
        ids_in_use << raw_id
        raw_id
      end
    end

    def id_in_use?(id)
      ids_in_use.include?(id)
    end

    def iterate_id(id)
      if id =~ /.*_\d*$/
        id.gsub(/(.*_)(\d*)$/) {|match|
          $1 + ($2.to_i + 1).to_s
        }
      else
        id + "_2"
      end
    end
  end
end
