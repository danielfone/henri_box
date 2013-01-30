class Photo < DropboxRecord

  def initialize(dropbox_session, attributes)
    super dropbox_session
    @attributes = attributes
  end

  def path
    @attributes['path']
  end

  def thumbnail
    cache_for_session([:thumbnail, 128, id]) { dropbox_client.thumbnail path, 'm' }
  end

  def id
    @id ||= @attributes['rev']
  end

  def to_s
    id
  end

  def url
    cache_for_session([:photo_url, id]) { dropbox_client.media(path)['url'] }
  end

end
