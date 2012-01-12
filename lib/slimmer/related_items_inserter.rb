require 'gds_api/helpers'

class RelatedItemsInserter
  include GdsApi::Helpers
  include ERB::Util
  
  def initialize(related_block_template, external_request)
    @related_block_template = related_block_template
    @external_request = external_request
  end
  
  def requested_slug
    url_parts = @external_request.path_info.split('/')
    url_parts.size > 0 ? url_parts[1] : ''
  end
  
  def filter(content_document, page_template)
    if content_document.at_css('body.citizen div#related-items')
      page_template.at_css('body.citizen div#related-items').replace(related_item_block)
    end
  end
  
  def metadata_from_panopticon
    fetch_artefact(slug: requested_slug)
  end
  
  def related_item_block
    artefact = metadata_from_panopticon
    html = ERB.new(@related_block_template).result(binding)
    Nokogiri::HTML.fragment(html)
  end
end
