class Slimmer::Processors::RelatedItemsInserter
  include ERB::Util
  
  def initialize(skin, artefact)
    @skin = skin
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
    related_block_template = @skin.template('related.raw')
    html = ERB.new(related_block_template).result(binding)
    Nokogiri::HTML.fragment(html)
  end
end
