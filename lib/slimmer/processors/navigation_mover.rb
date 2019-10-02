class Slimmer::Processors::NavigationMover
  def initialize(skin)
    @skin = skin
  end

  def filter(src, dest)
    proposition_header = src.at_css("#proposition-menu")
    global_header = dest.at_css("#global-header")
    if proposition_header && global_header
      proposition_header.remove

      global_header['class'] = [global_header['class'], 'with-proposition'].compact.join(' ')

      header_block = Nokogiri::HTML.fragment(proposition_header_block)
      header_block.at_css('.content') << proposition_header

      global_header.at_css('.header-wrapper') << header_block
    end
  end

  def proposition_header_block
    @proposition_header_block ||= @skin.template('proposition_menu')
  end
end
