class Slimmer::Processors::RelatedItemsInserter
  include ERB::Util

  def initialize(skin, artefact, response)
    @skin = skin
    @artefact = artefact
    @response = response
  end

  def filter(content_document, page_template)
    if content_document.at_css('body.mainstream div#related-items')
      page_template.at_css('body.mainstream div#related-items').replace(related_item_block)
    end
  end
  
  private

  def related_item_block
    artefact = @artefact
    html = ERB.new(@skin.template('related.raw')).result(binding)
    Nokogiri::HTML.fragment(html)
  end
end
