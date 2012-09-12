class Slimmer::Artefact
  def initialize(artefact_data)
    @data = artefact_data
  end

  def slug
    id_to_slug(@data["id"])
  end

  def tags_of_type(type)
    return [] unless @data.has_key?("tags")
    @data["tags"].select do |t|
      t["details"]["type"] == type
    end
  end

  def legacy_sources
    tags_of_type('legacy_source').map do |t|
      id_to_slug(t["id"])
    end
  end

  def related_artefacts
    return [] unless @data.has_key?("related")
    @data["related"].map do |r|
      self.class.new(r)
    end
  end

  def method_missing(name, *args)
    @data[name.to_s] || @data["details"][name.to_s]
  end

  private

  def id_to_slug(id)
    id.split('/').last.chomp('.json')
  end
end
