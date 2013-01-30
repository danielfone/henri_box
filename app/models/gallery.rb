class Gallery < DropboxRecord
  extend ActiveModel::Naming

  def initialize(dropbox_session, attributes)
    super dropbox_session
    @attributes = attributes
  end

  def name
    @name ||= @attributes['path'].gsub '/', ''
  end

  def updated_at
    @updated_at ||= DateTime.parse @attributes['modified']
  end

  def id
    @id ||= @attributes['rev']
  end

  def to_s
    id
  end

  def photos
    @photos ||= gallery_contents.collect { |hash| Photo.new @dropbox_session, hash }
  end

  def path
    @path ||= @attributes['path']
  end

  def find_photo(id)
    photos.find { |p| p.id == id }
  end

  private

    def gallery_contents
      cache_for_session([:gallery_contents, id]) { dropbox_client.metadata(name)['contents'] rescue [] }
    end

end
