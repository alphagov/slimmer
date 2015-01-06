class Slimmer::Artefact
  def initialize(artefact_data)
    @data = artefact_data
  end

  def slug
    id_to_slug(@data["id"])
  end

  def tags_of_type(type)
    return [] unless self.tags
    self.tags.select do |t|
      t["details"]["type"] == type
    end
  end

  def primary_section
    tags_of_type("section").first
  end

  def primary_root_section
    section = primary_section
    while section and section["parent"]
      section = section["parent"]
    end
    section
  end

  def related_artefacts
    return [] unless self.related
    self.related.map do |r|
      self.class.new(r)
    end
  end

  def method_missing(name, *args)
    value = @data[name.to_s]
    value ||= @data["details"][name.to_s] if @data["details"]
    value
  end

  private

  def id_to_slug(id)
    id.split('/').last.chomp('.json')
  end
end
