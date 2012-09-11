class Slimmer::Processors::RelatedItemsInserter
  include ERB::Util
  
  def initialize(related_block_template, artefact)
    @related_block_template = related_block_template
    @artefact = artefact
  end
  
  def filter(content_document, page_template)
    if content_document.at_css('body.mainstream div#related-items')
      page_template.at_css('body.mainstream div#related-items').replace(related_item_block)
    end
  end
  
  def related_item_block
    artefact = @artefact
    is_content_api_artefact = artefact.has_key?("related")
    html = ERB.new(@related_block_template).result(binding)
    Nokogiri::HTML.fragment(html)
  end
end
