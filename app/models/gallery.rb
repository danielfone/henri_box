class Gallery
  extend ActiveModel::Naming


  def initialize(attributes)
    @attributes = attributes
  end

  def name
    @name ||= @attributes['path'].gsub '/', ''
  end

  def updated_at
    @updated_at ||= DateTime.parse @attributes['modified']
  end

  def to_s
    @attributes['rev']
  end

end
